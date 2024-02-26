import 'dart:async';
import 'package:bookingapp/routes/name_route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});
  @override
  State<splashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<splashScreen> {
  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        Timer(
          const Duration(seconds: 3),
          () => context.goNamed(authNameRoute),
        );
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          alignment: Alignment.center,
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.white,
            image: const DecorationImage(
              image: AssetImage('assets/images/splashlogo.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
