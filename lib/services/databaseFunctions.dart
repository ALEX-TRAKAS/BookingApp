import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class databaseFunctions {
  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      // Reference to the user document in the "users" collection
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Check if the document exists
      if (userSnapshot.exists) {
        // Convert the document snapshot data to a Map
        Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;

        return data;
      } else {
        // User document not found
        print('User not found in Firestore');
        return null;
      }
    } catch (e) {
      // Handle errors
      print('Error retrieving user data: $e');
      return null;
    }
  }

  static Future getFromFirebase() async {
    // List<Map<String, dynamic>> restaurants = [];
    final result =
        await FirebaseFirestore.instance.collection("restaurants").get();

    return result.docs
        .map((e) => {
              'id': e.id, // Include the document ID
              ...e.data()!, // Include the document data
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
    required String restaurantID,
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
        'reservationStatus': reservationStatus,
        'creationTimestamp': creationTimestamp,
        'lastUpdatedTimestamp': lastUpdatedTimestamp
      });
    } catch (e) {
      // Handle errors
      print('Error creating reservation: $e');
    }
  }

  Future<void> updateReservationStatus(
      String userId, String reservationId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(userId)
          .collection('userReservations')
          .doc(reservationId)
          .update({'reservationStatus': newStatus});
    } catch (e) {
      print('Error updating reservation status: $e');
      // Handle the error, show an error message, or retry
    }
  }

  Future<List<Map<String, dynamic>>> getAllReservations(String userId) async {
    try {
      final QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('userID', isEqualTo: userId)
          .get();

      return reservationSnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data}; // Include the document ID
      }).toList();
    } catch (e) {
      print('Error getting reservations: $e');
      return [];
    }
  }

  // Future<List<Map<String, dynamic>>> getAllReservations(String userId) async {
  //   try {
  //     final QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
  //         .collection('reservations')
  //         .doc(userId)
  //         .collection('userReservations')
  //         .get();

  //     return reservationSnapshot.docs.map((doc) {
  //       return {
  //         'reservationId': doc.id,
  //         'creationTimestamp': doc['creationTimestamp'],
  //         'extraContactInformation': doc['extraContactInformation'],
  //         'lastUpdatedTimestamp': doc['lastUpdatedTimestamp'],
  //         'numberOfGuests': doc['numberOfGuests'],
  //         'reservationDateAndTime': doc['reservationDateAndTime'],
  //         'reservationStatus': doc['reservationStatus'],
  //         'restaurantID': doc['restaurantID'],
  //         'specialRequests': doc['specialRequests'],
  //         'userID': doc['userID'],
  //       };
  //     }).toList();
  //   } catch (e) {
  //     print('Error getting reservations: $e');
  //     return [];
  //   }
  // }

  void addRestaurant() async {
    // Create a reference to the Firestore collection
    CollectionReference restaurants =
        FirebaseFirestore.instance.collection('restaurants');

    // Add a document with dummy data
    await restaurants.add({
      'Location': {
        'address': '123 Pine Street',
        'city': 'Tastytown',
        'coordinates': GeoPoint(40.8781, -84.6298),
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

  Future<void> getRestaurantDataSecond(String restaurantId) async {
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

        // Print the retrieved data
        print('Restaurant Data:');
        data.forEach((key, value) {
          print('$key: $value');
        });
      } else {
        // Restaurant document not found
        print('Restaurant not found in Firestore');
      }
    } catch (e) {
      // Handle errors
      print('Error retrieving restaurant data: $e');
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
          .doc(userId) // Use user ID as the document ID
          .set({
        'userFavorites': {
          restaurantId: {'isFavorite': true},
        },
      }, SetOptions(merge: true)); // Use merge to update existing data
    } catch (e) {
      print('Error adding favorite restaurant: $e');
    }
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
    } catch (e) {
      print('Error removing favorite restaurant: $e');
    }
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
      print('Error checking favorite restaurant: $e');
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
        print(favorites);
        return favorites;
      }

      return [];
    } catch (e) {
      print('Error getting favorite restaurants: $e');
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

      print('All Favorite Restaurant Data: $allFavoriteRestaurantData');
      return allFavoriteRestaurantData;
    } catch (e) {
      print('Error getting favorite restaurants: $e');
      return [];
    }
  }

  // Future<List<String>>? getAllFavoriteRestaurantsData(
  //     Future<List<String>>? favRestIdList) async {
  //   try {
  //     List<String> allFavoriteRestaurantData = [];

  //     if (favRestIdList != null) {
  //       List<String> restaurantIds = await favRestIdList;

  //       for (String restaurantId in restaurantIds) {
  //         final DocumentSnapshot restaurantDoc = await FirebaseFirestore
  //             .instance
  //             .collection('restaurants')
  //             .doc(restaurantId)
  //             .get();

  //         if (restaurantDoc.exists) {
  //           final Map<String, dynamic>? restaurantData =
  //               restaurantDoc.data() as Map<String, dynamic>?;
  //           print(restaurantData);

  //           final Map<String, dynamic>? favoriteRestaurantData =
  //               (restaurantData?['restaurantId'] as Map<String, dynamic>?);

  //           print(favoriteRestaurantData);

  //           List<String> data = favoriteRestaurantData!.keys.toList();
  //           allFavoriteRestaurantData.addAll(data);
  //         }
  //       }
  //     }
  //     print(allFavoriteRestaurantData);
  //     return allFavoriteRestaurantData;
  //   } catch (e) {
  //     print('Error getting favorite restaurants: $e');
  //     return [];
  //   }
  // }
}
