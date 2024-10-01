import 'dart:convert';
import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/widgets/customDrawer.dart';
import 'package:bookingapp/widgets/login_dialog.dart';
import 'package:bookingapp/screens/restaurants_screen.dart';
import 'package:bookingapp/utils/AppLayout.dart';
import 'package:bookingapp/utils/AppStyles.dart';
import 'package:bookingapp/widgets/webFooter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bookingapp/services/databaseFunctions.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WebHomeScreen extends StatefulWidget {
  const WebHomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<WebHomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? locationData;
  Map<String, Object> selectedLocation = {};
  String profilePicUrl = '';
  String displayName = '';
  final TextEditingController _peopleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> restaurants = [];
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  FocusNode _focusNode = FocusNode();
  bool _showDropdown = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    _scrollController = ScrollController();
    _scrollController2 = ScrollController();
    getDatabaseData();
  }

  Future<void> loadUserData() async {
    try {
      if (user == null) {
        print("User is null");
        return;
      }

      Map<String, dynamic>? userData =
          await databaseFunctions().getUserData(user!.uid);

      print(userData);

      final String? userPhotoURL = user!.photoURL;
      final String? userDisplayName = user!.displayName;

      setState(() {
        profilePicUrl = userPhotoURL ?? '';
        displayName = userDisplayName ??
            (userData != null
                ? '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
                : '');
      });
    } catch (e) {
      // Handle any exceptions
      print("Error loading user data: $e");
    }
  }

  void _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = 'http://localhost:3000/places?input=$query';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(data['predictions']);
        });
      } else {
        //  non-200 responses
        print('Failed to load predictions: ${response.statusCode}');
      }
    } catch (e) {
      //  errors
      print('Failed to load predictions: $e');
    }

    setState(() {
      _isLoading = false;
    });
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        if (query.isEmpty) {
          _searchResults = [];
        }
        _showDropdown = _searchResults.isNotEmpty;
      });
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ScrollController _scrollController;
  late ScrollController _scrollController2;
  String _selectedTime = '10:00';

  final List<String> _timeSlots = [
    for (int hour = 10; hour <= 23; hour++)
      for (int minute = 0; minute < 60; minute += 30)
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}'
  ];

  Future<void> getDatabaseData() async {
    restaurants = await databaseFunctions.getFromFirebaseAll();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _selectDate(BuildContext context, RenderBox renderBox) async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: today,
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Styles.primaryColor,
            hintColor: Styles.primaryColor,
            colorScheme: ColorScheme.light(
              primary: Styles.primaryColor,
            ),
          ),
          child: Transform.translate(
            offset: Offset(0, renderBox.localToGlobal(Offset.zero).dy),
            child: child!,
          ),
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _getPlaceDetails(String placeId) async {
    final url = 'http://localhost:3000/place?input=$placeId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic> result = data['result'];
        locationData = result;
        final List<dynamic> addressComponents = result['address_components'];
        setLocationData(locationData);
        String postalCode = '';
        for (var component in addressComponents) {
          final List<dynamic> types = component['types'];
          if (types.contains('postal_code')) {
            postalCode = component['long_name'];
            break;
          }
        }
        final Map<String, dynamic> geometry = result['geometry'];
        final Map<String, dynamic> location = geometry['location'];
        final double lat = location['lat'];
        final double lng = location['lng'];
        final String name = result['name'];
        final String formattedAddress = result['formatted_address'];

        final List<String> selectedLocation = [
          name,
          formattedAddress,
          lat.toString(),
          lng.toString(),
          postalCode,
        ];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('selectedLocation', selectedLocation);
        setState(() {
          _searchController.text = result['name'];
          _showDropdown = false;
        });
      } else {
        //  non-200 responses
      }
    } catch (e) {
      //  errors
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

  void _onLoginSuccess() {
    if (user == null) {
      setState(() {
        context.pushReplacementNamed(webHomeScreenNameRoute);
      });
    }
  }

  Future<void> setLocationData(Map<String, dynamic>? selectedLocation) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('selectedLocation', [
      selectedLocation!['name'].toString(),
      selectedLocation!['formatted_address'].toString(),
      selectedLocation['lat'].toString(),
      selectedLocation['lng'].toString(),
      selectedLocation['postal_code'].toString(),
    ]);
    print(prefs.getStringList('selectedLocation') ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 1280;
    final isMediumScreen = MediaQuery.of(context).size.width > 900 &&
        MediaQuery.of(context).size.width < 1200;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 90,
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
      ),
      endDrawer: user != null
          ? CustomDrawer(displayName: displayName, profilePicUrl: profilePicUrl)
          : null,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: isSmallScreen
                        ? const EdgeInsets.only(left: 10.0, right: 10.0)
                        : const EdgeInsets.only(left: 350.0, right: 350.0),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          image: const DecorationImage(
                            image: AssetImage('assets/images/Bg-image.png'),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 8,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: isSmallScreen
                              ? double.infinity
                              : MediaQuery.of(context).size.width,
                          maxHeight: isSmallScreen ? double.infinity : 400,
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Βρείτε το τραπέζι σας για κάθε περίσταση',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            isSmallScreen
                                ? buildColumnInputs()
                                : buildRowInputs(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(55),
                  Center(
                    child: Column(
                      children: [
                        const Gap(15),
                        Container(
                          padding: isSmallScreen
                              ? const EdgeInsets.only(left: 10.0, right: 10.0)
                              : const EdgeInsets.only(left: 0, right: 0),
                          width: isSmallScreen
                              ? AppLayout.getScreenWidth(context)
                              : AppLayout.getScreenWidth(context) / 2,
                          height: 400,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Δημοφιλή εστιατόρια',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back_ios),
                                        onPressed: () {
                                          _scrollController.animateTo(
                                            _scrollController.offset - 515,
                                            duration:
                                                Duration(milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon:
                                            const Icon(Icons.arrow_forward_ios),
                                        onPressed: () {
                                          _scrollController.animateTo(
                                            _scrollController.offset + 515,
                                            duration:
                                                Duration(milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _scrollController,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: restaurants
                                      .map((singleRestaurant) => Stack(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10, left: 5),
                                                child: SizedBox(
                                                  width: 250,
                                                  height: 360,
                                                  child: restaurantsTile(
                                                      restaurant:
                                                          singleRestaurant),
                                                ),
                                              ),
                                            ],
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(20),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        const Gap(15),
                        Container(
                          padding: isSmallScreen
                              ? const EdgeInsets.only(left: 10.0, right: 10.0)
                              : const EdgeInsets.only(left: 0, right: 0),
                          width: isSmallScreen
                              ? AppLayout.getScreenWidth(context)
                              : AppLayout.getScreenWidth(context) / 2,
                          height: 400,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Δημοφιλή εστιατόρια',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back_ios),
                                        onPressed: () {
                                          _scrollController2.animateTo(
                                            _scrollController2.offset -
                                                MediaQuery.of(context)
                                                    .size
                                                    .width,
                                            duration:
                                                Duration(milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon:
                                            const Icon(Icons.arrow_forward_ios),
                                        onPressed: () {
                                          _scrollController2.animateTo(
                                            _scrollController2.offset +
                                                MediaQuery.of(context)
                                                    .size
                                                    .width,
                                            duration:
                                                Duration(milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _scrollController2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: restaurants
                                      .map((singleRestaurant) => Stack(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10, left: 5),
                                                child: SizedBox(
                                                  width: 250,
                                                  height: 360,
                                                  child: restaurantsTile(
                                                      restaurant:
                                                          singleRestaurant),
                                                ),
                                              ),
                                            ],
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(20),
                      ],
                    ),
                  ),
                  webFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildColumnInputs() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 56.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Τοποθεσία',
                  prefixIcon: Icon(Icons.location_on),
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
                onChanged: (value) {
                  _searchLocation(value);
                },
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                _selectDate(context, renderBox);
              },
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: DateFormat('dd-MM-yyyy').format(_selectedDate),
                    prefixIcon: const Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedTime,
              menuMaxHeight: 200,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTime = newValue!;
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.access_time),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              dropdownColor: Colors.white,
              items: _timeSlots.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  alignment: Alignment.center,
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 56.0,
              child: ElevatedButton(
                onPressed: () {
                  final String location = _searchController.text;
                  final String date =
                      DateFormat('dd-MM-yyyy').format(_selectedDate);
                  final String time = _selectedTime ?? '';
                  final int people = int.tryParse(_peopleController.text) ?? 1;
                  context.pushNamed(webSearchNameRoute,
                      queryParameters: {
                        'date': date,
                        'time': time,
                        'people': people.toString(),
                      },
                      extra: locationData);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Styles.secondaryColor,
                  backgroundColor: Styles.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(color: Colors.black),
                ),
                child: const Text('Αναζήτηση'),
              ),
            ),
          ],
        ),
        if (_showDropdown)
          Positioned(
            left: 0,
            right: 0,
            top: 50,
            child: Material(
              elevation: 4.0,
              child: Container(
                height: 200.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final prediction = _searchResults[index];
                          return Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                top: BorderSide(color: Colors.black),
                                right: BorderSide(color: Colors.black),
                                left: BorderSide(color: Colors.black),
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.location_on,
                                  color: Styles.primaryColor),
                              title: Text(prediction['description']),
                              onTap: () {
                                _getPlaceDetails(prediction['place_id']);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildRowInputs() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                height: 56.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Τοποθεσία',
                    prefixIcon: Icon(Icons.location_on),
                    filled: true,
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hoverColor: Colors.transparent,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  ),
                  onChanged: (value) {
                    _searchLocation(value);
                  },
                ),
              ),
              if (_showDropdown)
                Container(
                  height: 200,
                  child: Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Material(
                      elevation: 4.0,
                      child: Container(
                        height: 200.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : ListView.builder(
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final prediction = _searchResults[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Styles.primaryColor),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Icon(Icons.location_on,
                                          color: Styles.primaryColor),
                                      title: Text(prediction['description']),
                                      onTap: () {
                                        _getPlaceDetails(
                                            prediction['place_id']);
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              RenderBox renderBox = context.findRenderObject() as RenderBox;
              _selectDate(context, renderBox);
            },
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  labelText: DateFormat('dd-MM-yyyy').format(_selectedDate),
                  prefixIcon: const Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: Colors.white,
                  border:
                      const OutlineInputBorder(borderRadius: BorderRadius.zero),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedTime,
            menuMaxHeight: 500,
            onChanged: (String? newValue) {
              setState(() {
                _selectedTime = newValue!;
              });
            },
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.access_time),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.zero),
            ),
            dropdownColor: Colors.white,
            items: _timeSlots.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                alignment: AlignmentDirectional.bottomEnd,
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        SizedBox(
          height: 56.0,
          child: ElevatedButton(
            onPressed: () {
              final String location = _searchController.text;
              final String date =
                  DateFormat('dd-MM-yyyy').format(_selectedDate);
              final String time = _selectedTime ?? '';

              context.pushNamed(webSearchNameRoute,
                  queryParameters: {
                    'date': date,
                    'time': time,
                  },
                  extra: locationData);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Styles.secondaryColor,
              backgroundColor: Styles.primaryColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.zero,
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.circular(15),
                ),
              ),
              side: BorderSide(color: Colors.black),
            ),
            child: const Text('Αναζήτηση'),
          ),
        ),
      ],
    );
  }

  Widget buildInputField(
    String labelText,
    TextEditingController controller,
    IconData icon, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        prefixIconColor:
            MaterialStateColor.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.focused)) {
            return Styles.primaryColor;
          }
          return Colors.black;
        }),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFirst ? 15 : 0),
            bottomLeft: Radius.circular(isFirst ? 15 : 0),
            topRight: Radius.circular(isLast ? 15 : 0),
            bottomRight: Radius.circular(isLast ? 15 : 0),
          ),
        ),
      ),
    );
  }
}

Widget buildInputFieldColumn(
  String labelText,
  TextEditingController controller,
  IconData icon,
) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon),
      prefixIconColor:
          MaterialStateColor.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.focused)) {
          return Styles.primaryColor;
        }
        return Colors.black;
      }),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  );
}
