import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/screens/restaurants_screen.dart';
import 'package:bookingapp/screens/restaurantsTileWide.dart';
import 'package:bookingapp/services/databaseFunctions.dart';
import 'package:bookingapp/utils/AppInfoList.dart';
import 'package:bookingapp/utils/AppStyles.dart';
import 'package:bookingapp/widgets/UserData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/double_text_widget.dart';
import 'package:bookingapp/widgets/circle_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? lastSavedLocation;
  Map<String, Object> selectedLocation = {};

  final User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> restaurants = [];
  Map<String, dynamic>? userData;
  String profilePicUrl = '';
  int counter = 0;
  bool isLocationSelected = false;
  bool homeInputFlag = false;

  @override
  void initState() {
    loadLocationData();
    print('Init state of HomeScreen called.');
    if (mounted) {
      super.initState();
    }
  }

  Future<void> getDatabaseData(String postalCode) async {
    restaurants =
        await databaseFunctions.getFromFirebase(postalCode.replaceAll(' ', ''));
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> setLocationData(Map<String, Object> selectedLocation) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('selectedLocation', [
      selectedLocation['name'].toString(),
      selectedLocation['formatted_address'].toString(),
      selectedLocation['lat'].toString(),
      selectedLocation['lng'].toString(),
      selectedLocation['postal_code'].toString(),
    ]);
    print(prefs.getStringList('selectedLocation') ?? []);
  }

  Future<void> loadLocationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? locationData = prefs.getStringList('selectedLocation');
    if (locationData != null && locationData.length >= 4) {
      selectedLocation = {
        'name': locationData[0],
        'formatted_address': locationData[1],
        'lat': double.parse(locationData[2]),
        'lng': double.parse(locationData[3]),
        'postal_code': locationData[4],
      };
      isLocationSelected = true;
      homeInputFlag = true;
      print("postal code to getdata:");
      getDatabaseData(locationData[4]);
    } else {
      // Handle the case where the data is not available or incomplete
      print('Error: Could not retrieve location data from SharedPreferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserData(
      userId: user!.uid,
      restaurants: restaurants,
      profilePicUrl: profilePicUrl,
      child: PopScope(
        canPop: false,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const Gap(40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Styles.primaryColor,
                                    width: 2.0,
                                  ),
                                ),
                                padding: const EdgeInsets.all(3.0),
                                child: Row(
                                  children: [
                                    IconButton(
                                      iconSize: 30,
                                      icon: Icon(Icons.location_on,
                                          color: Styles
                                              .primaryColor), // Change location icon
                                      onPressed: () async {
                                        final selectedLocation =
                                            await context.pushNamed(
                                                    locationSearchScreenNameRoute)
                                                as Map<String, Object>?;

                                        if (selectedLocation != null) {
                                          print('selected location name :');
                                          print(selectedLocation['name']);
                                          setState(() {
                                            isLocationSelected = true;
                                            homeInputFlag = true;
                                            setLocationData(selectedLocation);
                                          });
                                          loadLocationData();
                                        }
                                      },
                                    ),
                                    Text(
                                      selectedLocation.isNotEmpty
                                          ? '${selectedLocation['formatted_address']!}'
                                          : 'Παρακαλώ επιλέξτε πρώτα τοποθεσία',
                                      // style: Styles.headLineStyle1,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Κάνε κράτηση',
                                style: Styles.headLineStyle1,
                              ),
                            ],
                          ),
                          // CircleAvatar(
                          //   radius: 40,
                          //   backgroundColor: Styles.primaryColor,
                          //   backgroundImage: profilePicUrl.isNotEmpty
                          //       ? NetworkImage(profilePicUrl)
                          //       : null,
                          //   child: profilePicUrl == ''
                          //       ? const Icon(Icons.person, size: 45)
                          //       : null,
                          // ),
                          // Container(
                          //   width: 70,
                          //   height: 70,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(10),
                          //     image: DecorationImage(
                          //         fit: BoxFit.cover,
                          //         image: NetworkImage(profilePicUrl)),
                          //   ),
                          // ),
                        ],
                      ),
                      if (isLocationSelected) const Gap(25),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  onChanged: (_) {
                                    context.pushNamed(
                                      homeSearchNameRoute,
                                    );
                                  },
                                  onTap: () {
                                    context.pushNamed(homeSearchNameRoute);
                                  },
                                  decoration: InputDecoration(
                                      enabled: homeInputFlag,
                                      labelText: "Αναζήτηση...",
                                      hintText: "Αναζήτηση...",
                                      prefixIcon: const Icon(Icons.search),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25.0)))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLocationSelected)
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'Παρακαλώ επιλέξτε πρώτα τοποθεσία',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (isLocationSelected)
                  Column(
                    children: [
                      const Gap(40),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const AppDoubleTextWidget(
                          bigText: 'Κουζίνες',
                          smallText: '',
                        ),
                      ),
                      const Gap(15),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                            children: circleBox
                                .map((singleCircle) =>
                                    circle_box(circle: singleCircle))
                                .toList()),
                      ),
                      const Gap(15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const AppDoubleTextWidget(
                          bigText: 'Κοντινά',
                          smallText: 'Προβολή όλων',
                        ),
                      ),
                      const Gap(15),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          children: restaurants
                              .map((singleRestaurant) =>
                                  restaurantsTile(restaurant: singleRestaurant))
                              .toList(),
                        ),
                      ),
                      const Gap(15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const AppDoubleTextWidget(
                          bigText: 'Προτεινόμενα μέρη',
                          smallText: 'Προβολή όλων',
                        ),
                      ),
                      const Gap(15),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.only(left: 20, bottom: 20),
                        child: Column(
                          children: restaurants
                              .map((singleRestaurant) => restaurantsTileWide(
                                  restaurant: singleRestaurant))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
