import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/utils/AppStyles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class reservationCompleteScreen extends StatefulWidget {
  @override
  _ReservationCompleteScreen createState() => _ReservationCompleteScreen();
}

class _ReservationCompleteScreen extends State<reservationCompleteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Επιτυχής κράτηση'),
        backgroundColor: Styles.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              FontAwesomeIcons.circleCheck,
              color: Styles.primaryColor,
              size: 100.0,
            ),
            const SizedBox(height: 30.0),
            const Text(
              'Η κράτηση ολοκληρώθηκε με επιτυχία!',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                context.goNamed(navigationHubNameRoute);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
