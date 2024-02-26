import 'package:flutter/material.dart';
import '../utils/applayout.dart';

// ignore: must_be_immutable
class FilterScreen extends StatefulWidget {
  List<Map<String, dynamic>> initialValues = [];

  FilterScreen({Key? key, required this.initialValues}) : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<Map<String, dynamic>> filteredRestaurants = [];
  String selectedOption = 'ΕΠΙΛΟΓΗ';
  double _ratingsValue = 0.0;
  double _distanceValue = 0.5;
  double _minPriceValue = 0.0;
  double _maxPriceValue = 100.0;

  _onValueChanged(double value, String title) {
    if (mounted) {
      setState(() {
        switch (title) {
          case 'Ratings':
            _ratingsValue = value;
            break;
          case 'Distance':
            _distanceValue = value;
            break;
        }
      });
    }
  }

  onValueChanged(double minValue, double maxValue, String title) {
    if (mounted) {
      setState(() {
        switch (title) {
          case 'Ratings':
            _ratingsValue = minValue;
            break;
          case 'Distance':
            _distanceValue = minValue;
            break;
          case 'Average Price':
            _minPriceValue = minValue;
            _maxPriceValue = maxValue;
            break;
        }
      });
    }
  }

  void clearAll() {
    setState(() {
      _ratingsValue = 0.0;
      _distanceValue = 0.5;
      _minPriceValue = 0.0;
      _maxPriceValue = 100.0;
    });
  }

  void sortRestaurantsAscending(List<Map<String, dynamic>> _allRestaurants) {
    // Sort restaurants by avgPrice
    _allRestaurants.sort((a, b) {
      double? numericPriceA = double.tryParse(a['avgPrice'] ?? '');
      double? numericPriceB = double.tryParse(b['avgPrice'] ?? '');

      // Handle cases where parsing fails by treating them as equal
      if (numericPriceA == null) numericPriceA = double.infinity;
      if (numericPriceB == null) numericPriceB = double.infinity;

      return numericPriceA.compareTo(numericPriceB);
    });
    // Update the displayed restaurants
    filteredRestaurants = List.from(_allRestaurants);
  }

  void sortRestaurantsDescending(List<Map<String, dynamic>> _allRestaurants) {
    // Sort restaurants by avgPrice
    _allRestaurants.sort((b, a) {
      double? numericPriceA = double.tryParse(a['avgPrice'] ?? '');
      double? numericPriceB = double.tryParse(b['avgPrice'] ?? '');

      // Handle cases where parsing fails by treating them as equal
      if (numericPriceA == null) numericPriceA = double.infinity;
      if (numericPriceB == null) numericPriceB = double.infinity;

      return numericPriceA.compareTo(numericPriceB);
    });
    // Update the displayed restaurants
    filteredRestaurants = List.from(_allRestaurants);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: AppLayout.getScreenWidth(context),
          height: AppLayout.getScreenHeight(context),
          padding: const EdgeInsets.only(top: 40),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      iconSize: 40,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const Text(
                      "Φίλτρα",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        clearAll();
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: buildDropDownMenu(widget.initialValues),
                  //const Text(
                  //   'Your Content Goes Here',
                  //   style: TextStyle(fontSize: 20),
                  // ),
                ),
                _buildSliderRatings("Ratings", _ratingsValue),
                _buildSliderDistance("Distance", _distanceValue),
                _buildSliderAvgPrice(
                    "Average Price", _minPriceValue, _maxPriceValue),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderRatings(String title, double valueType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Δημοτικότητα : $valueType',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              valueIndicatorColor: Colors.blue, // Customize indicator color
              valueIndicatorTextStyle:
                  const TextStyle(color: Colors.white), // Customize text color
            ),
            child: Slider(
              value: valueType,
              onChanged: (double value) {
                _onValueChanged(value, title);
              },
              min: 0.0,
              max: 5.0,
              divisions: 5,
              label: '$valueType',
            ),
          ),
        ),
        Text(
          '$title : $valueType',
        )
      ],
    );
  }

  Widget _buildSliderDistance(String title, double valueType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Απόσταση : ${valueType.floorToDouble() / 2} Χλμ.',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Slider(
            value: valueType,
            onChanged: (double value) {
              _onValueChanged(value, title);
            },
            min: 0.5,
            max: 100.0,
            divisions: 100,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderAvgPrice(String title, double minValue, double maxValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Κόστος/άτομο : $minValue € - $maxValue €',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: RangeSlider(
            values: RangeValues(minValue, maxValue),
            onChanged: (RangeValues values) {
              onValueChanged(values.start, values.end, title);
            },
            min: 0.0,
            max: 100.0,
            divisions: 5,
            labels: RangeLabels('$minValue', '$maxValue'),
          ),
        ),
      ],
    );
  }

  Widget buildDropDownMenu(List<Map<String, dynamic>> restaurantsList) {
    return Center(
      child: Align(
        alignment: Alignment.topRight,
        child: DropdownButton<String>(
          value: selectedOption,
          onChanged: (String? newValue) {
            setState(() {
              selectedOption = newValue!;
              // Add logic to handle selected option
              if (selectedOption == 'Αύξουσα') {
                // Handle ascending logic
              } else if (selectedOption == 'Φθίνουσα') {
                // Handle descending logic
              }
            });
          },
          items: <String>['ΕΠΙΛΟΓΗ', 'Αύξουσα', 'Φθίνουσα']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
