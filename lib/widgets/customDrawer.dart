import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/services/auth_service.dart';
import 'package:bookingapp/utils/AppStyles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomDrawer extends StatelessWidget {
  final String displayName;
  final String profilePicUrl;

  CustomDrawer({
    required this.displayName,
    required this.profilePicUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shadowColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            accountName: Text(displayName,
                style: TextStyle(color: Colors.black, fontSize: 20)),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage:
                  profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : null,
              child: profilePicUrl.isEmpty
                  ? const Icon(Icons.person, size: 75)
                  : null,
            ),
          ),
          ListTile(
            leading: Icon(Icons.calendar_month),
            title: Text('Κρατήσεις'),
            onTap: () {
              context.goNamed(reservationsNameRoute);
            },
          ),
          const Divider(
            thickness: 1.0,
          ),
          ListTile(
            leading: Icon(Icons.bookmark),
            title: Text('Αγαπημένα'),
            onTap: () {
              context.goNamed(favoritesNameRoute);
            },
          ),
          const Divider(
            thickness: 1.0,
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Προφίλ'),
            onTap: () {
              context.goNamed(profileNameRoute);
            },
          ),
          const Divider(
            thickness: 1.0,
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: const Text('Αποσύνδεση'),
            onTap: () {
              // Handle Αποσύνδεση option
              Authentication.signOutFromGoogle(context);
              context.goNamed(webHomeScreenNameRoute);
            },
          ),
        ],
      ),
    );
  }
}
