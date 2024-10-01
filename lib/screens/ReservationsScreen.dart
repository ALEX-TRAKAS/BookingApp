import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/utils/AppStyles.dart';
import 'package:bookingapp/widgets/MenuButton.dart';
import 'package:bookingapp/widgets/customDrawer.dart';
import 'package:bookingapp/widgets/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bookingapp/services/databaseFunctions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../widgets/webFooter.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  Future<List<Map<String, dynamic>>>? _reservations;
  final user = FirebaseAuth.instance.currentUser!;
  final db = databaseFunctions();
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? userData;
  String profilePicUrl = '';
  String displayName = '';

  @override
  void initState() {
    print('Init state of ReservationScreen called.');
    super.initState();
    _reservations = db.getAllReservations(user.uid);
    loadUserData();
  }

  Future<void> loadUserData() async {
    Map<String, dynamic>? userData =
        await databaseFunctions().getUserData(user.uid);

    print(userData);
    setState(() {
      if (user.photoURL == null) {
        profilePicUrl = '';
      } else {
        profilePicUrl = user.photoURL.toString();
      }
      if (user.displayName == null) {
        displayName = userData!['firstName'] + '\t' + userData!['lastName'];
      } else {
        displayName = user.displayName!;
      }
    });
  }

  Future<void> _cancelReservation(String reservationId) async {
    try {
      String status = "Ακυρωμένη";
      await db.updateReservationStatus(
          user.uid, reservationId, status.toString());

      setState(() {
        // Update the list of reservations
        _reservations = db.getAllReservations(user.uid);
      });
    } catch (e) {
      print(e);
    }
  }

  void _onButtonPressed(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        setState(() {
          _reservations = db.getAllReservations(user.uid);
        });
        break;
      case 1:
        setState(() {
          _reservations = db.getAllReservationsToday(user.uid);
        });
        break;
      case 2:
        setState(() {
          _reservations = db.getAllReservationseExceptToday(user.uid);
        });
        break;
    }
  }

  AppBar buildMobileAppBar() {
    return AppBar(
      title: const Text('Κρατήσεις'),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.white,
    );
  }

  AppBar buildWebAppBar() {
    final bool isMobileWidth = MediaQuery.of(context).size.width < 600;
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.white,
      elevation: 0,
      toolbarHeight: 90,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => {context.goNamed(authNameRoute)},
            child: Image.asset(
              'assets/images/logo.png',
              height: 90,
            ),
          ),
          const Text('Κρατήσεις'),
          if (user != null)
            GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isMobileWidth || !kIsWeb)
                    Text(
                      displayName,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Styles.primaryColor,
                    backgroundImage: profilePicUrl.isNotEmpty
                        ? NetworkImage(profilePicUrl)
                        : null,
                    child: profilePicUrl.isEmpty
                        ? const Icon(Icons.person, size: 25)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: buildWebAppBar(),
        endDrawer: user != null
            ? CustomDrawer(
                displayName: displayName, profilePicUrl: profilePicUrl)
            : null,
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return buildWebLayout();
            } else {
              return buildMobileLayout();
            }
          },
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: buildMobileAppBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return buildWebLayout();
            } else {
              return buildMobileLayout();
            }
          },
        ),
      );
    }
  }

  Widget buildWebLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Gap(20),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: MenuButton(
                        text: 'Ολές',
                        onPressed: () => _onButtonPressed(0),
                        isSelected: _selectedIndex == 0,
                      ),
                    ),
                    Expanded(
                      child: MenuButton(
                        text: 'Σημερινές',
                        onPressed: () => _onButtonPressed(1),
                        isSelected: _selectedIndex == 1,
                      ),
                    ),
                    Expanded(
                      child: MenuButton(
                        text: 'Προηγούμενες',
                        onPressed: () => _onButtonPressed(2),
                        isSelected: _selectedIndex == 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(20),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _reservations,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Δεν υπάρχουν κρατήσεις.'));
              } else {
                List<Map<String, dynamic>> reservations = snapshot.data!;
                return Center(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: 1000), // Set max width here
                    child: Column(
                      children: reservations.map((item) {
                        DateTime creationTimestamp =
                            (item['creationTimestamp'] as Timestamp).toDate();
                        DateTime dateTime =
                            (item['dateTime'] as Timestamp).toDate();

                        String formattedCreationTimestamp =
                            DateFormat('dd MMM yyyy, HH:mm', 'el')
                                .format(creationTimestamp);
                        String formattedDateTime =
                            DateFormat('dd MMM yyyy, HH:mm', 'el')
                                .format(dateTime);

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Styles.primaryColor),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(
                                  'Κατάσταση Κράτησης: ${item['reservationStatus']}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Roboto',
                                    fontSize: 20,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Όνομα Εστιατορίου: ${item['restaurantName']}',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Roboto',
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      'Αριθμός Ατόμων: ${item['numberOfGuests']}',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Roboto',
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      'Ώρα Κράτησης: $formattedDateTime',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Roboto',
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        context.pushNamed(
                                            restaurantsDetailedScreenNameRoute,
                                            queryParameters: {
                                              'restaurantId':
                                                  item['restaurantID']
                                            });
                                      },
                                      style: ButtonStyle(
                                        side: MaterialStateProperty.resolveWith<
                                            BorderSide>((states) {
                                          return BorderSide(
                                            color: Styles.primaryColor,
                                          );
                                        }),
                                        foregroundColor: MaterialStateProperty
                                            .resolveWith<Color>((states) {
                                          return Styles.primaryColor;
                                        }),
                                      ),
                                      child: const Text('Επανακράτηση'),
                                    ),
                                    const Gap(20),
                                    ElevatedButton(
                                      onPressed: item['reservationStatus'] ==
                                              'Ακυρωμένη'
                                          ? null
                                          : () async {
                                              bool confirm = await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Επιβεβαίωση Ακύρωσης'),
                                                    content: const Text(
                                                      'Είστε βέβαιοι ότι θέλετε να ακυρώσετε αυτήν την κράτηση;',
                                                      style: TextStyle(
                                                        fontFamily: 'Roboto',
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        style: ButtonStyle(
                                                          side: MaterialStateProperty
                                                              .resolveWith<
                                                                  BorderSide>(
                                                            (states) {
                                                              return BorderSide(
                                                                color: Styles
                                                                    .primaryColor,
                                                              );
                                                            },
                                                          ),
                                                          foregroundColor:
                                                              MaterialStateProperty
                                                                  .resolveWith<
                                                                      Color>(
                                                            (states) {
                                                              return Styles
                                                                  .primaryColor;
                                                            },
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(false);
                                                        },
                                                        child:
                                                            const Text('Άκυρο'),
                                                      ),
                                                      TextButton(
                                                        style: ButtonStyle(
                                                          side: MaterialStateProperty
                                                              .resolveWith<
                                                                  BorderSide>(
                                                            (states) {
                                                              return BorderSide(
                                                                color: Styles
                                                                    .primaryColor,
                                                              );
                                                            },
                                                          ),
                                                          foregroundColor:
                                                              MaterialStateProperty
                                                                  .resolveWith<
                                                                      Color>(
                                                            (states) {
                                                              return Styles
                                                                  .primaryColor;
                                                            },
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(true);
                                                        },
                                                        child:
                                                            const Text('Ναι'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (confirm == true) {
                                                await _cancelReservation(
                                                    item['id'].toString());
                                              }
                                            },
                                      style: ButtonStyle(
                                        side: MaterialStateProperty.resolveWith<
                                            BorderSide>((states) {
                                          return const BorderSide(
                                            color: Colors.red,
                                          );
                                        }),
                                        foregroundColor: MaterialStateProperty
                                            .resolveWith<Color>((states) {
                                          return Colors.red;
                                        }),
                                      ),
                                      child: const Text('Ακύρωση'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }
            },
          ),
          const Gap(20),
          webFooter(),
        ],
      ),
    );
  }

  Widget buildMobileLayout() {
    return SafeArea(
      child: Column(
        children: [
          const Gap(20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: MenuButton(
                    text: 'Ολές',
                    onPressed: () => _onButtonPressed(0),
                    isSelected: _selectedIndex == 0,
                  ),
                ),
                Flexible(
                  child: MenuButton(
                    text: 'Σημερινές',
                    onPressed: () => _onButtonPressed(1),
                    isSelected: _selectedIndex == 1,
                  ),
                ),
                Flexible(
                  child: MenuButton(
                    text: 'Προηγούμενες',
                    onPressed: () => _onButtonPressed(2),
                    isSelected: _selectedIndex == 2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _reservations,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('Δεν υπάρχουν κρατήσεις.'));
                      } else {
                        List<Map<String, dynamic>> reservations =
                            snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reservations.length,
                          itemBuilder: (context, index) {
                            final item = reservations[index];
                            DateTime creationTimestamp =
                                (item['creationTimestamp'] as Timestamp)
                                    .toDate();
                            DateTime dateTime =
                                (item['dateTime'] as Timestamp).toDate();

                            String formattedCreationTimestamp =
                                DateFormat('dd MMM yyyy, HH:mm', 'el')
                                    .format(creationTimestamp);
                            String formattedDateTime =
                                DateFormat('dd MMM yyyy, HH:mm', 'el')
                                    .format(dateTime);

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Styles.primaryColor),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Text(
                                      'Κατάσταση Κράτησης: ${item['reservationStatus']}',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Roboto',
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Όνομα Εστιατορίου: ${item['restaurantName']}',
                                          style: const TextStyle(
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Roboto',
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          'Αριθμός Ατόμων: ${item['numberOfGuests']}',
                                          style: const TextStyle(
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Roboto',
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          'Ώρα Κράτησης: $formattedDateTime',
                                          style: const TextStyle(
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Roboto',
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            context.pushNamed(
                                                restaurantsDetailedScreenNameRoute,
                                                queryParameters: {
                                                  'restaurantId':
                                                      item['restaurantID']
                                                });
                                          },
                                          style: ButtonStyle(
                                            side: MaterialStateProperty
                                                .resolveWith<BorderSide>(
                                                    (states) {
                                              return BorderSide(
                                                color: Styles.primaryColor,
                                              );
                                            }),
                                            foregroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                                        (states) {
                                              return Styles.primaryColor;
                                            }),
                                          ),
                                          child: const Text('Επανακράτηση'),
                                        ),
                                        const Gap(20),
                                        ElevatedButton(
                                          onPressed: item[
                                                      'reservationStatus'] ==
                                                  'Ακυρωμένη'
                                              ? null
                                              : () async {
                                                  bool confirm =
                                                      await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Επιβεβαίωση Ακύρωσης'),
                                                        content: const Text(
                                                          'Είστε βέβαιοι ότι θέλετε να ακυρώσετε αυτήν την κράτηση;',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Roboto',
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            style: ButtonStyle(
                                                              side: MaterialStateProperty
                                                                  .resolveWith<
                                                                      BorderSide>(
                                                                (states) {
                                                                  return BorderSide(
                                                                    color: Styles
                                                                        .primaryColor,
                                                                  );
                                                                },
                                                              ),
                                                              foregroundColor:
                                                                  MaterialStateProperty
                                                                      .resolveWith<
                                                                          Color>(
                                                                (states) {
                                                                  return Styles
                                                                      .primaryColor;
                                                                },
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(false);
                                                            },
                                                            child: const Text(
                                                                'Άκυρο'),
                                                          ),
                                                          TextButton(
                                                            style: ButtonStyle(
                                                              side: MaterialStateProperty
                                                                  .resolveWith<
                                                                      BorderSide>(
                                                                (states) {
                                                                  return BorderSide(
                                                                    color: Styles
                                                                        .primaryColor,
                                                                  );
                                                                },
                                                              ),
                                                              foregroundColor:
                                                                  MaterialStateProperty
                                                                      .resolveWith<
                                                                          Color>(
                                                                (states) {
                                                                  return Styles
                                                                      .primaryColor;
                                                                },
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(true);
                                                            },
                                                            child: const Text(
                                                                'Ναι'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );

                                                  if (confirm == true) {
                                                    await _cancelReservation(
                                                        item['id'].toString());
                                                  }
                                                },
                                          style: ButtonStyle(
                                            side: MaterialStateProperty
                                                .resolveWith<BorderSide>(
                                                    (states) {
                                              return const BorderSide(
                                                color: Colors.red,
                                              );
                                            }),
                                            foregroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                                        (states) {
                                              return Colors.red;
                                            }),
                                          ),
                                          child: const Text('Ακύρωση'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                  if (kIsWeb) webFooter()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
