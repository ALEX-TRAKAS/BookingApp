import 'package:bookingapp/screens/filterScreen.dart';
import 'package:bookingapp/utils/debouncer.dart';
import 'package:bookingapp/utils/filteringFunctions.dart';
import 'package:bookingapp/widgets/customDrawer.dart';
import 'package:bookingapp/widgets/login_dialog.dart';
import 'package:bookingapp/widgets/webFooter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/services/databaseFunctions.dart';
import 'package:bookingapp/utils/AppStyles.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class webSearchScreen extends StatefulWidget {
  Map<String, dynamic>? locationData;
  String? date;
  String? time;
  webSearchScreen({
    super.key,
    this.locationData,
    this.date,
    this.time,
  });

  @override
  _webSearchScreenState createState() => _webSearchScreenState();
}

class _webSearchScreenState extends State<webSearchScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final db = databaseFunctions();
  ScrollController scrollViewController = ScrollController();
  ScrollController webScrollViewController = ScrollController();
  TextEditingController editingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? userData;
  String profilePicUrl = '';
  String displayName = '';
  List<Map<String, dynamic>> restaurants = [];
  List<Map<String, dynamic>> _allRestaurants = [];
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 0;
  int _selectedGuestsIndex = 0;
  double lat = 0;
  double lng = 0;
  String name = '';
  String postalCode = '';
  final debouncer = Debouncer(delay: const Duration(milliseconds: 200));
  final List<Map<String, dynamic>> _dateOptions = [];
  final List<Map<String, dynamic>> _dateOptionsEng = [];
  final List<String> _timeOptions = [
    '01:00',
    '01:30',
    '02:00',
    '02:30',
    '03:00',
    '03:30',
    '04:00',
    '04:30',
    '05:00',
    '05:30',
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
    '22:00',
    '22:30',
    '23:00',
    '23:30',
  ];
  final List<String> _guestsOptions =
      List.generate(9, (index) => '${index + 1} άτομα');
  Map<String, Object> selectedLocation = {};
  bool _buttonPressed = false;
  bool isLoading = false;

  @override
  void initState() {
    if (mounted) {
      super.initState();
      loadUserData();
      loadLocationData();
      final startDate = DateTime.now();
      final endDate = DateTime.now().add(const Duration(days: 31));
      final days = getDaysInBetween(startDate, endDate);
      for (var i = 0; i < days.length; i++) {
        _dateOptions.add({
          'date': DateFormat('EEE dd MMM', 'el_GR').format(days[i]),
        });
      }
      for (var i = 0; i < days.length; i++) {
        _dateOptionsEng.add({
          'date': DateFormat('EEEE dd MMM', 'en_US').format(days[i]),
        });
      }
    }
  }

  @override
  void dispose() {
    editingController.dispose();
    scrollViewController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    Map<String, dynamic>? userData =
        await databaseFunctions().getUserData(user.uid);

    print(userData);
    setState(() {
      if (user.photoURL == null) {
        profilePicUrl = '';
      } else {
        profilePicUrl = user.photoURL.toString();
      }
      if (user.displayName == null) {
        displayName = userData!['firstName'] + '\t' + userData!['lastName'];
      } else {
        displayName = user.displayName!;
      }
    });
  }

  Future<void> getFromFirebase(String postalCode) async {
    if (mounted) {
      setState(() {});
    }
    try {
      final List<Map<String, dynamic>> fetchedRestaurants =
          await databaseFunctions
              .getFromFirebase(postalCode.replaceAll(' ', ''));
      if (mounted) {
        setState(() {
          restaurants = fetchedRestaurants;
          _allRestaurants = List.from(restaurants);
        });
      }
      print(_allRestaurants);
    } catch (e) {
      print('Error fetching restaurants: $e');
      // Handle the error, show an error message, or retry
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> getFromFirebaseLocation(String locationName) async {
    if (mounted) {
      setState(() {});
    }
    try {
      final List<Map<String, dynamic>> fetchedRestaurants =
          await databaseFunctions.getFromFirebaseLocation(locationName);
      if (mounted) {
        setState(() {
          restaurants = fetchedRestaurants;
          _allRestaurants = List.from(restaurants);
        });
      }
      print(_allRestaurants);
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void searchRestaurants(String query) {
    if (mounted) {
      setState(() {
        if (query.isEmpty) {
          restaurants = List.from(_allRestaurants);
        } else {
          // Filter restaurants based on the query from _allRestaurants
          restaurants = _allRestaurants.where((restaurant) {
            final restaurantName = restaurant['name'].toString().toLowerCase();
            final input = query.toLowerCase();
            return restaurantName.startsWith(input);
          }).toList();
        }
      });
    }
  }

  void updateRestaurants(List<Map<String, dynamic>> selectedRestaurants) {
    if (mounted) {
      setState(() {
        restaurants = selectedRestaurants;
        _allRestaurants = selectedRestaurants;
      });
    }
  }

  Future<void> showFilterScreenDialog(
      BuildContext context, List<Map<String, dynamic>> initialValues) async {
    List<Map<String, dynamic>>? returnedValues = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FilterScreen(initialValues: initialValues)),
    );

    if (returnedValues != null) {
      setState(() {
        restaurants = returnedValues;
      });
    }
  }

  void removeFilters() {
    updateRestaurants(_allRestaurants);
  }

  void _applyChanges() {
    print(_dateOptions[_selectedDateIndex]);
    String dateString = _dateOptionsEng[_selectedDateIndex]["date"];
    String day = extractDay(dateString);
    print(_timeOptions[_selectedTimeIndex]);
    print(_guestsOptions[_selectedGuestsIndex]);
    updateRestaurants(filterRestaurants(
        day, _timeOptions[_selectedTimeIndex], _allRestaurants));
  }

  void handleSelection(List<Map<String, dynamic>> filteredRestaurants) {
    Navigator.pop(context, filteredRestaurants);
  }

  void loadLocationData() async {
    final Map<String, dynamic>? data = widget.locationData;
    final List<dynamic> addressComponents = data!['address_components'];
    print(data['address_components']);

    for (var component in addressComponents) {
      final List<dynamic> types = component['types'];
      if (types.contains('postal_code')) {
        postalCode = component['long_name'];
        break;
      }
    }
    final Map<String, dynamic> geometry = data['geometry'];
    final Map<String, dynamic> location = geometry['location'];
    lat = location['lat'];
    lng = location['lng'];
    name = data['name'];
    final String formattedAddress = data['formatted_address'];

    if (postalCode.isEmpty) {
      getFromFirebaseLocation(name);
    } else {
      getFromFirebase(postalCode);
    }

    print(
        'Name: $name, Formatted Address: $formattedAddress, Latitude: $lat, Longitude: $lng, Postal Code: $postalCode');
  }

  void _skipChanges() {
    setState(() {
      _buttonPressed = !_buttonPressed;
    });
    updateRestaurants(_allRestaurants);
  }

  void _onLoginSuccess() {
    if (user == null) {
      setState(() {
        context.pushReplacementNamed(webHomeScreenNameRoute);
      });
    }
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return constraints.maxWidth < 600
                ? Scaffold(
                    backgroundColor: Colors.white,
                    body: Stack(
                      children: [
                        LoginDialog(
                          onLoginSuccess: () {
                            Navigator.of(context).pop();
                            _onLoginSuccess();
                          },
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.close, size: 24),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Container(
                      color: Colors.white,
                      constraints:
                          const BoxConstraints(maxWidth: 600, maxHeight: 660),
                      child: Stack(
                        children: [
                          LoginDialog(
                            onLoginSuccess: () {
                              _onLoginSuccess();
                              setState(() {
                                // loadUserData();
                              });
                            },
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(Icons.close, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
          },
        );
      },
    );
  }

  void showReservationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          contentPadding: const EdgeInsets.all(20.0),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize
                    .min, // Makes the dialog box adjust based on its contents
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 26.0, right: 26.0, bottom: 5.0),
                    child: Center(
                      child: const Text(
                        'Παρακαλώ επιλέξτε την ημερομηνία και την ώρα κράτησης',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Date Picker
                      buildOptionListDates(
                        _dateOptions,
                        _selectedDateIndex,
                        (index) => setState(() {
                          _selectedDateIndex = index;
                        }),
                      ),
                      // Time Picker
                      buildOptionList(
                        _timeOptions,
                        _selectedTimeIndex,
                        (index) => setState(() {
                          _selectedTimeIndex = index;
                        }),
                        200,
                        100,
                      ),
                      // Guests Picker
                      buildOptionList(
                        _guestsOptions,
                        _selectedGuestsIndex,
                        (index) => setState(() {
                          _selectedGuestsIndex = index;
                        }),
                        200,
                        150,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _applyChanges();
                          });
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          side: MaterialStateProperty.resolveWith<BorderSide>(
                              (states) {
                            return BorderSide(
                              color: Styles.primaryColor,
                            );
                          }),
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            return Colors.white;
                          }),
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            return Styles.primaryColor;
                          }),
                        ),
                        child: const Text('Εφαρμογή'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          _skipChanges();
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          side: MaterialStateProperty.resolveWith<BorderSide>(
                              (states) {
                            return BorderSide(
                              color: Styles.primaryColor,
                            );
                          }),
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            return Colors.white;
                          }),
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            return Styles.primaryColor;
                          }),
                        ),
                        child: const Text('Παράβλεψη'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  AppBar buildWebAppBar() {
    final bool isMobileWidth = MediaQuery.of(context).size.width < 600;
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.white,
      elevation: 0,
      toolbarHeight: 90,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => {context.goNamed(webHomeScreenNameRoute)},
            child: Image.asset(
              'assets/images/logo.png',
              height: 90,
            ),
          ),
          if (user == null)
            ElevatedButton(
              onPressed: () => _showLoginDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.primaryColor,
                foregroundColor: Styles.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Σύνδεση / Εγγραφή',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Styles.primaryColor,
                    backgroundImage: profilePicUrl.isNotEmpty
                        ? NetworkImage(profilePicUrl)
                        : null,
                    child: profilePicUrl.isEmpty
                        ? const Icon(Icons.person, size: 25)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  AppBar buildMobileAppBar() {
    return AppBar(
      title: const Text('Αγαπημένα'),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.white,
    );
  }

  Widget buildWebLayout() {
    return SingleChildScrollView(
      controller: webScrollViewController,
      child: SizedBox(
        height:
            MediaQuery.of(context).size.height, // Ensure height is constrained
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (value) {
                        searchRestaurants(value);
                      },
                      // controller: editingController,
                      decoration: InputDecoration(
                        labelText: "Αναζήτηση...",
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        prefixIcon: const Icon(Icons.search),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25.0)),
                          borderSide: BorderSide(color: Styles.primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25.0)),
                          borderSide: BorderSide(color: Styles.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showReservationDialog(context);
                    },
                    child: Container(
                      color: Styles.primaryColor,
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_month,
                                      color: Styles.primaryColor),
                                  Text(
                                    _dateOptions[_selectedDateIndex]["date"]
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: Styles.primaryColor),
                                  Text(
                                    _timeOptions[_selectedTimeIndex].toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.people,
                                      color: Styles.primaryColor),
                                  Text(
                                    _guestsOptions[_selectedGuestsIndex]
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: ElevatedButton.icon(
                              onPressed: () {
                                showFilterScreenDialog(
                                    context, _allRestaurants);
                              },
                              icon: const Icon(Icons.filter_alt_rounded),
                              label: const Text('Φίλτρα'),
                              style: ButtonStyle(
                                side: MaterialStateProperty.resolveWith<
                                    BorderSide>((states) {
                                  return BorderSide(
                                    color: Styles.primaryColor,
                                  );
                                }),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (states) {
                                  return Colors.white;
                                }),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (states) {
                                  return Styles.primaryColor;
                                }),
                                textStyle: MaterialStateProperty.resolveWith<
                                    TextStyle>((states) {
                                  return const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  );
                                }),
                              )),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: ElevatedButton.icon(
                              onPressed: () {
                                removeFilters();
                              },
                              icon: const Icon(Icons.cancel_outlined,
                                  color: Colors.red),
                              label: const Text('Φίλτρα'),
                              style: ButtonStyle(
                                side: MaterialStateProperty.resolveWith<
                                    BorderSide>((states) {
                                  return const BorderSide(
                                    color: Colors.red,
                                  );
                                }),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (states) {
                                  return Colors.white;
                                }),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (states) {
                                  return Colors.red;
                                }),
                                textStyle: MaterialStateProperty.resolveWith<
                                    TextStyle>((states) {
                                  return const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  );
                                }),
                              )),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 2,
                    height: 8,
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            controller: scrollViewController,
                            shrinkWrap: true,
                            itemExtent: 200.0,
                            itemCount: restaurants.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  context.pushNamed(
                                    restaurantsDetailedScreenNameRoute,
                                    queryParameters: {
                                      'restaurantId':
                                          restaurants[index]['id'].toString(),
                                    },
                                  );
                                },
                                child: Container(
                                  // width: size.width * 1.0,
                                  height: 200,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  margin: const EdgeInsets.only(
                                    right: 17,
                                    top: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    border: const Border(
                                      top: BorderSide(
                                        color: Color(0xFF0F9B0F),
                                        width: 0.1,
                                        style: BorderStyle.solid,
                                      ),
                                      left: BorderSide(
                                        color: Color(0xFF0F9B0F),
                                        width: 0.1,
                                        style: BorderStyle.solid,
                                      ),
                                      bottom: BorderSide(
                                        color: Color(0xFF0F9B0F),
                                        width: 1.0,
                                        style: BorderStyle.solid,
                                      ),
                                      right: BorderSide(
                                        color: Color(0xFF0F9B0F),
                                        width: 0.1,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 150,
                                        width: 119,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Styles.primaryColor,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              restaurants[index]['mainPhoto'],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Gap(10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Gap(10),
                                          Text(
                                            restaurants[index]['name'],
                                            style: Styles.headLineStyle2
                                                .copyWith(
                                                    color: Styles.textColor),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.location_on_sharp,
                                                size: 25.0,
                                                color: Color(0xFF0F9B0F),
                                              ),
                                              Text(
                                                '${restaurants[index]['Location']['city']}',
                                                style: Styles.headLineStyle2
                                                    .copyWith(
                                                  color: Styles.textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Gap(5),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              RatingBar.builder(
                                                initialRating:
                                                    (restaurants[index]
                                                            ['rating'] as num)
                                                        .toDouble(),
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemSize: 25.0,
                                                itemPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 1.0),
                                                itemBuilder: (context, _) =>
                                                    const Icon(
                                                  Icons.star,
                                                  color: Color(0xFF0F9B0F),
                                                ),
                                                ignoreGestures: true,
                                                onRatingUpdate:
                                                    (double value) {},
                                              ),
                                              const Gap(2),
                                              Text(
                                                '(${(restaurants[index]['rating'] as num).toDouble().toString()})',
                                                style: Styles.headLineStyle2
                                                    .copyWith(
                                                        color:
                                                            Styles.textColor),
                                              ),
                                            ],
                                          ),
                                          const Gap(5),
                                          Text(
                                            restaurants[index]['cuisine'],
                                            style: Styles.headLineStyle3
                                                .copyWith(
                                                    color: Styles.textColor),
                                          ),
                                          const Gap(2),
                                          Text(
                                            restaurants[index]['avgPrice'] +
                                                '€',
                                            style: Styles.headLineStyle1
                                                .copyWith(
                                                    color: Styles.textColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            webFooter(),
          ],
        ),
      ),
    );
  }

  // Widget buildMobileLayout() {
  //   return FutureBuilder<List<Map<String, dynamic>>?>(
  //     future: _favoriteRestData,
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: CircularProgressIndicator());
  //       } else if (snapshot.hasError) {
  //         return Center(child: Text('Error: ${snapshot.error}'));
  //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //         return const Center(child: Text('Δεν υπάρχουν αγαπημένα.'));
  //       } else {
  //         List<Map<String, dynamic>>? favoriteRestaurants = snapshot.data!;
  //         return SingleChildScrollView(
  //           controller: scrollViewController,
  //           child: Column(
  //             children: [
  //               Center(
  //                 child: ConstrainedBox(
  //                   constraints: const BoxConstraints(maxWidth: 600),
  //                   child: ListView.builder(
  //                     controller: scrollViewController,
  //                     shrinkWrap: true,
  //                     itemExtent: 200.0,
  //                     physics: NeverScrollableScrollPhysics(),
  //                     itemCount: favoriteRestaurants.length,
  //                     itemBuilder: (context, index) {
  //                       final restaurants = favoriteRestaurants[index];
  //                       return InkWell(
  //                         onTap: () {
  //                           context.pushNamed(
  //                             restaurantsDetailedScreenNameRoute,
  //                             queryParameters: {
  //                               'restaurantId': restaurants['id'],
  //                             },
  //                           );
  //                         },
  //                         child: Container(
  //                           height: 200,
  //                           padding: const EdgeInsets.symmetric(
  //                               horizontal: 10, vertical: 10),
  //                           margin: const EdgeInsets.only(
  //                               right: 17,
  //                               top: 5,
  //                               left: 17), // Adjust margins as needed
  //                           decoration: BoxDecoration(
  //                             border: const Border(
  //                               top: BorderSide(
  //                                 color: Color(0xFF0F9B0F),
  //                                 width: 0.1,
  //                                 style: BorderStyle.solid,
  //                               ),
  //                               left: BorderSide(
  //                                 color: Color(0xFF0F9B0F),
  //                                 width: 0.1,
  //                                 style: BorderStyle.solid,
  //                               ),
  //                               bottom: BorderSide(
  //                                 color: Color(0xFF0F9B0F),
  //                                 width: 1.0,
  //                                 style: BorderStyle.solid,
  //                               ),
  //                               right: BorderSide(
  //                                 color: Color(0xFF0F9B0F),
  //                                 width: 0.1,
  //                                 style: BorderStyle.solid,
  //                               ),
  //                             ),
  //                             borderRadius: BorderRadius.circular(24),
  //                           ),
  //                           child: Stack(
  //                             children: [
  //                               Row(
  //                                 children: [
  //                                   Container(
  //                                     height: 150,
  //                                     width: 119,
  //                                     decoration: BoxDecoration(
  //                                       borderRadius: BorderRadius.circular(12),
  //                                       color: Styles.primaryColor,
  //                                       image: DecorationImage(
  //                                         fit: BoxFit.cover,
  //                                         image: NetworkImage(
  //                                             restaurants['data']['mainPhoto']),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   const Gap(10),
  //                                   SizedBox(
  //                                     width: 170,
  //                                     child: Column(
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.start,
  //                                       children: [
  //                                         const Gap(10),
  //                                         Text(
  //                                           restaurants['data']['name'] ??
  //                                               'Unknown',
  //                                           style: Styles.headLineStyle2
  //                                               .copyWith(
  //                                                   color: Styles.textColor),
  //                                         ),
  //                                         Row(
  //                                           crossAxisAlignment:
  //                                               CrossAxisAlignment.start,
  //                                           children: [
  //                                             const Icon(
  //                                               Icons.location_on_sharp,
  //                                               size: 25.0,
  //                                               color: Color(0xFF0F9B0F),
  //                                             ),
  //                                             Text(
  //                                               favoriteRestaurants[index]
  //                                                           ['data']['Location']
  //                                                       ?['city'] ??
  //                                                   'Unknown',
  //                                               style: Styles.headLineStyle2
  //                                                   .copyWith(
  //                                                       color:
  //                                                           Styles.textColor),
  //                                             ),
  //                                           ],
  //                                         ),
  //                                         const Gap(5),
  //                                         RatingBar.builder(
  //                                           initialRating:
  //                                               (favoriteRestaurants[index]
  //                                                           ['data']['rating']
  //                                                       as num)
  //                                                   .toDouble(),
  //                                           minRating: 1,
  //                                           direction: Axis.horizontal,
  //                                           allowHalfRating: true,
  //                                           itemCount: 5,
  //                                           itemSize: 25.0,
  //                                           itemPadding: EdgeInsets.symmetric(
  //                                               horizontal: 1.0),
  //                                           itemBuilder: (context, _) =>
  //                                               const Icon(
  //                                             Icons.star,
  //                                             color: Color(0xFF0F9B0F),
  //                                           ),
  //                                           ignoreGestures: true,
  //                                           onRatingUpdate: (double value) {},
  //                                         ),
  //                                         const Gap(8),
  //                                         Text(
  //                                           restaurants['data']['avgPrice'] !=
  //                                                   null
  //                                               ? '${restaurants['data']['avgPrice']}€'
  //                                               : 'Unknown',
  //                                           style: Styles.headLineStyle1
  //                                               .copyWith(
  //                                                   color: Styles.textColor),
  //                                         ),
  //                                         Text(
  //                                           restaurants['data']['cuisine'] ??
  //                                               'Unknown',
  //                                           style: Styles.headLineStyle3
  //                                               .copyWith(
  //                                                   color: Styles.textColor),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ),
  //               if (kIsWeb) webFooter(),
  //             ],
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: buildWebAppBar(),
        endDrawer: user != null
            ? CustomDrawer(
                displayName: displayName, profilePicUrl: profilePicUrl)
            : null,
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return buildWebLayout();
            } else {
              return buildWebLayout();
              // return buildMobileLayout();
            }
          },
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: buildMobileAppBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return buildWebLayout();
            } else {
              return buildWebLayout();
              // return buildMobileLayout();
            }
          },
        ),
      );
    }
  }

  Widget buildOptionList(
      List<dynamic> options,
      int selectedIndex,
      void Function(int) onOptionSelected,
      double contHeight,
      double contWidth) {
    ScrollController scrollController = ScrollController();
    return SizedBox(
      height: contHeight,
      width: contWidth,
      child: ListView.builder(
        controller: scrollController,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final optionValue = options[index];
          return GestureDetector(
            onTap: () {
              debouncer.run(() {
                setState(() {
                  onOptionSelected(index);
                });

                if (scrollController.hasClients) {
                  // Calculate the offset to scroll the selected item to the center
                  final offset = (index * 44) -
                      (scrollController.position.viewportDimension / 2) +
                      (4 / 2);
                  // Scroll to the calculated offset with animation
                  scrollController.animateTo(offset,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: index == selectedIndex
                        ? Styles.primaryColor
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Center(
                child: Text(
                  optionValue.toString(),
                  style: TextStyle(
                    color: index == selectedIndex ? Colors.black : Colors.black,
                    fontSize: 18.0,
                    fontWeight: index == selectedIndex
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildOptionListDates(List<Map<String, dynamic>> options,
      int selectedIndex, void Function(int) onOptionSelected) {
    ScrollController scrollController = ScrollController();
    return SizedBox(
      height: 200,
      width: 150,
      child: ListView.builder(
        controller: scrollController,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final optionValue = options[index]['date'];
          return GestureDetector(
            onTap: () {
              debouncer.run(() {
                setState(() {
                  onOptionSelected(index);
                });

                if (scrollController.hasClients) {
                  // Calculate the offset to scroll the selected item to the center
                  final offset = (index * 44) -
                      (scrollController.position.viewportDimension / 2) +
                      (4 / 2);
                  // Scroll to the calculated offset with animation
                  scrollController.animateTo(offset,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: index == selectedIndex
                        ? Styles.primaryColor
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Center(
                child: Text(
                  optionValue.toString(),
                  style: TextStyle(
                    color: index == selectedIndex ? Colors.black : Colors.black,
                    fontSize: 18.0,
                    fontWeight: index == selectedIndex
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
