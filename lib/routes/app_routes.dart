

import 'package:bookingapp/screens/register_screen.dart';
import 'package:bookingapp/screens/splash_screen.dart';
import 'package:bookingapp/screens/login_screen.dart';
import 'package:bookingapp/screens/home_screen.dart';
import 'package:bookingapp/screens/profile_screen.dart';
import 'package:bookingapp/screens/auth_gate.dart';
import 'package:get/get.dart';

class AppRoutes {


  static const String loginScreen = '/login_screen';

  static const String splashScreen = '/splash_screen';

  static const String homeScreen = '/home_screen';
    static const String profileScreen = '/profile_screen';
 
 static const String registerScreen = '/register_screen';

static const String auth = '/auth_gate';

  static List<GetPage> pages = [
      GetPage(
      name: auth,
      page: () => const auth_gate(),
    ),
    GetPage(
      name: loginScreen,
      page: () => const login_screen(),
    ),
    GetPage(
      name: registerScreen,
      page: () => const register_screen(),
    ),
    GetPage(
      name: homeScreen,
      page: () =>  home_screen(),
    ),
     GetPage(
      name: profileScreen,
      page: () =>  profile_screen(),
    ),
    GetPage(
      name: splashScreen,
      page: () => const SplashScreen(),
    )
  ];
}
