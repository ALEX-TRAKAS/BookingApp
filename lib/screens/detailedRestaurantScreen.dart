import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/services/databaseFunctions.dart';
import 'package:bookingapp/widgets/circleButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetailedRestaurantScreen extends StatefulWidget {
  final String? restaurantId;

  DetailedRestaurantScreen({Key? key, this.restaurantId}) : super(key: key);

  @override
  _DetailedRestaurantScreenState createState() =>
      _DetailedRestaurantScreenState();
}

class _DetailedRestaurantScreenState extends State<DetailedRestaurantScreen> {
  late Future<Map<String, dynamic>>? _restaurantData;
  late Future<bool>? isFavorite;
  final db = databaseFunctions();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _restaurantData = _init();
    isFavorite = db.isFavoriteRestaurant(user!.uid, widget.restaurantId!);
    print(isFavorite);
  }

  Future<Map<String, dynamic>> _init() async {
    try {
      final data =
          await databaseFunctions.getRestaurantData(widget.restaurantId) ?? {};
      print('Restaurant data: $data'); // Add this line
      return data;
    } catch (e) {
      // Handle errors
      print('Error loading restaurant data: $e');
      return {};
    }
  }

  Future<void> _toggleFavorite(String restaurantId) async {
    try {
      final isFavorite = await db.isFavoriteRestaurant(user!.uid, restaurantId);

      if (isFavorite) {
        await db.removeFavoriteRestaurant(user!.uid, restaurantId);
        isFavorite == false;
        print(isFavorite);
      } else {
        await db.addFavoriteRestaurant(user!.uid, restaurantId);
      }

      setState(() {});
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Widget build(BuildContext context) {
    if (_restaurantData == null) {
      // Handle the case where data is not available yet, e.g., show a loading indicator
      return CircularProgressIndicator();
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0, // Remove the shadow
          leading: CircleIconButton(
            icon: Icons.arrow_back,
            onPressed: () {
              GoRouter.of(context).pop();
            },
            iconColor: Colors.amber,
          ),
          actions: <Widget>[
            CircleIconButton(
              icon: Icons.bookmark,
              iconColor: isFavorite == true ? Colors.red : Colors.blue,
              onPressed: () {
                _toggleFavorite(widget.restaurantId!);
              },
            ),
          ],
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _restaurantData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Data is still loading
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // An error occurred
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data == null) {
              // No data available
              return Text('No restaurant data available');
            } else {
              // Data has been loaded successfully
              Map<String, dynamic> restaurantData = snapshot.data!;
              final openingHours = restaurantData['openingHours'];
              final days = [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday'
              ];
              final formattedOpeningHours = days
                  .where((day) =>
                      openingHours[day.toLowerCase()]['isOpen'] == true)
                  .map((day) {
                final startTime = openingHours[day.toLowerCase()]['startTime'];
                final endTime = openingHours[day.toLowerCase()]['endTime'];
                return '$day: $startTime - $endTime';
              }).join('\n');

              final location = restaurantData['Location'];

              String formatLocation(Map<String, dynamic> location) {
                final address = location['address'];
                final city = location['city'];
                final country = location['country'];
                final postalCode = location['postalCode'];

                return 'Address: $address\nCity: $city\nCountry: $country\nPostal Code: $postalCode';
              }

              String formattedLocation = formatLocation(location);

              final menu = restaurantData['menu'];
              final menuItem = menu['menuItem'];

              String formatMenu(Map<String, dynamic> menuItem) {
                final itemName = menuItem['itemName'];
                final price = menuItem['price'];

                return 'Item Name: $itemName\nPrice: $price \$';
              }

              String formattedMenu = formatMenu(menuItem);
              return ListView(
                children: [
                  // Restaurant Images
                  Container(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // TODO: Add code to display images
                      ],
                    ),
                  ),

                  // Restaurant Name and Description
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Restaurant Name: ${restaurantData['name']}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Description: ${restaurantData['description']}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  // Additional Information
                  ListTile(
                    title: Text('Location'),
                    subtitle: Text(formattedLocation),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text('menu'),
                    subtitle: Text(formattedMenu),
                  ),

                  ListTile(
                    title: Text('Phone'),
                    subtitle: Text(restaurantData['contact']['phone']),
                  ),
                  ListTile(
                    title: Text('Opening Hours'),
                    subtitle: Text(formattedOpeningHours),
                  ),
                  // Google Map for Restaurant Location

                  Container(
                    height: 200,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          37.7749,
                          -122.4194, // Replace with actual coordinates
                        ),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('restaurant-location'),
                          position: LatLng(
                            37.7749,
                            -122.4194, // Replace with actual coordinates
                          ),
                          infoWindow: InfoWindow(title: 'Restaurant Name'),
                        ),
                      },
                    ),
                  ),

                  // Button to add a new restaurant
                  FloatingActionButton(
                    onPressed: () {
                      db.addRestaurant();
                    },
                    child: Icon(Icons.add),
                  ),

                  // Button to navigate to the reservation screen
                  ElevatedButton(
                    onPressed: () {
                      context.pushNamed(
                        reservationScreenNameRoute,
                        queryParameters: {'restaurantId': widget.restaurantId},
                      );
                    },
                    child: Text('Create Reservation'),
                  ),
                ],
              );
            }
          },
        ),
      );
    }
  }
}
