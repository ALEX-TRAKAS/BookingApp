import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/services/databaseFunctions.dart';
import 'package:bookingapp/widgets/customDrawer.dart';
import 'package:bookingapp/widgets/webFooter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:bookingapp/utils/AppStyles.dart';
import 'package:bookingapp/services/auth_service.dart';
import 'package:go_router/go_router.dart';
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
  String lastName = '';
  String firstName = '';
  String phone = '';
  String email = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    print('Init state of profileScreen called.');
    print(user);
    loadData();
    super.initState();
  }

  Future<void> loadData() async {
    Map<String, dynamic>? userData =
        await databaseFunctions().getUserData(user!.uid);

    print(userData);
    setState(() {
      if (user!.photoURL == null) {
        profilePicUrl = '';
      } else {
        profilePicUrl = user!.photoURL.toString();
      }
      if (user!.displayName == null) {
        displayName = userData!['firstName'] + '\t' + userData!['lastName'];
        firstName = userData!['firstName'];
        lastName = userData!['lastName'];
      } else {
        displayName = user!.displayName!;
      }
      if (userData!['phone'] != null) {
        phone = userData['phone'];
      }
      if (userData!['email'] != null) {
        email = userData['email'];
      }
    });
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

  AppBar buildMobileAppBar() {
    return AppBar(
      title: const Text('Το προφίλ μου'),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.white,
    );
  }

  Widget buildMobileLayout() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    return PopScope(
        child: SafeArea(
            child: Scaffold(
      backgroundColor: Colors.white,
      drawerScrimColor: Colors.white,
      body: Column(
        children: [
          const Gap(20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
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
                                ? CachedNetworkImageProvider(profilePicUrl)
                                : null,
                            child: profilePicUrl.isEmpty
                                ? const Icon(Icons.person, size: 75)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(5),
                  Text(
                    displayName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Gap(40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Styles.secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Display Name: $displayName',
                            style: Theme.of(context).textTheme.bodyLarge),
                        const Gap(10),
                        Text('Last Name: $lastName',
                            style: Theme.of(context).textTheme.bodyLarge),
                        const Gap(10),
                        Text('First Name: $firstName',
                            style: Theme.of(context).textTheme.bodyLarge),
                        const Gap(10),
                        Text('Phone: $phone',
                            style: Theme.of(context).textTheme.bodyLarge),
                        const Gap(10),
                        Text('Email: $email',
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                  const Gap(30),
                  const Divider(height: 0),
                  ListTile(
                    title: const Text('Όροι'),
                    onTap: () {},
                  ),
                  const Divider(height: 0),
                  ListTile(
                    title: const Text('Απόρρητο & Πολιτική'),
                    onTap: () {},
                  ),
                  const Divider(height: 0),
                  ListTile(
                    title: const Text('Βοήθεια & Υποστήριξη'),
                    onTap: () {},
                  ),
                  const Divider(height: 0),
                  if (!kIsWeb)
                    ListTile(
                      title: const Text('Αποσύνδεση'),
                      onTap: () {
                        Authentication.signOutFromGoogle(context);
                      },
                    ),
                  const Divider(height: 0),
                  if (kIsWeb) webFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    )));
  }

  Widget buildWebLayout() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));

    return Column(
      children: [
        const Gap(20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
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
                                      ? CachedNetworkImageProvider(
                                          profilePicUrl)
                                      : null,
                                  child: profilePicUrl.isEmpty
                                      ? const Icon(Icons.person, size: 75)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(5),
                        Text(
                          displayName,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Gap(50),
                        const Divider(height: 0),
                        ListTile(
                          title: const Text('Όροι'),
                          onTap: () {},
                        ),
                        const Divider(height: 0),
                        ListTile(
                          title: const Text('Απόρρητο & Πολιτική'),
                          onTap: () {},
                        ),
                        const Divider(height: 0),
                        ListTile(
                          title: const Text('Βοήθεια & Υποστήριξη'),
                          onTap: () {},
                        ),
                        const Gap(60),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Styles.secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Display Name: $displayName',
                          style: Theme.of(context).textTheme.bodyLarge),
                      const Gap(10),
                      Text('Last Name: $lastName',
                          style: Theme.of(context).textTheme.bodyLarge),
                      const Gap(10),
                      Text('First Name: $firstName',
                          style: Theme.of(context).textTheme.bodyLarge),
                      const Gap(10),
                      Text('Phone: $phone',
                          style: Theme.of(context).textTheme.bodyLarge),
                      const Gap(10),
                      Text('Email: $email',
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (kIsWeb) webFooter(),
      ],
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
            if (constraints.maxWidth >= 905) {
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
}
