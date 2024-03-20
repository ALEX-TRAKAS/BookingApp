import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/services/databaseFunctions.dart';
import 'package:bookingapp/utils/AppStyles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void initState() {
    print('Init state of favoritesScreen called.');
    super.initState();
    _favorites = db.getAllFavoriteRestaurants(user.uid);
    _favoriteRestData = db.getAllFavoriteRestaurantsData(_favorites!);
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
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Αγαπημένα'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
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
            return ListView.builder(
              controller: scrollViewController,
              shrinkWrap: true,
              itemExtent: 200.0,
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
                            // image: DecorationImage(
                            //   fit: BoxFit.cover,
                            //   image: NetworkImage(
                            //     restaurants[index]['imageUrl'],
                            //   ),
                            // ),
                          ),
                        ),
                        const Gap(10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Gap(10),
                            Text(
                              restaurants['data']['name'] ?? 'Unknown',
                              style: Styles.headLineStyle2
                                  .copyWith(color: Styles.textColor),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_sharp,
                                  size: 25.0,
                                  color: Color(0xFF0F9B0F),
                                ),
                                Text(
                                  favoriteRestaurants[index]['data']['Location']
                                          ?['city'] ??
                                      'Unknown',
                                  style: Styles.headLineStyle2
                                      .copyWith(color: Styles.textColor),
                                ),
                              ],
                            ),
                            // const Gap(5),
                            // RatingBar.builder(
                            //   initialRating: 3,
                            //   minRating: 1,
                            //   direction: Axis.horizontal,
                            //   allowHalfRating: true,
                            //   itemCount: 5,
                            //   itemSize: 25.0,
                            //   itemPadding:
                            //       EdgeInsets.symmetric(horizontal: 1.0),
                            //   itemBuilder: (context, _) => const Icon(
                            //     Icons.star,
                            //     color: Color(0xFF0F9B0F),
                            //   ),
                            //   onRatingUpdate: (rating) {
                            //     print(rating);
                            //   },
                            // ),
                            // const Gap(8),
                            Text(
                              restaurants['data']['avgPrice'] != null
                                  ? '${restaurants['data']['avgPrice']}€'
                                  : 'Unknown',
                              style: Styles.headLineStyle1
                                  .copyWith(color: Styles.textColor),
                            ),
                            Text(
                              restaurants['data']['cuisine'] ?? 'Unknown',
                              style: Styles.headLineStyle3
                                  .copyWith(color: Styles.textColor),
                            ),
                          ],
                        ),
                        const Gap(25),
                        IconButton(
                          iconSize: 30,
                          icon: const Icon(Icons.bookmark, color: Color(0xFF0F9B0F)),
                          onPressed: () {
                            _toggleFavorite(restaurants['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
                //ListTile(
                //   title: Text(item),
                //   trailing: IconButton(
                //     icon: Icon(Icons.bookmark, color: Color(0xFF0F9B0F)),
                //     onPressed: () {
                //       _toggleFavorite(item);
                //     },
                //   ),
                // );
              },
            );
          }
        },
      ),
    );
  }
}
