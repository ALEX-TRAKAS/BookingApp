import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:bookingapp/utils/AppStyles.dart';
import 'package:bookingapp/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class profileScreen extends StatefulWidget {
  const profileScreen({super.key});

  @override
  _profileScreenState createState() => _profileScreenState();
}

class _profileScreenState extends State<profileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  String profilePicUrl = '';
  String displayName = '';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    print('Init state of profileScreen called.');
    loadDataFromLocalStorage();
    super.initState();
  }

  Future<void> loadDataFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profilePicUrl = prefs.getString('profilePicUrl') ?? '';
      displayName = prefs.getString('displayName') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircleAvatar(
                          backgroundColor: Styles.primaryColor,
                          backgroundImage: profilePicUrl.isNotEmpty
                              ? NetworkImage(profilePicUrl)
                              : null,
                          child: profilePicUrl == ''
                              ? const Icon(Icons.person, size: 75)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 0),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Surface color mapping.
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FloatingActionButton.large(
                                foregroundColor: Colors.black,
                                backgroundColor: primary,
                                onPressed: () {
                                  // Add your onPressed code here!
                                },
                                heroTag: "fab3",
                                child: const Icon(Icons.rate_review),
                              ),
                              const SizedBox(height: 20),
                              const Text("Κριτικές",
                                  style: TextStyle(
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Roboto',
                                      fontSize: 20)),
                            ],
                          ),
                          const Gap(20),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FloatingActionButton.large(
                                foregroundColor: Colors.black,
                                backgroundColor: primary,
                                onPressed: () {
                                  // Add your onPressed code here!
                                },
                                heroTag: "fab4",
                                child: const Icon(Icons.calendar_month),
                              ),
                              const SizedBox(height: 20),
                              const Text("Κρατήσεις",
                                  style: TextStyle(
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Roboto',
                                    fontSize: 20,
                                  )),
                            ],
                          ),
                          const Gap(20),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FloatingActionButton.large(
                                foregroundColor: Colors.black,
                                backgroundColor: primary,
                                onPressed: () {
                                  // Add your onPressed code here!
                                },
                                heroTag: "fab5",
                                child: const Icon(Icons.photo_camera),
                              ),
                              const SizedBox(height: 20),
                              const Text("Φωτογραφίες",
                                  style: TextStyle(
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Roboto',
                                      fontSize: 20)),
                            ],
                          ),
                        ],
                      ),
                      const Gap(20),
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          itemExtent: 40.0,
                          children: [
                            ListTile(
                              title: const Text('Όροι'),
                              onTap: () {
                                // Handle Όροι option
                              },
                            ),
                            const Divider(height: 0),
                            ListTile(
                              title: const Text('Απόρρητο & Πολιτική'),
                              onTap: () {
                                // Handle Απόρρητο & Πολιτική option
                              },
                            ),
                            const Divider(height: 0),
                            ListTile(
                              title: const Text('Βοήθεια & Υποστήριξη'),
                              onTap: () {
                                // Handle Βοήθεια & Υποστήριξη option
                              },
                            ),
                            const Divider(height: 0),
                            ListTile(
                              title: const Text('Αποσύνδεση'),
                              onTap: () {
                                // Handle Αποσύνδεση option
                                Authentication.signOutFromGoogle(context);
                              },
                            ),
                            const Divider(height: 0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
