import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/utils/AppStyles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class ReservationCompleteDialog extends StatelessWidget {
  const ReservationCompleteDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                context.goNamed(webHomeScreenNameRoute);
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
