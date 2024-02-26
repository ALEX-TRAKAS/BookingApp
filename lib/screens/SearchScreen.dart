import 'package:bookingapp/screens/filterScreen.dart';
import 'package:bookingapp/services/databaseFunctions.dart';
import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../utils/appstyles.dart';
import 'package:gap/gap.dart';
import '../utils/filteringFunctions.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({
    Key? key,
  }) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController editingController = TextEditingController();
  ScrollController scrollViewController = ScrollController();
  bool isVisible = false;
  bool isLoading = false;
  bool isLoadingFlag = false;
  bool _buttonPressed = false;
  List<Map<String, dynamic>> restaurants = [];
  List<Map<String, dynamic>> _allRestaurants = [];
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 0;
  int _selectedGuestsIndex = 0;
  final debouncer = Debouncer(delay: Duration(milliseconds: 200));
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
    if (mounted) {
      super.initState();
      print('Init state of SearchScreen called.');
      getFromFirebase();
      final startDate = DateTime.now();
      final endDate = DateTime.now().add(Duration(days: 31));
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
  }

  @override
  void dispose() {
    editingController.dispose();
    scrollViewController.dispose();
    super.dispose();
  }

  Future<void> getFromFirebase() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final List<Map<String, dynamic>> fetchedRestaurants =
          await databaseFunctions.getFromFirebase();
      if (mounted) {
        setState(() {
          restaurants = fetchedRestaurants;
          _allRestaurants = List.from(restaurants);
        });
      }
    } catch (e) {
      print('Error fetching restaurants: $e');
      // Handle the error, show an error message, or retry
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void searchRestaurants(String query) {
    if (mounted) {
      setState(() {
        if (query.isEmpty) {
          // If the query is empty, show all restaurants
          restaurants = List.from(_allRestaurants);
        } else {
          // Filter restaurants based on the query from _allRestaurants
          restaurants = _allRestaurants.where((restaurant) {
            final restaurantName = restaurant['name'].toString().toLowerCase();
            final input = query.toLowerCase();
            return restaurantName.startsWith(input);
          }).toList();
        }
      });
    }
  }

  void updateRestaurants(List<Map<String, dynamic>> selectedRestaurants) {
    if (mounted) {
      setState(() {
        restaurants = selectedRestaurants;
        _allRestaurants = selectedRestaurants;
      });
    }
  }

  // void searchRestaurants(String query) {
  //   setState(() {
  //     if (query.isEmpty) {
  //       // If the query is empty, show all restaurants
  //       restaurants = List.from(_allRestaurants);
  //     } else {
  //       // Filter restaurants based on the query
  //       restaurants = _allRestaurants.where((restaurant) {
  //         final restaurantName = restaurant['name'].toString().toLowerCase();
  //         final input = query.toLowerCase();
  //         return restaurantName.startsWith(input);
  //       }).toList();
  //     }
  //   });
  // }

  void showFilterScreenDialog(
      BuildContext context, List<Map<String, dynamic>> initialValues) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterScreen(initialValues: initialValues);
      },
    );
  }

  void _applyChanges() {
    print(_dateOptions[_selectedDateIndex]);
    String dateString = _dateOptionsEng[_selectedDateIndex]
        ["date"]; // Get the date string from the map
    String day = extractDay(dateString); // Extract the day from the date string
    print(_timeOptions[_selectedTimeIndex]);
    print(_guestsOptions[_selectedGuestsIndex]);
    updateRestaurants(filterRestaurants(
        day, _timeOptions[_selectedTimeIndex], _allRestaurants));
  }

  void handleSelection(List<Map<String, dynamic>> filteredRestaurants) {
    Navigator.pop(context, filteredRestaurants);
  }

  void _skipChanges() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    isLoadingFlag = true;
    return Scaffold(
      appBar: AppBar(
        title: Text('Αναζήτηση'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Visibility(
              visible: !_buttonPressed, // Hide when button pressed
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      enabled: false,
                      controller: editingController,
                      decoration: InputDecoration(
                        labelText: "Αναζήτηση...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25.0)),
                          borderSide: BorderSide(
                            color: Styles.primaryColor,
                            width: 3.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: ElevatedButton.icon(
                        onPressed: null,
                        icon: Icon(Icons.filter_alt_rounded),
                        label: Text('Filters'),
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        color: Styles.primaryColor,
                        strokeWidth: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.grey, // Border color
                //     width: 1.0, // Border width
                //   ),
                //   borderRadius: BorderRadius.circular(10.0), // Border radius
                // ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: !_buttonPressed, // Hide when button pressed
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                      ),
                      Visibility(
                        visible: _buttonPressed, // Show when button pressed
                        child: buildFilteredList(context),
                      ),
                      Gap(20),
                      Visibility(
                        visible: !_buttonPressed, // Hide when button pressed
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _applyChanges();
                                  _buttonPressed = !_buttonPressed;
                                });
                              },
                              style: ButtonStyle(
                                side: MaterialStateProperty.resolveWith<
                                    BorderSide>((states) {
                                  return BorderSide(
                                    color: Styles.primaryColor,
                                  ); // Outline border color
                                }),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (states) {
                                  return Styles.primaryColor;
                                }), // Text color
                              ),
                              child: Text('Apply'),
                            ),
                            SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: _skipChanges,
                              style: ButtonStyle(
                                side: MaterialStateProperty.resolveWith<
                                    BorderSide>((states) {
                                  return BorderSide(
                                    color: Styles.primaryColor,
                                  ); // Outline border color
                                }),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (states) {
                                  return Styles.primaryColor;
                                }), // Text color
                              ),
                              child: Text('Skip'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilteredList(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                searchRestaurants(value);
              },
              controller: editingController,
              decoration: const InputDecoration(
                labelText: "Αναζήτηση...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton.icon(
                  onPressed: () {
                    showFilterScreenDialog(context, _allRestaurants);
                  },
                  icon: Icon(Icons.filter_alt_rounded),
                  label: Text('Filters'),
                  style: ButtonStyle(
                    side:
                        MaterialStateProperty.resolveWith<BorderSide>((states) {
                      return BorderSide(
                        color: Styles.primaryColor,
                      ); // Outline border color
                    }),
                    foregroundColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
                      return Styles.primaryColor;
                    }),
                    textStyle:
                        MaterialStateProperty.resolveWith<TextStyle>((states) {
                      return const TextStyle(
                        fontSize: 18, // Specify the desired font size here
                      );
                    }),
                  )),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: scrollViewController,
                    shrinkWrap: true,
                    itemExtent: 200.0,
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          context.pushNamed(
                            restaurantsDetailedScreenNameRoute,
                            queryParameters: {
                              'restaurantId':
                                  restaurants[index]['id'].toString(),
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
                                    restaurants[index]['name'],
                                    style: Styles.headLineStyle2
                                        .copyWith(color: Styles.textColor),
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
                                        '${restaurants[index]['Location']['city']}',
                                        style: Styles.headLineStyle2.copyWith(
                                          color: Styles.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(5),
                                  RatingBar.builder(
                                    initialRating: 3,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 25.0,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 1.0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Color(0xFF0F9B0F),
                                    ),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                    },
                                  ),
                                  const Gap(8),
                                  Text(
                                    restaurants[index]['avgPrice'] + '€',
                                    style: Styles.headLineStyle1.copyWith(
                                      color: Styles.textColor,
                                    ),
                                  ),
                                  Text(
                                    restaurants[index]['cuisine'],
                                    style: Styles.headLineStyle3.copyWith(
                                      color: Styles.textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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
    return Container(
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
                    duration: Duration(milliseconds: 500),
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
    return Container(
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
                    duration: Duration(milliseconds: 500),
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
