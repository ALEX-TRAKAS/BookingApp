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
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import '../widgets/double_text_widget.dart';
import 'package:bookingapp/widgets/circle_box.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String concatenatedLocation = '';
  Map<String, dynamic>? lastSavedLocation;
  final User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> restaurants = [];
  Map<String, dynamic>? userData;
  String profilePicUrl = '';
  int counter = 0;

  @override
  void initState() {
    print('Init state of HomeScreen called.');
    getDatabaseData();
    if (mounted) {
      super.initState();
    }
    // if (lastSavedLocation == null) {
    //   _getCurrentLocation();
    // }
    // showLocation();
  }

  Future<void> getDatabaseData() async {
    print('User Data: $userData');
    userData = await databaseFunctions.getUserData(user!.uid);
    print(user!.uid);
    print('User Data: $userData');
    profilePicUrl = userData?['photoURL'];
    restaurants = await databaseFunctions.getFromFirebase();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Limiting to the first result if available
      if (placemarks.isNotEmpty) {
        Placemark firstPlacemark = placemarks.first;
        // Save the last known location
        await _saveLastKnownLocation(
            position.latitude,
            position.longitude,
            firstPlacemark.country,
            firstPlacemark.locality,
            firstPlacemark.street);
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _saveLastKnownLocation(double latitude, double longitude,
      String? country, String? city, String? address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('last_latitude', latitude);
    prefs.setDouble('last_longitude', longitude);
    prefs.setString('Country', country!);
    prefs.setString('City', city!);
    prefs.setString('Address', address!);
  }

  Future<Map<String, dynamic>?> _getLastKnownLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? latitude = prefs.getDouble('last_latitude');
    double? longitude = prefs.getDouble('last_longitude');
    String? country = prefs.getString('Country');
    String? city = prefs.getString('City');
    String? address = prefs.getString('Address');

    if (latitude != null &&
        longitude != null &&
        country != null &&
        city != null &&
        address != null) {
      return {
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        'city': city,
        'address': address,
      };
    } else {
      return null; // Return null if any of the values are missing
    }
  }

  void showLocation() async {
    Map<String, dynamic>? lastKnownLocation = await _getLastKnownLocation();
    if (lastKnownLocation != null) {
      lastSavedLocation = lastKnownLocation;
    } else {
      // Handle case where last known location is not available
      print('no geo coords');
    }
    print('Latitude: ' + lastSavedLocation!['latitude'].toString());
    print('Longitude:' + lastSavedLocation!['longitude'].toString());
    print('Country:' + lastSavedLocation?['country']);
    print('City:' + lastSavedLocation?['city']);
    print('Address:' + lastSavedLocation?['address']);
    concatenatedLocation = (lastSavedLocation?['country'] ?? '') +
        (lastSavedLocation?['city'] ?? '') +
        (lastSavedLocation?['address'] ?? '');
    print('Concatenated Location: $concatenatedLocation');
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
                              Text(
                                'Κάνε κράτηση',
                                style: Styles.headLineStyle1,
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            backgroundImage: profilePicUrl.isNotEmpty
                                ? NetworkImage(profilePicUrl)
                                : null,
                          ),
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
                      const Gap(25),
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
                                  decoration: const InputDecoration(
                                      labelText: "Αναζήτηση...",
                                      hintText: "Αναζήτηση...",
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25.0)))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(40),
                      const AppDoubleTextWidget(
                        bigText: 'Κουζίνες',
                        smallText: '',
                      )
                    ],
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
                          .toList()),
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
                  padding: const EdgeInsets.only(
                    left: 20,
                    bottom: 20,
                  ),
                  child: Column(
                      children: restaurants
                          .map((singleRestaurant) =>
                              restaurantsTileWide(restaurant: singleRestaurant))
                          .toList()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
