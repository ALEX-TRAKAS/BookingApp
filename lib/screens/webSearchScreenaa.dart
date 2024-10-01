import 'package:bookingapp/screens/filterScreen.dart';
import 'package:bookingapp/services/databaseFunctions.dart';
import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/utils/debouncer.dart';
import 'package:bookingapp/widgets/webFooter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/appstyles.dart';
import 'package:gap/gap.dart';
import '../utils/filteringFunctions.dart';

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
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<webSearchScreen> {
  TextEditingController editingController = TextEditingController();
  ScrollController scrollViewController = ScrollController();
  bool isVisible = false;
  bool isLoading = false;
  bool isLoadingFlag = false;
  bool _buttonPressed = true;
  bool isContainerPressed = false;
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

  @override
  void initState() {
    if (mounted) {
      super.initState();
      locationData();
      print('Init state of SearchScreen called.');
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

    print(widget.locationData);
  }

  @override
  void dispose() {
    editingController.dispose();
    scrollViewController.dispose();
    super.dispose();
  }

  Future<void> getFromFirebase(String postalCode) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
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
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void searchRestaurants(String query) {
    if (mounted) {
      setState(() {
        if (query.isEmpty) {
          // If the query is empty, show all restaurants
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

  void locationData() async {
    final Map<String, dynamic>? data = widget.locationData;
    final List<dynamic> addressComponents = data!['address_components'];
    print(data['address_components']);

    for (var component in addressComponents) {
      final List<dynamic> types = component['types'];
      if (types.contains('postal_code')) {
        postalCode = component['long_name'];
        break;
      }
      print("postalCode:" + postalCode);
    }

    final Map<String, dynamic> geometry = data['geometry'];
    final Map<String, dynamic> location = geometry['location'];
    lat = location['lat'];
    lng = location['lng'];
    name = data['name'];
    final String formattedAddress = data['formatted_address'];

    getFromFirebase(postalCode);
    print(
        'Name: $name, Formatted Address: $formattedAddress, Latitude: $lat, Longitude: $lng, Postal Code: $postalCode');
  }

  void _skipChanges() {
    setState(() {
      _buttonPressed = !_buttonPressed;
    });
    updateRestaurants(_allRestaurants);
  }

  void handleContainerPress() {
    setState(() {
      isContainerPressed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isContainerPressed) {
      // Reset the flag to false after rebuilding the widget
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          isContainerPressed = false;
          isLoadingFlag = true;
          _buttonPressed = false;
        });
      });
    }

    isLoadingFlag = true;
    return Scaffold(
      backgroundColor: Colors.white,
      drawerScrimColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (!kIsWeb)
              Visibility(
                visible: !_buttonPressed,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        enabled: false,
                        controller: editingController,
                        decoration: InputDecoration(
                          labelText: "Αναζήτηση...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(25.0)),
                            borderSide: BorderSide(
                              color: Styles.primaryColor,
                              width: 3.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.filter_alt_rounded),
                          label: const Text('Φίλτρα'),
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Visibility(
                      visible: !_buttonPressed,
                      child: const Padding(
                        padding: EdgeInsets.only(
                            left: 26.0, right: 26.0, bottom: 5.0),
                        child: Center(
                          child: Text(
                            'Παρακαλώ επιλέξτε την ημερομηνία και την ώρα κράτησης',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !_buttonPressed,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildOptionListDates(
                            _dateOptions,
                            _selectedDateIndex,
                            (index) => _selectedDateIndex = index,
                          ),
                          buildOptionList(
                            _timeOptions,
                            _selectedTimeIndex,
                            (index) => _selectedTimeIndex = index,
                            200,
                            100,
                          ),
                          buildOptionList(
                            _guestsOptions,
                            _selectedGuestsIndex,
                            (index) => _selectedGuestsIndex = index,
                            200,
                            150,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _buttonPressed,
                      child: buildFilteredList(context),
                    ),
                    const Gap(20),
                    Visibility(
                      visible: !_buttonPressed,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _applyChanges();
                                _buttonPressed = !_buttonPressed;
                              });
                            },
                            style: ButtonStyle(
                              side:
                                  MaterialStateProperty.resolveWith<BorderSide>(
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
                            onPressed: _skipChanges,
                            style: ButtonStyle(
                              side:
                                  MaterialStateProperty.resolveWith<BorderSide>(
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilteredList(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                searchRestaurants(value);
              },
              controller: editingController,
              decoration: InputDecoration(
                labelText: "Αναζήτηση...",
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                prefixIcon: const Icon(Icons.search),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                  borderSide: BorderSide(color: Styles.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                  borderSide: BorderSide(color: Styles.primaryColor),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              handleContainerPress();
            },
            child: Container(
              color: Styles.primaryColor,
              // decoration: BoxDecoration(
              //   color: Styles.primaryColor,
              //   border: Border.all(
              //     color: Styles.primaryColor,
              //     width: 2.0,
              //   ),
              // ),
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
                            _dateOptions[_selectedDateIndex]["date"].toString(),
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
                          Icon(Icons.access_time, color: Styles.primaryColor),
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
                          Icon(Icons.people, color: Styles.primaryColor),
                          Text(
                            _guestsOptions[_selectedGuestsIndex].toString(),
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
                        showFilterScreenDialog(context, _allRestaurants);
                      },
                      icon: const Icon(Icons.filter_alt_rounded),
                      label: const Text('Φίλτρα'),
                      style: ButtonStyle(
                        side: MaterialStateProperty.resolveWith<BorderSide>(
                            (states) {
                          return BorderSide(
                            color: Styles.primaryColor,
                          );
                        }),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
                          return Colors.white;
                        }),
                        foregroundColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
                          return Styles.primaryColor;
                        }),
                        textStyle: MaterialStateProperty.resolveWith<TextStyle>(
                            (states) {
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
                      icon:
                          const Icon(Icons.cancel_outlined, color: Colors.red),
                      label: const Text('Φίλτρα'),
                      style: ButtonStyle(
                        side: MaterialStateProperty.resolveWith<BorderSide>(
                            (states) {
                          return const BorderSide(
                            color: Colors.red,
                          );
                        }),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
                          return Colors.white;
                        }),
                        foregroundColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
                          return Colors.red;
                        }),
                        textStyle: MaterialStateProperty.resolveWith<TextStyle>(
                            (states) {
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
                                  borderRadius: BorderRadius.circular(12),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Gap(10),
                                  Text(
                                    restaurants[index]['name'],
                                    style: Styles.headLineStyle2
                                        .copyWith(color: Styles.textColor),
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
                                        style: Styles.headLineStyle2.copyWith(
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
                                        initialRating: (restaurants[index]
                                                ['rating'] as num)
                                            .toDouble(),
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 25.0,
                                        itemPadding: const EdgeInsets.symmetric(
                                            horizontal: 1.0),
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Color(0xFF0F9B0F),
                                        ),
                                        ignoreGestures: true,
                                        onRatingUpdate: (double value) {},
                                      ),
                                      const Gap(2),
                                      Text(
                                        '(${(restaurants[index]['rating'] as num).toDouble().toString()})',
                                        style: Styles.headLineStyle2
                                            .copyWith(color: Styles.textColor),
                                      ),
                                    ],
                                  ),
                                  const Gap(5),
                                  Text(
                                    restaurants[index]['cuisine'],
                                    style: Styles.headLineStyle3
                                        .copyWith(color: Styles.textColor),
                                  ),
                                  const Gap(2),
                                  Text(
                                    restaurants[index]['avgPrice'] + '€',
                                    style: Styles.headLineStyle1
                                        .copyWith(color: Styles.textColor),
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
          if (kIsWeb) webFooter(),
        ],
      ),
    );
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
                  final offset = (index * 44) -
                      (scrollController.position.viewportDimension / 2) +
                      (4 / 2);
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
                  final offset = (index * 44) -
                      (scrollController.position.viewportDimension / 2) +
                      (4 / 2);

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
