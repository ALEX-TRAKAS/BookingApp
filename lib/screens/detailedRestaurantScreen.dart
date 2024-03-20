import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/services/databaseFunctions.dart';
import 'package:bookingapp/utils/AppStyles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetailedRestaurantScreen extends StatefulWidget {
  final String? restaurantId;

  const DetailedRestaurantScreen({super.key, this.restaurantId});

  @override
  _DetailedRestaurantScreenState createState() =>
      _DetailedRestaurantScreenState();
}

class _DetailedRestaurantScreenState extends State<DetailedRestaurantScreen> {
  late Future<Map<String, dynamic>>? _restaurantData;
  late Future<bool> isFavorite;
  final db = databaseFunctions();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    _restaurantData = _init();
    _updateIsFavorite();
    super.initState();
  }

  void _updateIsFavorite() async {
    isFavorite = db.isFavoriteRestaurant(user!.uid, widget.restaurantId!);
    setState(() {});
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
        print('remove favorite ${user!.uid}, $restaurantId');
        await db.removeFavoriteRestaurant(user!.uid, restaurantId);
      } else {
        print('add favorite ${user!.uid}, $restaurantId');
        await db.addFavoriteRestaurant(user!.uid, restaurantId);
      }

      // Update favorite status
      _updateIsFavorite();

      // Rebuild UI to reflect the changes
      setState(() {});
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_restaurantData == null) {
      // Handle the case where data is not available yet, e.g., show a loading indicator
      return const CircularProgressIndicator();
    } else {
      return Scaffold(
        appBar: AppBar(
          // backgroundColor: Colors.transparent,
          // elevation: 0.0, // Remove the shadow
          leading: Ink(
            decoration: const ShapeDecoration(
              color: Colors.grey,
              shape: CircleBorder(),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Styles.primaryColor,
              onPressed: () {
                GoRouter.of(context).pop();
              },
            ),
          ),
          actions: <Widget>[
            FutureBuilder<bool>(
              future: isFavorite,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Return a placeholder widget while waiting for the future to complete
                  return const Icon(
                    Icons.bookmark,
                    color: Colors.grey, // You can customize the error color
                  );
                } else if (snapshot.hasError) {
                  // Return a widget to display the error if the future throws an error
                  return const Icon(
                    Icons.error_outline,
                    color: Colors.red, // You can customize the error color
                  );
                } else {
                  // Return the bookmark icon with the appropriate color based on the future's result
                  final bool isFav = snapshot.data ?? false;
                  return Ink(
                    decoration: const ShapeDecoration(
                      color: Colors.grey,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.bookmark),
                      onPressed: () {
                        _toggleFavorite(widget.restaurantId!);
                        setState(() {});
                      },
                      color: isFav ? Styles.primaryColor : Colors.white,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _restaurantData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Data is still loading
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // An error occurred
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data == null) {
              // No data available
              return const Text('No restaurant data available');
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
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
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
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Description: ${restaurantData['description']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  // Additional Information
                  ListTile(
                    title: const Text('Location'),
                    subtitle: Text(formattedLocation),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('menu'),
                    subtitle: Text(formattedMenu),
                  ),

                  ListTile(
                    title: const Text('Phone'),
                    subtitle: Text(restaurantData['contact']['phone']),
                  ),
                  ListTile(
                    title: const Text('Opening Hours'),
                    subtitle: Text(formattedOpeningHours),
                  ),
                  // Google Map for Restaurant Location

                  SizedBox(
                    height: 200,
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(
                          37.7749,
                          -122.4194, // Replace with actual coordinates
                        ),
                        zoom: 15,
                      ),
                      markers: {
                        const Marker(
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
                    child: const Icon(Icons.add),
                  ),

                  // Button to navigate to the reservation screen
                  ElevatedButton(
                    onPressed: () {
                      context.pushNamed(
                        reservationScreenNameRoute,
                        queryParameters: {'restaurantId': widget.restaurantId},
                      );
                    },
                    child: const Text('Create Reservation'),
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
