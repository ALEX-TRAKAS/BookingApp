import 'package:bookingapp/services/databaseFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class reservationScreen extends StatefulWidget {
  String? restaurantId = '';
  reservationScreen({
    Key? key,
    this.restaurantId,
  }) : super(key: key);

  @override
  _CreateReservationScreenState createState() =>
      _CreateReservationScreenState(restaurantId);
}

class _CreateReservationScreenState extends State<reservationScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  int _numberOfGuests = 1;
  late TextEditingController _dateTimeController;
  late TextEditingController _numberOfGuestsController;
  late TextEditingController _specialRequestsController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactPhoneNumberController;
  late TextEditingController _contactEmailController;
  late TextEditingController _tableAssignmentController;
  DateTime? _selectedDateTime;

  _CreateReservationScreenState(this.restaurantId);
  final restaurantId;
  final db = databaseFunctions();

  @override
  void initState() {
    super.initState();
    _dateTimeController = TextEditingController();
    _numberOfGuestsController = TextEditingController();
    _specialRequestsController = TextEditingController();
    _contactNameController = TextEditingController();
    _contactPhoneNumberController = TextEditingController();
    _contactEmailController = TextEditingController();
    _tableAssignmentController = TextEditingController();
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    _numberOfGuestsController.dispose();
    _specialRequestsController.dispose();
    _contactNameController.dispose();
    _contactPhoneNumberController.dispose();
    _contactEmailController.dispose();
    _tableAssignmentController.dispose();
    super.dispose();
  }

  Future<void> _selectNumberOfGuests(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Number of Guests'),
        content: Container(
          width: 300, // Adjust the width as needed
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(10, (index) {
                final number = index + 1;
                return Card(
                  elevation: 2, // Add elevation for a card-like effect
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Center(
                      child: Text(
                        '$number Guests',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue, // Customize the text color
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _numberOfGuests = number;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                );
              }),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<TimeOfDay?> _showCustomTimePicker(BuildContext context) async {
    TimeOfDay currentTime = TimeOfDay.now();
    int selectedHour = currentTime.hour;
    int selectedMinute = currentTime.minute;
    int roundedMinute = ((selectedMinute + 7) / 15).round() * 15 % 60;

    return showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Hour: '),
                  DropdownButton<int>(
                    value: selectedHour,
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          selectedHour = value;
                        });
                      }
                    },
                    items: List.generate(24, (index) {
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text('$index'),
                      );
                    }),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text('Minute: '),
                  DropdownButton<int>(
                    value: roundedMinute,
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          roundedMinute = value;
                        });
                      }
                    },
                    items: List.generate(60, (index) {
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text('$index'),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(TimeOfDay(hour: selectedHour, minute: roundedMinute));
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Reservation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Date and Time
            ListTile(
              title: Text('Date and Time'),
              subtitle: Text(
                _selectedDateTime != null
                    ? _selectedDateTime.toString()
                    : 'Select Date and Time',
              ),
              onTap: () async {
                DateTime? selectedDateTime = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (selectedDateTime != null) {
                  TimeOfDay? selectedTime =
                      await _showCustomTimePicker(context);
                  if (selectedTime != null) {
                    setState(() {
                      _selectedDateTime = DateTime(
                        selectedDateTime.year,
                        selectedDateTime.month,
                        selectedDateTime.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                    });
                  }
                }
              },
            ),
            ListTile(
              title: Text(
                'Number of Guests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '$_numberOfGuests',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () => _selectNumberOfGuests(context),
              tileColor: Colors.blue
                  .withOpacity(0.1), // Customize the background color
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10), // Customize the border radius
              ),
            ),

            // Special Requests
            TextFormField(
              controller: _specialRequestsController,
              decoration: InputDecoration(labelText: 'Special Requests'),
              maxLines: 3,
            ),

            // Contact Information
            TextFormField(
              controller: _contactNameController,
              decoration: InputDecoration(labelText: 'Contact Name'),
            ),
            TextFormField(
              controller: _contactPhoneNumberController,
              decoration: InputDecoration(labelText: 'Contact Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: _contactEmailController,
              decoration: InputDecoration(labelText: 'Contact Email'),
              keyboardType: TextInputType.emailAddress,
            ),

            // Table Assignment
            TextFormField(
              controller: _tableAssignmentController,
              decoration: InputDecoration(labelText: 'Table Assignment'),
            ),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                Timestamp? timestamp;
                if (_selectedDateTime != null) {
                  timestamp = Timestamp.fromDate(_selectedDateTime!);
                }
                db.createReservation(
                  reservationDateAndTime:
                      timestamp, // the selected date and time
                  numberOfGuests:
                      _numberOfGuests, // the selected number of guests
                  specialRequests:
                      _specialRequestsController.text, // special requests
                  contactName: _contactNameController.text, // contact name
                  contactPhoneNumber: _contactPhoneNumberController
                      .text, // contact phone number
                  contactEmail: _contactEmailController.text, // contact email
                  userID: user!.uid,
                  restaurantID: restaurantId,
                  reservationStatus: 'PENDING',
                  creationTimestamp: Timestamp.now(),
                  lastUpdatedTimestamp: Timestamp.now(),
                );
              },
              child: Text('Create Reservation'),
            ),
          ],
        ),
      ),
    );
  }
}
