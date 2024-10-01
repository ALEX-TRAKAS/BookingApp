// ignore_for_file: empty_catches

import 'package:cloud_firestore/cloud_firestore.dart';

class databaseFunctions {
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future getFromFirebase(String postalCode) async {
    final result = await FirebaseFirestore.instance
        .collection("restaurants")
        .where('Location.postalCode', isEqualTo: postalCode)
        .get();

    return result.docs
        .map((e) => {
              'id': e.id,
              ...e.data(),
            })
        .toList();
  }

  static Future getFromFirebaseLocation(String locationName) async {
    final result = await FirebaseFirestore.instance
        .collection("restaurants")
        .where('Location.city', isEqualTo: locationName)
        .get();

    return result.docs
        .map((e) => {
              'id': e.id,
              ...e.data(),
            })
        .toList();
  }

  static Future getFromFirebaseAll() async {
    final result =
        await FirebaseFirestore.instance.collection("restaurants").get();

    return result.docs
        .map((e) => {
              'id': e.id, // Include the document ID
              ...e.data(), // Include the document data
            })
        .toList();
  }

  static Future getRestaurantData(String? restaurantId) async {
    try {
      DocumentSnapshot restauranSnapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .get();
      // Check if the document exists
      if (restauranSnapshot.exists) {
        // Convert the document snapshot data to a Map
        Map<String, dynamic>? data =
            restauranSnapshot.data() as Map<String, dynamic>?;

        return data;
      } else {
        // Restaurant document not found
        print('Restaurant not found in Firestore');
        return null;
      }
    } catch (e) {
      // Handle errors
      print('Error retrieving restaurant data: $e');
      return null;
    }
  }

  Future<void> createReservation({
    required Timestamp? reservationDateAndTime,
    required int numberOfGuests,
    required String specialRequests,
    required String contactName,
    required String contactPhoneNumber,
    required String contactEmail,
    required String userID,
    required String? restaurantID,
    required String restaurantName,
    required String reservationStatus,
    required Timestamp? creationTimestamp,
    required Timestamp? lastUpdatedTimestamp,
  }) async {
    try {
      final CollectionReference reservationsCollection =
          FirebaseFirestore.instance.collection('reservations');

      await reservationsCollection.add({
        'dateTime': reservationDateAndTime,
        'numberOfGuests': numberOfGuests,
        'specialRequests': specialRequests,
        'contactName': contactName,
        'contactPhoneNumber': contactPhoneNumber,
        'contactEmail': contactEmail,
        'userID': userID,
        'restaurantID': restaurantID,
        'restaurantName': restaurantName,
        'reservationStatus': reservationStatus,
        'creationTimestamp': creationTimestamp,
        'lastUpdatedTimestamp': lastUpdatedTimestamp
      });
    } catch (e) {}
  }

