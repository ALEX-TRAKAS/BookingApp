import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/services/databaseFunctions.dart';
import 'package:bookingapp/utils/AppStyles.dart';
import 'package:bookingapp/widgets/ReservationDialog%20.dart';
import 'package:bookingapp/widgets/customDrawer.dart';
import 'package:bookingapp/widgets/login_dialog.dart';
import 'package:bookingapp/widgets/webFooter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
  Map<String, dynamic>? userData;
  String profilePicUrl = '';
  String displayName = '';
  String restaurantName = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _restaurantData = _init();
    if (user != null) {
      _updateIsFavorite();
      loadData();
    }
    super.initState();
  }

  void _updateIsFavorite() async {
    if (user != null) {
      isFavorite = db.isFavoriteRestaurant(user!.uid, widget.restaurantId!);
      setState(() {});
    }
  }

  Future<Map<String, dynamic>> _init() async {
    try {
      final data =
          await databaseFunctions.getRestaurantData(widget.restaurantId) ?? {};
      print('Restaurant data: $data');

      return data;
    } catch (e) {
      // Handle errors
      print('Error loading restaurant data: $e');
      return {};
    }
  }

  Future<void> loadData() async {
    Map<String, dynamic>? userData =
        await databaseFunctions().getUserData(user!.uid);

    print(userData);
    setState(() {
      if (user!.photoURL == null) {
        profilePicUrl = '';
      } else {
        profilePicUrl = user!.photoURL.toString();
      }
      if (user!.displayName == null) {
        displayName = userData!['firstName'] + '\t' + userData!['lastName'];
      } else {
        displayName = user!.displayName!;
      }
    });
  }

  Future<void> _toggleFavorite(String restaurantId) async {
    if (user != null) {
      try {
        final isFavorite =
            await db.isFavoriteRestaurant(user!.uid, restaurantId);

        if (isFavorite) {
          print('remove favorite ${user!.uid}, $restaurantId');
          await db.removeFavoriteRestaurant(user!.uid, restaurantId);
        } else {
          print('add favorite ${user!.uid}, $restaurantId');
          await db.addFavoriteRestaurant(user!.uid, restaurantId);
        }

        // Update favorite status
        _updateIsFavorite();

        // Rebuild UI
        setState(() {});
      } catch (e) {
        print('Error toggling favorite: $e');
      }
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
                          BoxConstraints(maxWidth: 600, maxHeight: 660),
                      child: Stack(
                        children: [
                          LoginDialog(
                            onLoginSuccess: () {
                              _onLoginSuccess();
                              setState(() {
                                loadData();
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
        context.pushReplacementNamed(restaurantsDetailedScreenNameRoute,
            queryParameters: {'restaurantId': widget.restaurantId});
      });
    }
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
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.white,
      actions: <Widget>[
        if (user != null)
          FutureBuilder<bool>(
            future: isFavorite,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Icon(
                  Icons.bookmark,
                  size: 40,
                  color: Colors.grey,
                );
              } else if (snapshot.hasError) {
                return const Icon(Icons.error_outline, color: Colors.red);
              } else {
                final bool isFav = snapshot.data ?? false;
                return Ink(
                  decoration: const ShapeDecoration(
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.bookmark,
                      size: 40,
                    ),
                    onPressed: () {
                      _toggleFavorite(widget.restaurantId!);
                      setState(() {});
                    },
                    color: isFav ? Styles.primaryColor : Colors.grey,
                  ),
                );
              }
            },
          ),
      ],
    );
  }

  Widget buildMobileLayout() {
    if (_restaurantData == null) {
      return const CircularProgressIndicator();
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<Map<String, dynamic>>(
          future: _restaurantData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Text('Δεν υπάρχουν διαθέσιμα δεδομένα εστιατορίου');
            } else {
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

              final daylElLocale = [
                'Δευτέρα',
                'Τρίτη',
                'Τετάρτη',
                'Πέμπτη',
                'Παρασκευή',
                'Σάββατο',
                'Κυριακή'
              ];
              final formattedOpeningHours = days
                  .where((day) =>
                      openingHours[day.toLowerCase()]['isOpen'] == true)
                  .map((day) {
                final startTime = openingHours[day.toLowerCase()]['startTime'];
                final endTime = openingHours[day.toLowerCase()]['endTime'];
                final greekDay = daylElLocale[days.indexOf(day)];
                return '$greekDay: $startTime - $endTime';
              }).join('\n');

              final location = restaurantData['Location'];
              final GeoPoint geoPoint = location['coordinates'];
              final double latitude = geoPoint.latitude;
              final double longitude = geoPoint.longitude;

              String formatLocation(Map<String, dynamic> location) {
                final address = location['address'];
                final city = location['city'];
                final country = location['country'];
                final postalCode = location['postalCode'];

                return 'Διεύθυνση: $address\nΠόλη: $city\nΧώρα: $country\nΤαχυδρομικός Κώδικας: $postalCode';
              }

              String formattedLocation = formatLocation(location);

              final menu = restaurantData['menu'];
              final menuItem = menu['menuItem'];

              String formatMenu(Map<String, dynamic> menuItem) {
                final itemName = menuItem['itemName'];
                final price = menuItem['price'];

                return '$itemName \tPrice: $price €';
              }

              String formattedMenu = formatMenu(menuItem);
              return ListView(
                children: [
                  Stack(
                    children: [
                      Flex(
                        direction: Axis.vertical,
                        children: [
                          Image.network(
                            restaurantData['mainPhoto'],
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.pushNamed(photoGridScreenNameRoute,
                                queryParameters: {
                                  'restaurantId': widget.restaurantId
                                });
                          },
                          icon: Icon(
                            Icons.photo,
                            color: Styles.primaryColor,
                          ),
                          label: const Text('Εικόνες'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Όνομα Εστιατορίου: ${restaurantData['name']}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Πληροφορίες: ${restaurantData['description']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Διεύθυνση'),
                    subtitle: Text(formattedLocation),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Μενού'),
                    subtitle: Text(formattedMenu),
                  ),

                  ListTile(
                    title: const Text('Τηλεφωνικές κρατήσεις'),
                    subtitle: Text(restaurantData['contact']['phone']),
                  ),
                  ListTile(
                    title: const Text('Ωράριο'),
                    subtitle: Text(formattedOpeningHours),
                  ),
                  // Google Map for Restaurant Location
                  SizedBox(
                    height: 400,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          latitude,
                          longitude,
                        ),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('restaurant-location'),
                          position: LatLng(
                            latitude,
                            longitude,
                          ),
                          infoWindow: InfoWindow(title: restaurantData['name']),
                        ),
                      },
                    ),
                  ),
                  const Gap(100),
                  if (kIsWeb) webFooter(),
                ],
              );
            }
          },
        ),
        floatingActionButton: Container(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton.extended(
            onPressed: () {
              context.pushNamed(
                reservationScreenNameRoute,
                queryParameters: {'restaurantId': widget.restaurantId},
              );
            },
            backgroundColor: Styles.primaryColor,
            foregroundColor: Colors.white,
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Styles.primaryColor),
              borderRadius: BorderRadius.circular(10.0),
            ),
            label: const Text(
              'Κάνε κράτηση',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }
  }

  Widget buildWebLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Styles.secondaryColor,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(
            Icons.home,
            size: 30,
          ),
          color: Styles.primaryColor,
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                restaurantName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Styles.primaryColor,
            ),
          ],
        ),
        actions: <Widget>[
          if (user != null)
            FutureBuilder<bool>(
              future: isFavorite,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Icon(
                    Icons.bookmark,
                    size: 40,
                    color: Colors.grey,
                  );
                } else if (snapshot.hasError) {
                  return const Icon(Icons.error_outline, color: Colors.red);
                } else {
                  final bool isFav = snapshot.data ?? false;
                  return Ink(
                    decoration: const ShapeDecoration(
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.bookmark,
                        size: 40,
                      ),
                      onPressed: () {
                        _toggleFavorite(widget.restaurantId!);
                        setState(() {});
                      },
                      color: isFav ? Styles.primaryColor : Colors.grey,
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Gap(20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: _restaurantData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                      child:
                          Text('Δεν υπάρχουν διαθέσιμα δεδομένα εστιατορίου'));
                } else {
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

                  final daylElLocale = [
                    'Δευτέρα',
                    'Τρίτη',
                    'Τετάρτη',
                    'Πέμπτη',
                    'Παρασκευή',
                    'Σάββατο',
                    'Κυριακή'
                  ];

                  final formattedOpeningHours = days
                      .where((day) =>
                          openingHours[day.toLowerCase()]['isOpen'] == true)
                      .map((day) {
                    final startTime =
                        openingHours[day.toLowerCase()]['startTime'];
                    final endTime = openingHours[day.toLowerCase()]['endTime'];
                    final greekDay = daylElLocale[days.indexOf(day)];
                    return '$greekDay: $startTime - $endTime';
                  }).join('\n');

                  final location = restaurantData['Location'];
                  final GeoPoint geoPoint = location['coordinates'];
                  final double latitude = geoPoint.latitude;
                  final double longitude = geoPoint.longitude;

                  String formatLocation(Map<String, dynamic> location) {
                    final address = location['address'];
                    final city = location['city'];
                    final country = location['country'];
                    final postalCode = location['postalCode'];

                    return 'Διεύθυνση: $address\nΠόλη: $city\nΧώρα: $country\nΤαχυδρομικός Κώδικας: $postalCode';
                  }

                  String formattedLocation = formatLocation(location);

                  final menu = restaurantData['menu'];
                  final menuItem = menu['menuItem'];

                  String formatMenu(Map<String, dynamic> menuItem) {
                    final itemName = menuItem['itemName'];
                    final price = menuItem['price'];

                    return '$itemName \tPrice: $price €';
                  }

                  String formattedMenu = formatMenu(menuItem);

                  return Column(
                    children: [
                      Stack(
                        children: [
                          Image.network(
                            restaurantData['mainPhoto'],
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.pushNamed(photoGridScreenNameRoute,
                                    queryParameters: {
                                      'restaurantId': widget.restaurantId
                                    });
                              },
                              icon: Icon(
                                Icons.photo,
                                color: Styles.primaryColor,
                              ),
                              label: const Text('Εικόνες'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Όνομα Εστιατορίου: ${restaurantData['name']}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Πληροφορίες: ${restaurantData['description']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        title: const Text('Διεύθυνση'),
                        subtitle: Text(formattedLocation),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Μενού'),
                        subtitle: Text(formattedMenu),
                      ),
                      ListTile(
                        title: const Text('Τηλεφωνικές κρατήσεις'),
                        subtitle: Text(restaurantData['contact']['phone']),
                      ),
                      ListTile(
                        title: const Text('Ωράριο'),
                        subtitle: Text(formattedOpeningHours),
                      ),
                      SizedBox(
                        height: 400,
                        child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              latitude,
                              longitude,
                            ),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId('restaurant-location'),
                              position: LatLng(
                                latitude,
                                longitude,
                              ),
                              infoWindow:
                                  InfoWindow(title: restaurantData['name']),
                            ),
                          },
                        ),
                      ),
                      const Gap(100),
                    ],
                  );
                }
              },
            ),
            if (kIsWeb)
              Container(
                width: double.infinity,
                child: webFooter(),
              ),
          ],
        ),
      ),
      floatingActionButton: Container(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton.extended(
          onPressed: () {
            if (user == null) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Styles.secondaryColor,
                    title: const Text('Απαιτείται Σύνδεση'),
                    content: const Text(
                        'Πρέπει να συνδεθείτε για να κάνετε κράτηση.'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(color: Colors.red, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Ακύρωση'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showLoginDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          side:
                              BorderSide(color: Styles.primaryColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Σύνδεση'),
                      ),
                    ],
                  );
                },
              );
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ReservationDialog(restaurantId: widget.restaurantId);
                },
              );
            }
          },
          backgroundColor: Styles.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Styles.primaryColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          label: const Text(
            'Κάνε κράτηση',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

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
            if (constraints.maxWidth >= 905) {
              return buildWebLayout();
            } else {
              return buildMobileLayout();
            }
          },
        ),
      );
    } else {
      return Scaffold(
        appBar: buildMobileAppBar(),
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return buildWebLayout();
            } else {
              return buildMobileLayout();
            }
          },
        ),
      );
    }
  }
}
