import 'dart:convert';
import 'package:bookingapp/utils/appstyles.dart';
import 'package:bookingapp/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  void _searchLocation(String searchTerm) async {
    if (searchTerm.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    // final url =
    //     'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$searchTerm&types=geocode&language=el&key=$apiKey';
    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
        'input=$searchTerm&'
        'types=(regions)&'
        'components=country:gr&'
        'language=el&'
        'key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final List<dynamic> predictions = data['predictions'];

      setState(() {
        _searchResults = predictions;
      });
    } else {
      // Handle error
      print('Error: ${response.reasonPhrase}');
    }
  }

  void _getPlaceDetails(String placeId) async {
    final url = 'https://maps.googleapis.com/maps/api/place/details/json?'
        'place_id=$placeId&'
        'fields=name,formatted_address,geometry,address_components&'
        'key=$apiKey&'
        'language=el';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final Map<String, dynamic> result = data['result'];
      final List<dynamic> addressComponents = result['address_components'];
      print(result['address_components']);

      // Iterate through the address components to find the postal code
      String postalCode = '';
      for (var component in addressComponents) {
        final List<dynamic> types = component['types'];
        if (types.contains('postal_code')) {
          postalCode = component['long_name'];
          break;
        }
      }

      // Get other details like name, formatted address, and location
      final Map<String, dynamic> geometry = result['geometry'];
      final Map<String, dynamic> location = geometry['location'];
      final double lat = location['lat'];
      final double lng = location['lng'];
      final String name = result['name'];
      final String formattedAddress = result['formatted_address'];

      print(
          'Name: $name, Formatted Address: $formattedAddress, Latitude: $lat, Longitude: $lng, Postal Code: $postalCode');

      // Return selected location back to previous screen
      Navigator.pop(context, {
        'name': name,
        'formatted_address': formattedAddress,
        'lat': lat,
        'lng': lng,
        'postal_code': postalCode,
      });
    } else {
      // Handle error
      print('Error: ${response.reasonPhrase}');
    }
  }

  // void _getPlaceDetails(String placeId) async {
  //   final url =
  //       'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,formatted_address,geometry&key=$apiKey';

  //   final response = await http.get(Uri.parse(url));
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     print(response);
  //     final Map<String, dynamic> result = data['result'];
  //     final Map<String, dynamic> geometry = result['geometry'];
  //     final Map<String, dynamic> location = geometry['location'];
  //     final double lat = location['lat'];
  //     final double lng = location['lng'];
  //     final String name = result['name'];
  //     final String formattedAddress = result['formatted_address'];

  //     print(
  //         'Name: $name, Formatted Address: $formattedAddress, Latitude: $lat, Longitude: $lng');

  //     // Return selected location back to previous screen
  //     Navigator.pop(context, {
  //       'name': name,
  //       'formatted_address': formattedAddress,
  //       'lat': lat,
  //       'lng': lng,
  //     });
  //   } else {
  //     // Handle error
  //     print('Error: ${response.reasonPhrase}');
  //   }
  // }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Check if the widget is still mounted before updating the state
      // Check if placemarks is not empty and the first element is not null
      if (placemarks.isNotEmpty) {
        Placemark firstPlacemark =
            placemarks.first; // Access the first element safely

        // Check if any property of firstPlacemark is null
        if (firstPlacemark.name != null &&
            firstPlacemark.locality != null &&
            firstPlacemark.postalCode != null) {
          Navigator.pop(context, {
            'name': firstPlacemark.name!,
            'formatted_address': firstPlacemark.locality!,
            'lat': position.latitude,
            'lng': position.longitude,
            'postal_code': firstPlacemark.postalCode!,
          });
        }
      }
    } catch (e) {
      print('Error getting current location: $e');
    } finally {
      // Check if the widget is still mounted before updating the state
      if (mounted) {
        setState(() {
          _isLoading =
              false; // Set loading state to false when location fetching is complete
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Επίλεξε περιοχή'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search locations...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
                onChanged: _searchLocation,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Styles.primaryColor),
              ),
            ),
            child: ListTile(
              leading: Icon(Icons.my_location, color: Styles.primaryColor),
              title: const Text('Εύρεση της τρέχουσας τοποθεσίας σας'),
              onTap: () {
                _getCurrentLocation();
              },
            ),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(), // Show loading indicator
                )
              : Expanded(
                  child: _searchResults.isEmpty
                      ? const Center(
                          child: Text('No results found.'),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final prediction = _searchResults[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(color: Styles.primaryColor),
                                ),
                              ),
                              child: ListTile(
                                leading: Icon(Icons.location_on,
                                    color: Styles.primaryColor),
                                title: Text(prediction['description']),
                                onTap: () {
                                  _getPlaceDetails(prediction['place_id']);
                                },
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
