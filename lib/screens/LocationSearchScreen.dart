import 'dart:convert';
import 'package:bookingapp/utils/appstyles.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationSearchScreen extends StatefulWidget {
  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];

  void _searchLocation(String searchTerm) async {
    if (searchTerm.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    const apiKey =
        'AIzaSyATy0dmhFlGx-kopTHB6ePYIwJPuX5PD-E'; // Replace with your Google Places API key
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$searchTerm&types=geocode&language=el&key=$apiKey';

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
    const apiKey =
        'AIzaSyATy0dmhFlGx-kopTHB6ePYIwJPuX5PD-E'; // Replace with your Google Places API key
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,formatted_address,geometry&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final Map<String, dynamic> result = data['result'];
      final Map<String, dynamic> geometry = result['geometry'];
      final Map<String, dynamic> location = geometry['location'];
      final double lat = location['lat'];
      final double lng = location['lng'];
      final String name = result['name'];
      final String formattedAddress = result['formatted_address'];

      // Do something with lat and lng, such as storing them in variables or using them in further processing
      print(
          'Name: $name, Formatted Address: $formattedAddress, Latitude: $lat, Longitude: $lng');

      // Return selected location back to previous screen
      Navigator.pop(context, {
        'name': name,
        'formatted_address': formattedAddress,
        'lat': lat,
        'lng': lng,
      });
    } else {
      // Handle error
      print('Error: ${response.reasonPhrase}');
    }
  }
//to be done
  //  Future<void> _getCurrentLocation() async {
  //   try {
  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );

  //     List<Placemark> placemarks = await placemarkFromCoordinates(
  //       position.latitude,
  //       position.longitude,
  //     );
  //     print('geo data get method: ${placemarks.first}');
  //     // Limiting to the first result if available
  //     if (placemarks.isNotEmpty) {
  //       Placemark firstPlacemark = placemarks.first;
  //       // Save the last known location
  //       await _saveLastKnownLocation(
  //           position.latitude,
  //           position.longitude,
  //           firstPlacemark.country,
  //           firstPlacemark.locality,
  //           firstPlacemark.street);
  //     }
  //   } catch (e) {
  //     print('Error getting current location: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Επίλεξε περιοχή'),
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
                  hintText: 'Αναζήτηση τοποθεσίας...',
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
              leading: Icon(
                Icons.my_location,
                color: Styles.primaryColor,
              ),
              title: Text('Εύρεση της τρέχουσας τοποθεσίας σας'),
              onTap: () {
                // Add your specific function here
              },
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Text('No results found.'),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final prediction = _searchResults[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Styles.primaryColor),
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: Styles.primaryColor,
                          ),
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
}
