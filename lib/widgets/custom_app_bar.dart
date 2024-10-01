// // custom_app_bar.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:gap/gap.dart';
// import '../utils/AppStyles.dart';
// import 'customDrawer.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final User? user;
//   final String displayName;
//   final String profilePicUrl;

//   CustomAppBar({
//     Key? key,
//     required this.user,
//     required this.displayName,
//     required this.profilePicUrl,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       surfaceTintColor: Colors.white,
//       shadowColor: Colors.white,
//       elevation: 0,
//       toolbarHeight: 90,
//       automaticallyImplyLeading: false,
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Image.asset(
//             'assets/images/logo.png',
//             height: 90,
//           ),
//           if (user == null)
//             // ElevatedButton(
//             //   onPressed: () => showLoginDialog(context),
//             //   style: ElevatedButton.styleFrom(
//             //     backgroundColor: Styles.primaryColor,
//             //     foregroundColor: Styles.primaryColor,
//             //     shape: RoundedRectangleBorder(
//             //       borderRadius: BorderRadius.circular(15),
//             //     ),
//             //   ),
//             //   child: const Text(
//             //     'Σύνδεση / Εγγραφή',
//             //     style: TextStyle(
//             //       color: Colors.white,
//             //     ),
//             //   ),
//             // )
//             Gap(1)
//           else
//             GestureDetector(
//               onTap: () {
//                 _scaffoldKey.currentState?.openEndDrawer();
//               },
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     displayName,
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleLarge
//                         ?.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(width: 10),
//                   CircleAvatar(
//                     backgroundColor: Styles.primaryColor,
//                     backgroundImage: profilePicUrl.isNotEmpty
//                         ? NetworkImage(profilePicUrl)
//                         : null,
//                     child: profilePicUrl.isEmpty
//                         ? const Icon(Icons.person, size: 25)
//                         : null,
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(90);
// }
