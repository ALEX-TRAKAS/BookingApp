import 'package:bookingapp/utils/AppStyles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/applayout.dart';

// ignore: must_be_immutable
class FilterScreen extends StatefulWidget {
  List<Map<String, dynamic>> initialValues = [];

  FilterScreen({super.key, required this.initialValues});

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
  List<String> selectedCuisines = [];
  Map<String, Object> selectedLocation = {};
  late double? lat;
  late double? lng;
  List<String> cuisines = [
    'Ελληνική',
    'Ιταλική',
    'Γαλλική',
    'Κινέζικη',
    'Ιαπωνική',
    'Μεξικάνικη',
  ];

  @override
  void initState() {
    loadLocationData();

    super.initState();
  }

  _onValueChanged(double value, String title) {
    if (mounted) {
      setState(() {
        switch (title) {
          case 'Ratings':
            _ratingsValue = value;
            applyFilters(widget.initialValues);
            break;
          case 'Distance':
            _distanceValue = value;
            applyFilters(widget.initialValues);
            break;
        }
      });
    }
  }

  onValueChanged(double minValue, double maxValue, String title) {
    if (mounted) {
      setState(() {
        switch (title) {
          case 'Average Price':
            _minPriceValue = minValue;
            _maxPriceValue = maxValue;
            applyFilters(widget.initialValues);
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
      selectedCuisines.clear();
      filteredRestaurants.clear();
    });
  }

  Future<void> loadLocationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("object");

    print(prefs.getStringList('selectedLocation') ?? []);
    List<String>? locationData = prefs.getStringList('selectedLocation');
    if (locationData != null && locationData.length >= 4) {
      selectedLocation = {
        'name': locationData[0],
        'formatted_address': locationData[1],
        'lat': double.parse(locationData[2]),
        'lng': double.parse(locationData[3]),
        'postal_code': locationData[4],
      };
      lat = double.tryParse(locationData[2]);
      lng = double.tryParse(locationData[3]);
    } else {}
  }

  void applyFilters(List<Map<String, dynamic>> allRestaurants) {
    filteredRestaurants.clear();

    switch (selectedOption) {
      case 'ΕΠΙΛΟΓΗ':
        break;
      case 'Δημοτικότητα':
        filteredRestaurants = sortRestaurantsAscendingByRatings(allRestaurants);
        break;
      case 'Κόστος':
        filteredRestaurants = sortRestaurantsAscending(allRestaurants);
        break;
    }

    List<Map<String, dynamic>> filteredByDistance =
        filterRestaurantsByDistance(allRestaurants, lat!, lng!, _distanceValue);
    List<Map<String, dynamic>> filteredByPrice =
        filterRestaurantsBetweenGivenPriceRanges(
            allRestaurants, _minPriceValue, _maxPriceValue);
    List<Map<String, dynamic>> filteredByRating =
        filterRestaurantsByRating(allRestaurants, _ratingsValue);
    List<Map<String, dynamic>> filteredByCuisines =
        filterRestaurantsByCuisines(allRestaurants);

    if (filteredByDistance.isNotEmpty) {
      // If there are restaurants within the distance range, apply intersection with other filters
      filteredRestaurants = filteredByDistance
          .toSet()
          .intersection(filteredRestaurants.toSet())
          .toList();
    } else {
      // If no restaurants are within the distance range, apply other filters independently
      filteredRestaurants = filteredByPrice
          .toSet()
          .intersection(filteredByRating.toSet())
          .toList();
    }

    // Apply intersection with cuisines filter if not empty
    if (filteredByCuisines.isNotEmpty) {
      filteredRestaurants = filteredRestaurants
          .toSet()
          .intersection(filteredByCuisines.toSet())
          .toList();
    } else {
      if (filteredByCuisines.isEmpty && selectedCuisines.isNotEmpty) {
        // Clear filtered results if there are selected cuisines but none match
        filteredRestaurants.clear();
      }
    }
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

  List<Map<String, dynamic>> filterRestaurantsByCuisines(
      List<Map<String, dynamic>> allRestaurants) {
    List<Map<String, dynamic>> filteredRestaurants = [];

    for (var restaurant in allRestaurants) {
      String cuisine = restaurant['cuisine'] ?? '';

      if (selectedCuisines.contains(cuisine)) {
        filteredRestaurants.add(restaurant);
      }
    }

    return filteredRestaurants;
  }

  List<Map<String, dynamic>> filterRestaurantsBetweenGivenPriceRanges(
      List<Map<String, dynamic>> allRestaurants, min, max) {
    List<Map<String, dynamic>> filteredRestaurants = [];
    for (var restaurant in allRestaurants) {
      double? price = double.tryParse(restaurant['avgPrice'] ?? '');
      if (price != null && price >= min && price <= max) {
        filteredRestaurants.add(restaurant);
      }
    }
    return filteredRestaurants;
  }

  List<Map<String, dynamic>> filterRestaurantsByRating(
      List<Map<String, dynamic>> allRestaurants, double sliderRatingValue) {
    List<Map<String, dynamic>> filteredRestaurants = [];
    for (var restaurant in allRestaurants) {
      double rating = (restaurant['rating'] as num).toDouble();
      if (rating >= sliderRatingValue) {
        if (!filteredRestaurants.contains(restaurant)) {
          filteredRestaurants.add(restaurant);
        }
      }
    }
    return filteredRestaurants;
  }

  List<Map<String, dynamic>> sortRestaurantsAscendingByRatings(
      List<Map<String, dynamic>> allRestaurants) {
    allRestaurants.sort((b, a) {
      double ratingA = a['rating'] ?? 0.0;
      double ratingB = b['rating'] ?? 0.0;
      return ratingA.compareTo(ratingB);
    });
    return List.from(allRestaurants);
  }

  List<Map<String, dynamic>> sortRestaurantsAscending(
      List<Map<String, dynamic>> allRestaurants) {
    allRestaurants.sort((a, b) {
      double? numericPriceA = double.tryParse(a['avgPrice'] ?? '');
      double? numericPriceB = double.tryParse(b['avgPrice'] ?? '');
      // Handle cases where parsing fails by treating them as equal
      numericPriceA ??= double.infinity;
      numericPriceB ??= double.infinity;
      return numericPriceA.compareTo(numericPriceB);
    });
    return List.from(allRestaurants);
  }

  void sortRestaurantsDescending(List<Map<String, dynamic>> allRestaurants) {
    // Sort restaurants by avgPrice
    allRestaurants.sort((b, a) {
      double? numericPriceA = double.tryParse(a['avgPrice'] ?? '');
      double? numericPriceB = double.tryParse(b['avgPrice'] ?? '');

      // Handle cases where parsing fails by treating them as equal
      numericPriceA ??= double.infinity;
      numericPriceB ??= double.infinity;

      return numericPriceA.compareTo(numericPriceB);
    });
    // Update the displayed restaurants
    setState(() {
      filteredRestaurants = List.from(allRestaurants);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Scrollbar(
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
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        ElevatedButton(
                            onPressed: () {
                              clearAll();
                            },
                            style: ButtonStyle(
                              side:
                                  MaterialStateProperty.resolveWith<BorderSide>(
                                      (states) {
                                return BorderSide(
                                  color: Styles.primaryColor,
                                );
                              }),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (states) {
                                return Colors.white;
                              }),
                              foregroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (states) {
                                return Styles.primaryColor;
                              }),
                              textStyle:
                                  MaterialStateProperty.resolveWith<TextStyle>(
                                      (states) {
                                return const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                );
                              }),
                            ),
                            child: const Text('Καθαρισμός')),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: buildDropDownMenu(widget.initialValues),
                    ),
                    _buildSliderRatings("Ratings", _ratingsValue),
                    _buildSliderDistance("Distance", _distanceValue),
                    _buildSliderAvgPrice(widget.initialValues, "Average Price",
                        _minPriceValue, _maxPriceValue),
                    const Divider(
                      color: Colors.grey,
                      thickness: 2,
                      height: 8,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Κουζίνες',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: Scrollbar(
                        child: ListView.builder(
                          itemCount: cuisines.length,
                          itemBuilder: (context, index) {
                            return CheckboxListTile(
                              title: Text(cuisines[index]),
                              activeColor: Colors.white,
                              checkColor: Styles.primaryColor,
                              value: selectedCuisines.contains(cuisines[index]),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value != null && value) {
                                    selectedCuisines.add(cuisines[index]);
                                    applyFilters(widget.initialValues);
                                  } else {
                                    selectedCuisines.remove(cuisines[index]);
                                    applyFilters(widget.initialValues);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 2,
                      height: 8,
                    ),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: filteredRestaurants.isNotEmpty
          ? SizedBox(
              height: 75.0,
              width: 150.0,
              child: FloatingActionButton(
                backgroundColor: Styles.primaryColor,
                onPressed: () {
                  Navigator.of(context).pop(filteredRestaurants);
                },
                child: Text(
                  "${filteredRestaurants.length} Εστιατόρια",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
              valueIndicatorColor: Styles.primaryColor,
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: Slider(
              activeColor: Styles.primaryColor,
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
            activeColor: Styles.primaryColor,
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

  Widget _buildSliderAvgPrice(List<Map<String, dynamic>> allRestaurants,
      String title, double minValue, double maxValue) {
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
            activeColor: Styles.primaryColor,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Ταξινόμηση κατά:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(50),
            Container(
              width: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButton<String>(
                dropdownColor: Colors.white,
                isExpanded: true,
                underline: Container(),
                value: selectedOption,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOption = newValue!;
                    if (selectedOption == 'Δημοτικότητα') {
                      applyFilters(widget.initialValues);
                    } else if (selectedOption == 'Κόστος') {
                      applyFilters(widget.initialValues);
                    }
                  });
                },
                items: <String>['ΕΠΙΛΟΓΗ', 'Δημοτικότητα', 'Κόστος']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
