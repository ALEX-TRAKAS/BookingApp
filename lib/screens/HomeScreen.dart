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
import '../widgets/double_text_widget.dart';
import 'package:bookingapp/widgets/circle_box.dart';

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
  bool isLocationSelected = false;

  @override
  void initState() {
    print('Init state of HomeScreen called.');
    getDatabaseData();
    if (mounted) {
      super.initState();
    }
    // showLocation();
  }

  Future<void> getDatabaseData() async {
    userData = await databaseFunctions.getUserData(user!.uid);
    print('User Data: $userData');
    profilePicUrl = userData?['photoURL'];
    restaurants = await databaseFunctions.getFromFirebase();
    if (mounted) {
      setState(() {});
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
                              IconButton(
                                icon: const Icon(
                                    Icons.location_on), // Change location icon
                                onPressed: () async {
                                  final selectedLocation = await context
                                      .pushNamed(locationSearchScreenNameRoute);
                                  if (selectedLocation != null) {
                                    print(
                                        'Selected location name: ${selectedLocation}');
                                    setState(() {
                                      isLocationSelected = true;
                                    });
                                  }
                                },
                              ),
                              // Text(
                              //   'Κάνε κράτηση',
                              //   style: Styles.headLineStyle1,
                              // ),
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
                    ],
                  ),
                ),
                if (!isLocationSelected)
                  Column(
                    children: [
                      Text(
                        'PRWTA EPELEKSE TOPO8ESIA',
                        style: Styles.headLineStyle1,
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
