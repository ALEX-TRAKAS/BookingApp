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
