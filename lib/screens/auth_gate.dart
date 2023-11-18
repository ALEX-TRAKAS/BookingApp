import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bookingapp/screens/login_screen.dart';
import 'package:bookingapp/screens/home_screen.dart';

class auth_gate extends StatelessWidget {
  const auth_gate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   return StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  // If the user is already signed-in, use it as initial data
  initialData: FirebaseAuth.instance.currentUser,
  builder: (context, snapshot) {
    // User is not signed in
    if (!snapshot.hasData) {
      return const login_screen();
    }

    // Render your application if authenticated
  return  home_screen();
  });
  
  }
}