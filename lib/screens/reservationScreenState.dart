import 'package:bookingapp/utils/AppStyles.dart';
import 'package:bookingapp/utils/debouncer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ReservationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialRestaurants;
  final Function(List<Map<String, dynamic>>)? onSelectedRestaurants;
  const ReservationScreen({
    super.key,
    required this.initialRestaurants,
    this.onSelectedRestaurants,
  });
  @override
  _ReservationScreenState createState() => _ReservationScreenState();

  void _onSelectRestaurants(List<Map<String, dynamic>> selectedRestaurants) {
    if (onSelectedRestaurants != null) {
      onSelectedRestaurants!(selectedRestaurants);
    }
  }
}

class _ReservationScreenState extends State<ReservationScreen> {
  List<Map<String, dynamic>> restaurants = [];
  List<Map<String, dynamic>> filteredRestaurants = [];
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 0;
  int _selectedGuestsIndex = 0;
  final debouncer = Debouncer(delay: const Duration(milliseconds: 200));
  final List<Map<String, dynamic>> _dateOptions = [];
  final List<Map<String, dynamic>> _dateOptionsEng = [];
  final List<String> _timeOptions = [
    '01:00',
    '01:30',
    '02:00',
    '02:30',
    '03:00',
    '03:30',
    '04:00',
    '04:30',
    '05:00',
    '05:30',
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
    '22:00',
    '22:30',
    '23:00',
    '23:30',
  ];
  final List<String> _guestsOptions =
      List.generate(9, (index) => '${index + 1} άτομα');

  @override
  void initState() {
    super.initState();
    final startDate = DateTime.now();
    final endDate = DateTime.now().add(const Duration(days: 7));
    final days = getDaysInBetween(startDate, endDate);
    for (var i = 0; i < days.length; i++) {
      _dateOptions.add({
        'date': DateFormat('EEE dd MMM', 'el_GR').format(days[i]),
      });
    }
    for (var i = 0; i < days.length; i++) {
      _dateOptionsEng.add({
        'date': DateFormat('EEEE dd MMM', 'en_US').format(days[i]),
      });
    }
  }

  void filterRestaurants(String day, String selectedTime) {
    // Iterate through the list of restaurants
    for (var restaurant in widget.initialRestaurants) {
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
    print(filteredRestaurants);
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

  Future<void> fetchOpenRestaurants(int selectedDateIndex) async {
    // Get the selected date in English format
    String selectedDate = _dateOptions[selectedDateIndex]['date'];

    // Construct the query to fetch open restaurants for the selected date
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('restaurants')
        .where('openingHours.$selectedDate.isOpen', isEqualTo: true)
        .get();

    // Iterate through the query results
    for (var doc in querySnapshot.docs) {
      // Access each restaurant document
      Map<String, dynamic> restaurantData = doc.data();
      // Process the restaurant data as needed
      print('Restaurant: ${restaurantData['name']}');
    }
  }

  String extractDay(String dateString) {
    // Find the index of the first space
    int spaceIndex = dateString.indexOf(' ');

    // Extract the substring from the start of the string to the first space
    String day = dateString.substring(0, spaceIndex);

    return day.toLowerCase();
  }

  void _applyChanges() {
    print(_dateOptions[_selectedDateIndex]);
    String dateString = _dateOptionsEng[_selectedDateIndex]
        ["date"]; // Get the date string from the map
    String day = extractDay(dateString); // Extract the day from the date string
    print(_timeOptions[_selectedTimeIndex]);
    print(_guestsOptions[_selectedGuestsIndex]);
    filterRestaurants(day, _timeOptions[_selectedTimeIndex]);
    handleSelection(filteredRestaurants);
  }

  void handleSelection(List<Map<String, dynamic>> filteredRestaurants) {
    Navigator.pop(context, filteredRestaurants);
  }

  void _skipChanges() {
    // Close the widget when the "Skip" button is pressed
    Navigator.of(context).pop();
  }

  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
        color: Colors.white70,
      ),
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        children: [
          Row(
            children: [
              buildOptionListDates(
                _dateOptions,
                _selectedDateIndex,
                (index) => _selectedDateIndex = index,
              ),
              buildOptionList(
                _timeOptions,
                _selectedTimeIndex,
                (index) => _selectedTimeIndex = index,
                200,
                100,
              ),
              buildOptionList(
                _guestsOptions,
                _selectedGuestsIndex,
                (index) => _selectedGuestsIndex = index,
                200,
                150,
              ),
            ],
          ),
          const Gap(20), // Add spacing between list views and buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _applyChanges,
                style: ButtonStyle(
                  side: MaterialStateProperty.resolveWith<BorderSide>((states) {
                    return BorderSide(
                        color: Styles.primaryColor); // Outline border color
                  }),
                  foregroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    return Styles.primaryColor; // Text color
                  }),
                ),
                child: const Text('Apply'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _skipChanges,
                style: ButtonStyle(
                  side: MaterialStateProperty.resolveWith<BorderSide>((states) {
                    return BorderSide(
                        color: Styles.primaryColor); // Outline border color
                  }),
                  foregroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    return Styles.primaryColor; // Text color
                  }),
                ),
                child: const Text('Skip'),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOptionList(
      List<dynamic> options,
      int selectedIndex,
      void Function(int) onOptionSelected,
      double contHeight,
      double contWidth) {
    ScrollController scrollController = ScrollController();
    return SizedBox(
      height: contHeight, // Set the desired height here
      width: contWidth, // Set the width to fill the available space
      child: ListView.builder(
        controller: scrollController,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final optionValue = options[index];
          return GestureDetector(
            onTap: () {
              debouncer.run(() {
                setState(() {
                  onOptionSelected(index);
                });
                // Calculate the offset to scroll the selected item to the center
                final offset = (index * 44) -
                    (scrollController.position.viewportDimension / 2) +
                    (4 / 2);
                // Scroll to the calculated offset with animation
                scrollController.animateTo(offset,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: index == selectedIndex
                        ? Styles.primaryColor
                        : Colors.transparent,
                    width: 2.0, // Adjust the border width as needed
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Center(
                child: Text(
                  optionValue
                      .toString(), // Change this based on your data structure
                  style: TextStyle(
                    color: index == selectedIndex ? Colors.black : Colors.black,
                    fontSize: 18.0,
                    fontWeight: index == selectedIndex
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildOptionListDates(List<Map<String, dynamic>> options,
      int selectedIndex, void Function(int) onOptionSelected) {
    ScrollController scrollController = ScrollController();
    return SizedBox(
      height: 200, // Set the desired height here
      width: 150, // Set the width to fill the available space
      child: ListView.builder(
        controller: scrollController,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final optionValue = options[index]
              ['date']; // Change this based on your data structure
          return GestureDetector(
            onTap: () {
              debouncer.run(() {
                setState(() {
                  onOptionSelected(index);
                });
                // Calculate the offset to scroll the selected item to the center
                final offset = (index * 44) -
                    (scrollController.position.viewportDimension / 2) +
                    (4 / 2);
                // Scroll to the calculated offset with animation
                scrollController.animateTo(offset,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: index == selectedIndex
                        ? Styles.primaryColor
                        : Colors.transparent,
                    width: 2.0, // Adjust the border width as needed
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Center(
                child: Text(
                  optionValue
                      .toString(), // Change this based on your data structure
                  style: TextStyle(
                    color: index == selectedIndex ? Colors.black : Colors.black,
                    fontSize: 18.0,
                    fontWeight: index == selectedIndex
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
