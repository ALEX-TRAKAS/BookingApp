import 'package:bookingapp/services/databaseFunctions.dart';
import 'package:bookingapp/utils/AppStyles.dart';
import 'package:bookingapp/widgets/reservationCompleteScreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:validators/validators.dart' as validators;
import 'package:intl/intl.dart';

class ReservationDialog extends StatefulWidget {
  final String? restaurantId;

  const ReservationDialog({Key? key, required this.restaurantId})
      : super(key: key);

  @override
  _ReservationDialogState createState() => _ReservationDialogState();
}

class _ReservationDialogState extends State<ReservationDialog> {
  final User? user = FirebaseAuth.instance.currentUser;
  int _numberOfGuests = 0;
  late TextEditingController _dateTimeController;
  late TextEditingController _numberOfGuestsController;
  late TextEditingController _specialRequestsController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactPhoneNumberController;
  late TextEditingController _contactEmailController;
  late TextEditingController _tableAssignmentController;
  late Map<String, dynamic> data = {};
  String restaurantName = '';
  DateTime? _selectedDateTime;
  String selectedDay = '';
  Map<String, dynamic> restaurantOpeningHours = {};
  int selectedHour = TimeOfDay.now().hour;
  int roundedMinute = (TimeOfDay.now().minute >= 30) ? 30 : 0;
  final _formKey = GlobalKey<FormState>();
  final db = databaseFunctions();
  @override
  void initState() {
    super.initState();
    getRestaurantData();
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

  Map<String, String> getOpeningHours(Map<String, dynamic> data, String day) {
    Map<String, String> openingHoursMap = {};

    if (data.containsKey(day.toLowerCase())) {
      final Map<String, dynamic> dayData = data[day.toLowerCase()]!;
      if (dayData['isOpen'] == true) {
        String startTime = dayData['startTime'];
        String endTime = dayData['endTime'];

        openingHoursMap['startTime'] = startTime;
        openingHoursMap['endTime'] = endTime;
        openingHoursMap['status'] = 'Open';
      } else {
        openingHoursMap['status'] = 'Closed';
      }
    } else {
      openingHoursMap['status'] = 'Closed';
    }
    return openingHoursMap;
  }

  List<String> getOpenDays(Map<String, dynamic> data) {
    return data.keys.where((day) => data[day]['isOpen'] == true).toList();
  }

  Future<void> getRestaurantData() async {
    data = await db.getRestaurantDataSecond(widget.restaurantId);
    if (mounted) {
      setState(() {
        restaurantName = data['name'];
        restaurantOpeningHours = data['openingHours'];
        print(restaurantOpeningHours);
      });
    }
  }

  bool isFormValid() {
    _formKey.currentState?.validate() ?? false;
    return _contactNameController.text.isNotEmpty &&
        _contactPhoneNumberController.text.isNotEmpty &&
        _contactEmailController.text.isNotEmpty;
  }

  void _showValidationAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Παρακαλούμε συμπληρώστε όλα τα πεδία της φόρμας'),
          content: const Text(
              'Συμπληρώστε και επιλέξτε ημερομηνία, αριθμό ατόμων, όνομα, τηλέφωνο και email.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Εντάξει'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectNumberOfGuests(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Styles.primaryColor, // Change primary color
          hintColor: Styles.primaryColor, // Change accent color
          colorScheme: ColorScheme.light(
            primary: Styles.primaryColor, // Change primary color
          ),
        ),
        child: AlertDialog(
          title: const Text('Επιλέξτε Αριθμό Ατόμων'),
          content: SizedBox(
            width: 300, // Adjust the width as needed
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(10, (index) {
                  final number = index + 1;
                  return TextButton(
                    style: ButtonStyle(
                      side: MaterialStateProperty.resolveWith<BorderSide>(
                          (states) {
                        return BorderSide(
                          color: Styles.primaryColor,
                        );
                      }),
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        return Colors.white;
                      }),
                      foregroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        return Styles.primaryColor;
                      }),
                      textStyle: MaterialStateProperty.resolveWith<TextStyle>(
                          (states) {
                        return const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        );
                      }),
                    ),
                    child: Center(
                      child: Text(
                        '$number Άτομα',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              Styles.primaryColor, // Customize the text color
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _numberOfGuests = number;
                      });
                      Navigator.of(context).pop();
                    },
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
              child: const Text('Ακύρωση'),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    const Map<String, int> dayToWeekday = {
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
      'sunday': DateTime.sunday,
    };

    // List of days that the restaurant is open
    List<String> openDays = getOpenDays(restaurantOpeningHours);

    // Adjust initialDate to the next available open day if today is closed
    DateTime initialDate = DateTime.now();
    while (!openDays.any((openDay) =>
        initialDate.weekday == dayToWeekday[openDay.toLowerCase()])) {
      initialDate = initialDate.add(const Duration(days: 1));
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (DateTime day) {
        return openDays.any(
            (openDay) => day.weekday == dayToWeekday[openDay.toLowerCase()]);
      },
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Styles.primaryColor,
            hintColor: Styles.primaryColor,
            colorScheme: ColorScheme.light(
              primary: Styles.primaryColor,
            ),
          ),
          child: child!,
        );
      },
      locale: const Locale('el'), // Greek locale
    );

    return pickedDate;
  }

  Future<TimeOfDay?> _selectTimeSlot(
      BuildContext context, DateTime selectedDate) async {
    const Map<String, int> dayToWeekday = {
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
      'sunday': DateTime.sunday,
    };

    // Call the function to get opening hours
    Map<String, String> openingHours =
        getOpeningHours(restaurantOpeningHours, selectedDay);

    // Check if the restaurant is open for the selected day
    if (openingHours.containsKey('startTime') &&
        openingHours.containsKey('endTime')) {
      // Generate time slots within the opening hours
      List<String> timeSlots = [];

      // Parse start and end times
      int startHour = int.parse(openingHours['startTime']!.split(':')[0]);
      int startMinute = int.parse(openingHours['startTime']!.split(':')[1]);
      int endHour = int.parse(openingHours['endTime']!.split(':')[0]);
      int endMinute = int.parse(openingHours['endTime']!.split(':')[1]);

      // Get the current date and time
      DateTime now = DateTime.now();

      // Set the start time for the selected day
      DateTime selectedDayStartTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        startHour,
        startMinute,
      );

      // If the selected day is today and the current time is after the start time, adjust
      if (selectedDate
          .isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
        if (now.isAfter(selectedDayStartTime)) {
          selectedDayStartTime = now;
        }

        // Round up to the nearest 30-minute interval if it's today
        int minuteAdjustment = 30 - (selectedDayStartTime.minute % 30);
        selectedDayStartTime =
            selectedDayStartTime.add(Duration(minutes: minuteAdjustment));
      }

      // Initialize the end time for the selected day
      DateTime selectedDayEndTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        endHour,
        endMinute,
      );

      // Generate time slots until the end time
      while (selectedDayStartTime.isBefore(selectedDayEndTime) ||
          selectedDayStartTime.isAtSameMomentAs(selectedDayEndTime)) {
        String formattedTime = DateFormat('HH:mm').format(selectedDayStartTime);
        timeSlots.add(formattedTime);

        // Add 30 minutes to current time
        selectedDayStartTime =
            selectedDayStartTime.add(const Duration(minutes: 30));
      }

      return showDialog(
        context: context,
        builder: (context) => Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Styles.primaryColor,
            hintColor: Styles.primaryColor,
            colorScheme: ColorScheme.light(
              primary: Styles.primaryColor,
            ),
          ),
          child: AlertDialog(
            title: const Text('Επιλέξτε Ώρα'),
            content: SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: timeSlots.map((timeSlot) {
                    return TextButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.resolveWith<BorderSide>(
                            (states) {
                          return BorderSide(
                            color: Styles.primaryColor,
                          );
                        }),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
                          return Colors.white;
                        }),
                        foregroundColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
                          return Styles.primaryColor;
                        }),
                        textStyle: MaterialStateProperty.resolveWith<TextStyle>(
                            (states) {
                          return const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          );
                        }),
                      ),
                      onPressed: () {
                        List<String> parts = timeSlot.split(':');
                        int hour = int.parse(parts[0]);
                        int minute = int.parse(parts[1]);
                        TimeOfDay selectedTime =
                            TimeOfDay(hour: hour, minute: minute);
                        Navigator.of(context).pop(selectedTime);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Center(
                          child: Text(
                            timeSlot,
                            style: TextStyle(
                              fontSize: 16,
                              color: Styles.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Ακύρωση'),
              ),
            ],
          ),
        ),
      );
    } else {
      // Restaurant is closed for the selected day
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Επιλέξτε Ώρα'),
          content: const Text(
              'Το εστιατόριο είναι κλειστό για την επιλεγμένη ημέρα.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Κλείσιμο'),
            ),
          ],
        ),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ολοκλήρωση Κράτησης',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Divider(
            color: Styles.primaryColor,
            thickness: 2,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Date and Time
              ListTile(
                title: const Text(
                  'Ημερομηνία και Ώρα',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _selectedDateTime != null
                      ? DateFormat('dd/MM/yyyy HH:mm')
                          .format(_selectedDateTime!)
                      : 'Επιλέξτε Ημερομηνία και Ώρα',
                ),
                onTap: () async {
                  DateTime? selectedDateTime = await _selectDate(context);
                  if (selectedDateTime != null) {
                    selectedDay = DateFormat('EEEE').format(selectedDateTime);
                    TimeOfDay? selectedTime =
                        await _selectTimeSlot(context, selectedDateTime);

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
                tileColor: Styles.primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Gap(5),
              ListTile(
                title: const Text(
                  'Αριθμός ατόμων',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '$_numberOfGuests',
                  style: const TextStyle(fontSize: 16),
                ),
                onTap: () => _selectNumberOfGuests(context),
                tileColor: Styles.primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              TextFormField(
                controller: _contactNameController,
                decoration: InputDecoration(
                  labelText: 'Ονοματεπώνυμο Κράτησης',
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Styles.primaryColor, width: 2.0),
                  ),
                ),
              ),
              TextFormField(
                controller: _contactPhoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Τηλέφωνο Επικοινωνίας',
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Styles.primaryColor, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Αυτό το πεδίο είναι υποχρεωτικό.';
                  }
                  final phoneExp = RegExp(r'^\+?[1-9]\d{1,14}$');
                  if (!phoneExp.hasMatch(value)) {
                    return 'Παρακαλώ εισάγετε έναν έγκυρο αριθμό τηλεφώνου.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactEmailController,
                decoration: InputDecoration(
                  labelText: 'Email Επικοινωνίας',
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Styles.primaryColor, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Αυτό το πεδίο είναι υποχρεωτικό.';
                  }
                  if (!validators.isEmail(value)) {
                    return 'Παρακαλώ εισάγετε μια έγκυρη διεύθυνση email.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _specialRequestsController,
                decoration: InputDecoration(
                  labelText: 'Σχόλια Κράτησης',
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Styles.primaryColor, width: 2.0),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Ακύρωση'),
        ),
        ElevatedButton(
          onPressed: () {
            Timestamp? timestamp;
            if (_selectedDateTime != null && isFormValid()) {
              timestamp = Timestamp.fromDate(_selectedDateTime!);

              db.createReservation(
                reservationDateAndTime: timestamp,
                numberOfGuests: _numberOfGuests,
                specialRequests: _specialRequestsController.text,
                contactName: _contactNameController.text,
                contactPhoneNumber: _contactPhoneNumberController.text,
                contactEmail: _contactEmailController.text,
                userID: user!.uid,
                restaurantID: widget.restaurantId,
                restaurantName: restaurantName,
                reservationStatus: 'Εκκρεμής',
                creationTimestamp: Timestamp.now(),
                lastUpdatedTimestamp: Timestamp.now(),
              );
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const ReservationCompleteDialog();
                },
              );
            } else {
              _showValidationAlert(context);
            }
          },
          child: const Text('Ολοκλήρωση Κράτησης'),
        ),
      ],
    );
  }
}
