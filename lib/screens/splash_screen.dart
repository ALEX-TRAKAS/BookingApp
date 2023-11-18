import 'dart:async';
import 'package:bookingapp/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
     Timer(const Duration(seconds: 3), 
     ()=> Get.toNamed(AppRoutes.auth),
     );
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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