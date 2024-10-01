import 'package:bookingapp/widgets/customDrawer.dart';
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

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Future<List<String>>? _favorites;
  late Future<List<Map<String, dynamic>>?> _favoriteRestData;
  final user = FirebaseAuth.instance.currentUser!;
  final db = databaseFunctions();
  ScrollController scrollViewController = ScrollController();
  ScrollController webScrollViewController = ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? userData;
  String profilePicUrl = '';
  String displayName = '';

  @override
  void initState() {
    print('Init state of favoritesScreen called.');
    super.initState();
    _favorites = db.getAllFavoriteRestaurants(user.uid);
    _favoriteRestData = db.getAllFavoriteRestaurantsData(_favorites!);
    loadUserData();
  }

  Future<void> _toggleFavorite(String restaurantId) async {
    try {
      final isFavorite = await db.isFavoriteRestaurant(user.uid, restaurantId);

      if (isFavorite) {
        await db.removeFavoriteRestaurant(user.uid, restaurantId);
      } else {
        await db.addFavoriteRestaurant(user.uid, restaurantId);
      }

      setState(() {
        // Update the list of favorites
        _favorites = db.getAllFavoriteRestaurants(user.uid);
        _favoriteRestData = db.getAllFavoriteRestaurantsData(_favorites!);
      });
    } catch (e) {}
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
            onTap: () => {context.goNamed(authNameRoute)},
            child: Image.asset(
              'assets/images/logo.png',
              height: 90,
            ),
          ),
          const Text('Αγαπημένα'),
          if (user != null)
            GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isMobileWidth || !kIsWeb)
                    Text(
                      displayName,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
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
    return FutureBuilder<List<Map<String, dynamic>>?>(
      future: _favoriteRestData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Δεν υπάρχουν αγαπημένα.'));
        } else {
          List<Map<String, dynamic>>? favoriteRestaurants = snapshot.data!;
          return SingleChildScrollView(
            controller: webScrollViewController,
            child: Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: 1000), // Set max width here
                    child: ListView.builder(
                      controller: webScrollViewController,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemExtent: 250.0,
                      itemCount: favoriteRestaurants.length,
                      itemBuilder: (context, index) {
                        final restaurants = favoriteRestaurants[index];
                        return InkWell(
                          onTap: () {
                            context.pushNamed(
                              restaurantsDetailedScreenNameRoute,
                              queryParameters: {
                                'restaurantId': restaurants['id'],
                              },
                            );
                          },
                          child: Container(
                            height: 200,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            margin: const EdgeInsets.only(
                                right: 50, left: 50, top: 50),
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
                            child: Stack(
                              children: [
                                Row(
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
                                              restaurants['data']['mainPhoto']),
                                        ),
                                      ),
                                    ),
                                    const Gap(10),
                                    SizedBox(
                                      width: 170,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Gap(10),
                                          Text(
                                            restaurants['data']['name'] ??
                                                'Unknown',
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
                                                favoriteRestaurants[index]
                                                            ['data']['Location']
                                                        ?['city'] ??
                                                    'Unknown',
                                                style: Styles.headLineStyle2
                                                    .copyWith(
                                                        color:
                                                            Styles.textColor),
                                              ),
                                            ],
                                          ),
                                          const Gap(5),
                                          RatingBar.builder(
                                            initialRating:
                                                (favoriteRestaurants[index]
                                                            ['data']['rating']
                                                        as num)
                                                    .toDouble(),
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemSize: 25.0,
                                            itemPadding: EdgeInsets.symmetric(
                                                horizontal: 1.0),
                                            itemBuilder: (context, _) =>
                                                const Icon(
                                              Icons.star,
                                              color: Color(0xFF0F9B0F),
                                            ),
                                            ignoreGestures: true,
                                            onRatingUpdate: (double value) {},
                                          ),
                                          const Gap(8),
                                          Text(
                                            restaurants['data']['avgPrice'] !=
                                                    null
                                                ? '${restaurants['data']['avgPrice']}€'
                                                : 'Unknown',
                                            style: Styles.headLineStyle1
                                                .copyWith(
                                                    color: Styles.textColor),
                                          ),
                                          Text(
                                            restaurants['data']['cuisine'] ??
                                                'Unknown',
                                            style: Styles.headLineStyle3
                                                .copyWith(
                                                    color: Styles.textColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Gap(25),
                                  ],
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    iconSize: 30,
                                    icon: const Icon(Icons.bookmark,
                                        color: Color(0xFF0F9B0F)),
                                    onPressed: () {
                                      _toggleFavorite(restaurants['id']);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const Gap(20),
                webFooter(),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildMobileLayout() {
    return FutureBuilder<List<Map<String, dynamic>>?>(
      future: _favoriteRestData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Δεν υπάρχουν αγαπημένα.'));
        } else {
          List<Map<String, dynamic>>? favoriteRestaurants = snapshot.data!;
          return SingleChildScrollView(
            controller: scrollViewController,
            child: Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: ListView.builder(
                      controller: scrollViewController,
                      shrinkWrap: true,
                      itemExtent: 200.0,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: favoriteRestaurants.length,
                      itemBuilder: (context, index) {
                        final restaurants = favoriteRestaurants[index];
                        return InkWell(
                          onTap: () {
                            context.pushNamed(
                              restaurantsDetailedScreenNameRoute,
                              queryParameters: {
                                'restaurantId': restaurants['id'],
                              },
                            );
                          },
                          child: Container(
                            height: 200,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            margin: const EdgeInsets.only(
                                right: 17,
                                top: 5,
                                left: 17), // Adjust margins as needed
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
                            child: Stack(
                              children: [
                                Row(
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
                                              restaurants['data']['mainPhoto']),
                                        ),
                                      ),
                                    ),
                                    const Gap(10),
                                    SizedBox(
                                      width: 170,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Gap(10),
                                          Text(
                                            restaurants['data']['name'] ??
                                                'Unknown',
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
                                                favoriteRestaurants[index]
                                                            ['data']['Location']
                                                        ?['city'] ??
                                                    'Unknown',
                                                style: Styles.headLineStyle2
                                                    .copyWith(
                                                        color:
                                                            Styles.textColor),
                                              ),
                                            ],
                                          ),
                                          const Gap(5),
                                          RatingBar.builder(
                                            initialRating:
                                                (favoriteRestaurants[index]
                                                            ['data']['rating']
                                                        as num)
                                                    .toDouble(),
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemSize: 25.0,
                                            itemPadding: EdgeInsets.symmetric(
                                                horizontal: 1.0),
                                            itemBuilder: (context, _) =>
                                                const Icon(
                                              Icons.star,
                                              color: Color(0xFF0F9B0F),
                                            ),
                                            ignoreGestures: true,
                                            onRatingUpdate: (double value) {},
                                          ),
                                          const Gap(8),
                                          Text(
                                            restaurants['data']['avgPrice'] !=
                                                    null
                                                ? '${restaurants['data']['avgPrice']}€'
                                                : 'Unknown',
                                            style: Styles.headLineStyle1
                                                .copyWith(
                                                    color: Styles.textColor),
                                          ),
                                          Text(
                                            restaurants['data']['cuisine'] ??
                                                'Unknown',
                                            style: Styles.headLineStyle3
                                                .copyWith(
                                                    color: Styles.textColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    iconSize: 30,
                                    icon: const Icon(Icons.bookmark,
                                        color: Color(0xFF0F9B0F)),
                                    onPressed: () {
                                      _toggleFavorite(restaurants['id']);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (kIsWeb) webFooter(),
              ],
            ),
          );
        }
      },
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
            if (constraints.maxWidth > 800) {
              return buildWebLayout();
            } else {
              return buildMobileLayout();
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
              return buildMobileLayout();
            }
          },
        ),
      );
    }
  }
}