  Future<void> updateReservationStatus(
      String userId, String reservationId, String newStatus) async {
    try {
      DocumentReference reservationDoc = FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId);

      final docSnapshot = await reservationDoc.get();
      if (docSnapshot.exists) {
        await reservationDoc.update({'reservationStatus': newStatus});
      }
    } catch (e) {}
  }

  // Future<void> updateReservationStatus(
  //     String userId, String reservationId, String newStatus) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('reservations')
  //         .doc(userId)
  //         .collection('userReservations')
  //         .doc(reservationId)
  //         .update({'reservationStatus': newStatus});
  //   } catch (e) {
  //     print('Error updating reservation status: $e');
  //     // Handle the error, show an error message, or retry
  //   }
  // }

  Future<List<Map<String, dynamic>>> getAllReservationsToday(
      String userId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay =
          startOfDay.add(Duration(days: 1)).subtract(Duration(milliseconds: 1));

      final QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('userID', isEqualTo: userId)
          .where('creationTimestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('creationTimestamp',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('creationTimestamp', descending: true)
          .get();

      return reservationSnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllReservations(String userId) async {
    try {
      final QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('userID', isEqualTo: userId)
          .orderBy('creationTimestamp', descending: true)
          .get();

      return reservationSnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllReservationseExceptToday(
      String userId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);

      final QuerySnapshot reservationsBeforeTodaySnapshot =
          await FirebaseFirestore.instance
              .collection('reservations')
              .where('userID', isEqualTo: userId)
              .where('creationTimestamp',
                  isLessThan: Timestamp.fromDate(startOfDay))
              .orderBy('creationTimestamp', descending: true)
              .get();

      return reservationsBeforeTodaySnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      return [];
    }
  }

  void addRestaurant() async {
    // Create a reference to the Firestore collection
    CollectionReference restaurants =
        FirebaseFirestore.instance.collection('restaurants');

    // Add a document with dummy data
    await restaurants.add({
      'Location': {
        'address': '123 Pine Street',
        'city': 'Tastytown',
        'coordinates': const GeoPoint(40.8781, -84.6298),
        'country': 'Flavorland',
        'postalCode': '98765',
      },
      'avgPrice': '\$\$\$',
      'contact': {
        'email': 'info@tastefulcuisine.com',
        'phone': '+9876543210',
      },
      'cuisine': 'Italian',
      'description': 'Indulge in exquisite French cuisine with a modern twist.',
      'mainPhoto': 'https://example.com/main-photo-6.jpg',
      'menu': {
        'menuItem': {
          'itemName': 'Coq au Vin',
          'price': 29.99,
        },
      },
      'name': 'Tasteful Cuisine',
      'openingHours': {
        'friday': {
          'endTime': '10:30 PM',
          'isOpen': true,
          'startTime': '12:00 PM',
        },
        'monday': {
          'endTime': '09:00 PM',
          'isOpen': false,
          'startTime': '11:30 AM',
        },
        'saturday': {
          'endTime': '11:00 PM',
          'isOpen': true,
          'startTime': '12:00 PM',
        },
        'sunday': {
          'endTime': '09:00 PM',
          'isOpen': true,
          'startTime': '01:00 PM',
        },
        'thursday': {
          'endTime': '10:00 PM',
          'isOpen': true,
          'startTime': '11:00 AM',
        },
        'tuesday': {
          'endTime': '09:30 PM',
          'isOpen': true,
          'startTime': '11:30 AM',
        },
        'wednesday': {
          'endTime': '10:00 PM',
          'isOpen': true,
          'startTime': '11:00 AM',
        },
      },
      'photos': [
        'https://example.com/photo11.jpg',
        'https://example.com/photo12.jpg',
      ],
      'table': {
        'capacity': '85',
      },
    });

    print('Restaurant added successfully!');
  }

  Future<Map<String, dynamic>> getRestaurantDataSecond(
      String? restaurantId) async {
    try {
      DocumentSnapshot restaurantSnapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .get();

      // Check if the document exists
      if (restaurantSnapshot.exists) {
        // Convert the document snapshot data to a Map
        Map<String, dynamic> data =
            restaurantSnapshot.data() as Map<String, dynamic>;

        return data;
      } else {
        // Restaurant document not found
        print('Restaurant not found in Firestore');
        // Return an empty map if the restaurant is not found
        return {};
      }
    } catch (e) {
      // Handle errors
      print('Error retrieving restaurant data: $e');
      // Return an empty map if an error occurs
      return {};
    }
  }

  Future<void> submitReview(String restaurantId, double newRating) async {
    // Assume you have a collection 'reviews' where reviews are stored.
    final CollectionReference restaurants =
        FirebaseFirestore.instance.collection('restaurants');

    QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('restaurantId', isEqualTo: restaurantId)
        .get();

    // Calculate the new rating based on existing ratings and the new review.
    double totalRating = 0;
    int numberOfReviews = reviewsSnapshot.size;

    for (QueryDocumentSnapshot review in reviewsSnapshot.docs) {
      totalRating += review['rating'] ?? 0.0;
    }

    double averageRating = (totalRating + newRating) / (numberOfReviews + 1);

    // Update the restaurant document with the new rating.
    await restaurants.doc(restaurantId).update({'rating': averageRating});
  }

  Future<List<String>> getFavoriteRestaurants(String userId) async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        final favoriteRestaurantIds =
            data.keys.where((key) => data[key] == true).toList();
        return favoriteRestaurantIds;
      } else {
        return [];
      }
    } catch (e) {
      print('Error retrieving favorite restaurants: $e');
      return [];
    }
  }

  Future<void> addFavoriteRestaurant(
      String? userId, String restaurantId) async {
    try {
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId) // Using user ID as the document ID
          .set({
        'userFavorites': {
          restaurantId: {'isFavorite': true},
        },
      }, SetOptions(merge: true)); // Using merge to update existing data
    } catch (e) {}
  }

  Future<void> removeFavoriteRestaurant(
      String userId, String restaurantId) async {
    try {
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .update({
        'userFavorites.$restaurantId': FieldValue.delete(),
      });
    } catch (e) {}
  }

  Future<bool> isFavoriteRestaurant(String userId, String restaurantId) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        final Map<String, dynamic> userFavorites =
            (userData?['userFavorites'] as Map<String, dynamic>?) ?? {};

        final bool isFavorite = userFavorites.containsKey(restaurantId) &&
            userFavorites[restaurantId]?['isFavorite'] == true;
        return isFavorite;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>>? getAllFavoriteRestaurants(String userId) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        final Map<String, dynamic> userFavorites =
            (userData?['userFavorites'] as Map<String, dynamic>?) ?? {};

        List<String> favorites = userFavorites.keys.toList();

        return favorites;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>?> getAllFavoriteRestaurantsData(
      Future<List<String>>? favRestIdList) async {
    try {
      List<Map<String, dynamic>> allFavoriteRestaurantData = [];

      if (favRestIdList != null) {
        List<String> restaurantIds = await favRestIdList;

        for (String restaurantId in restaurantIds) {
          final DocumentSnapshot restaurantDoc = await FirebaseFirestore
              .instance
              .collection('restaurants')
              .doc(restaurantId)
              .get();

          if (restaurantDoc.exists) {
            final Map<String, dynamic>? restaurantData =
                restaurantDoc.data() as Map<String, dynamic>?;

            if (restaurantData != null) {
              // Add both the data and the ID to the list
              allFavoriteRestaurantData.add({
                'id': restaurantId,
                'data': restaurantData,
              });
            }
          }
        }
      }
      return allFavoriteRestaurantData;
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> filteredAscending(
      String postalCode) async {
    final result = await FirebaseFirestore.instance
        .collection("restaurants")
        .where('Location.postalCode', isEqualTo: postalCode)
        .orderBy('avgPrice', descending: false)
        .get();

    final List<Map<String, dynamic>> restaurants = result.docs
        .map((e) => {
              'id': e.id, //  document ID
              ...e.data(), //  document data
            })
        .toList();

    final int count = result.size;

    return {'restaurants': restaurants, 'count': count};
  }
}
