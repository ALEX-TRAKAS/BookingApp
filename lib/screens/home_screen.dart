import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookingapp/widgets/bottomNavbar.dart';


class home_screen extends StatelessWidget {
   home_screen({super.key});
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
   bottomNavigationBar: bottomNavigationBar(),
    );
  }
}