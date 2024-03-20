import 'package:bookingapp/screens/LocationSearchScreen.dart';
import 'package:bookingapp/screens/detailedRestaurantScreen.dart';
import 'package:bookingapp/screens/ReservationsScreen.dart';
import 'package:bookingapp/screens/SearchScreen.dart';
import 'package:go_router/go_router.dart';
import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/screens/registerScreen.dart';
import 'package:bookingapp/screens/reservationScreen.dart';
import 'package:bookingapp/screens/splashScreen.dart';
import 'package:bookingapp/screens/loginScreen.dart';
import 'package:bookingapp/screens/errorScreen.dart';
import 'package:bookingapp/screens/navigationHub.dart';
import 'package:bookingapp/screens/HomeScreen.dart';
import 'package:bookingapp/screens/profileScreen.dart';
import 'package:bookingapp/screens/authGate.dart';

abstract class AppRouter {
  static GoRouter router() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const splashScreen(),
        ),
        GoRoute(
          name: authNameRoute,
          path: authRoute,
          builder: (context, state) => const authGate(),
        ),
        GoRoute(
          name: loginNameRoute,
          path: loginRoute,
          builder: (context, state) => const loginScreen(),
        ),
        GoRoute(
          name: homeNameRoute,
          path: homeRoute,
          builder: (context, state) => const HomeScreen(),
          routes: <RouteBase>[
            GoRoute(
              name: homeSearchNameRoute,
              path: homeSearchRoute,
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        GoRoute(
          name: profileNameRoute,
          path: profileRoute,
          builder: (context, state) => const profileScreen(),
        ),
        GoRoute(
          name: searchNameRoute,
          path: searchRoute,
          builder: (context, state) => const SearchScreen(),
          // routes: <RouteBase>[
          //   GoRoute(
          //     name: restaurantsDetailedScreenNameRoute,
          //     path: restaurantsDetailedScreenRoute,
          //     builder: (context, state) => DetailedRestaurantScreen(
          //       restaurantId: state.uri.queryParameters['restaurantId'],
          //     ),
          //   ),
          // ],
        ),
        GoRoute(
          name: signupNameRoute,
          path: signupRoute,
          builder: (context, state) => const registerScreen(),
        ),
        GoRoute(
          name: navigationHubNameRoute,
          path: navigationHubRoute,
          builder: (context, state) => const navigationHub(),
        ),
        GoRoute(
          name: reservationsNameRoute,
          path: reservationsRoute,
          builder: (context, state) => const ReservationsScreen(),
        ),
        // GoRoute(
        //   name: filterNameRoute,
        //   path: filterRoute,
        //   builder: (context, state) => const _FilterPageState(),
        // ),
        GoRoute(
          name: restaurantsDetailedScreenNameRoute,
          path: restaurantsDetailedScreenRoute,
          builder: (context, state) => DetailedRestaurantScreen(
            restaurantId: state.uri.queryParameters['restaurantId'],
          ),
        ),
        GoRoute(
          name: reservationScreenNameRoute,
          path: reservationScreenRoute,
          builder: (context, state) => reservationScreen(
            restaurantId: state.uri.queryParameters['restaurantId'],
          ),
        ),
        GoRoute(
          name: locationSearchScreenNameRoute,
          path: locationSearchScreenRoute,
          builder: (context, state) => const LocationSearchScreen(),
        ),
      ],
      errorBuilder: (context, state) => ErrorScreen(exception: state.error),
    );
  }
}
