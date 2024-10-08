import 'package:bookingapp/screens/webHomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bookingapp/screens/loginScreen.dart';
import 'package:bookingapp/screens/navigationHub.dart';

class authGate extends StatelessWidget {
  const authGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        // If the user is already signed-in, use it as initial data
        initialData: FirebaseAuth.instance.currentUser,
        builder: (context, snapshot) {
          // User is not signed in
          if (!snapshot.hasData) {
            if (kIsWeb) {
              return const WebHomeScreen();
            } else {
              return const loginScreen();
            }
          }
          if (kIsWeb) {
            return const WebHomeScreen();
          } else {
            return const navigationHub();
          }
        });
  }
}
