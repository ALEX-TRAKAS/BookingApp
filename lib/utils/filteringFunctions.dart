import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

List<Map<String, dynamic>> filterRestaurants(String day, String selectedTime,
    List<Map<String, dynamic>> initialRestaurants) {
  List<Map<String, dynamic>> filteredRestaurants = [];
  // Iterate through the list of restaurants
  for (var restaurant in initialRestaurants) {
    // Extract the opening hours for the selected date
    Map<String, dynamic> openingHours = restaurant['openingHours'][day];
    if (openingHours['isOpen'] == true) {
      if (isTimeInRange(
          selectedTime, openingHours['startTime'], openingHours['endTime'])) {
        filteredRestaurants.add(restaurant);
        print(openingHours);
      }
    }
  }
  print(filteredRestaurants.length);
  return filteredRestaurants;
}

List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
  List<DateTime> days = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    days.add(startDate.add(Duration(days: i)));
  }
  return days;
}

bool isTimeInRange(String selectedTime, String startTime, String endTime) {
  // Convert time strings to DateTime objects
  DateTime selectedDateTime = DateTime.parse('2024-01-01 $selectedTime');
  DateTime startDateTime = DateTime.parse('2024-01-01 $startTime');
  DateTime endDateTime = DateTime.parse('2024-01-01 $endTime');

  // Check if the selected time is within the range
  return selectedDateTime.isAtSameMomentAs(startDateTime) ||
      (selectedDateTime.isAfter(startDateTime) &&
          selectedDateTime.isBefore(endDateTime));
}

String extractDay(String dateString) {
  // Find the index of the first space
  int spaceIndex = dateString.indexOf(' ');
  // Extract the substring from the start of the string to the first space
  String day = dateString.substring(0, spaceIndex);

  return day.toLowerCase();
}

List<Map<String, dynamic>> filterRestaurantsByCuisines(
    List<Map<String, dynamic>> allRestaurants, String? selectedCuisine) {
  List<Map<String, dynamic>> filteredRestaurants = [];

  for (var restaurant in allRestaurants) {
    String cuisine = restaurant['cuisine'] ?? '';

    if (selectedCuisine == cuisine) {
      filteredRestaurants.add(restaurant);
    }
  }

  return filteredRestaurants;
}

List<Map<String, dynamic>> filterRestaurantsByDistance(
    List<Map<String, dynamic>> restaurants,
    double centerLat,
    double centerLon,
    double maxDistance) {
  List<Map<String, dynamic>> nearbyRestaurants = [];
  double restaurantLat;
  double restaurantLon;

  for (var restaurant in restaurants) {
    var location = restaurant['Location'];
    if (location != null) {
      var coordinates = location['coordinates'] as GeoPoint?;
      if (coordinates != null) {
        var coordinates = location['coordinates'] as GeoPoint;
        restaurantLat = coordinates.latitude;
        restaurantLon = coordinates.longitude;
        double distance = Geolocator.distanceBetween(
            centerLat, centerLon, restaurantLat, restaurantLon);

        if (distance <= maxDistance * 1000) {
          nearbyRestaurants.add(restaurant);
        }
      }
    }
  }

  return nearbyRestaurants;
}

List<Map<String, dynamic>> filterRestaurantsByRating(
    List<Map<String, dynamic>> allRestaurants, double RatingValue) {
  List<Map<String, dynamic>> filteredRestaurants = [];
  for (var restaurant in allRestaurants) {
    double rating = restaurant['rating'] ?? 0.0;
    if (rating >= RatingValue) {
      if (!filteredRestaurants.contains(restaurant)) {
        filteredRestaurants.add(restaurant);
      }
    }
  }
  return filteredRestaurants;
}
