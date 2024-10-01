// ignore_for_file: use_build_context_synchronously

import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/utils/registerTranslationMap.dart';
import 'package:bookingapp/utils/validationFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bookingapp/widgets/squareTile.dart';
import 'package:bookingapp/widgets/myButton.dart';
import 'package:bookingapp/widgets/myTextfield.dart';
import 'package:bookingapp/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:bookingapp/utils/AppStyles.dart';

class registerScreen extends StatefulWidget {
  const registerScreen({super.key});

  @override
  State<registerScreen> createState() => _register_screenState();
}

class _register_screenState extends State<registerScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // void signUserUp(BuildContext dialogContext) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return const Center(
  //         child: CircularProgressIndicator(),
  //       );
  //     },
  //   );
  //   try {
  //     // check if both password and confirm password are the same
  //     if (passwordController.text == confirmPasswordController.text) {
  //       UserCredential userCredential =
  //           await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //         email: emailController.text,
  //         password: passwordController.text,
  //       );
  //       final User? user = userCredential.user;
  //       // Check if the user already exists in Firestore
  //       final userSnapshot = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(user!.uid)
  //           .get();
  //       if (!userSnapshot.exists) {
  //         // Create a new user document in Firestore
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(user.uid)
  //             .set({
  //           'displayName': user.displayName,
  //           'firstName': firstNameController.text,
  //           'lastName': lastNameController.text,
  //           'phone': phoneController.text,
  //           'email': user.email,
  //           'photoURL': user.photoURL,
  //         });
  //       }
  //       Navigator.pop(context); // Close the loading circle
  //       await FirebaseAuth.instance.signOut();
  //       if (kIsWeb) {
  //         // Close the dialog and navigate to home on the web
  //         Navigator.of(dialogContext).pop();
  //         context.goNamed('home');
  //       } else {
  //         // Navigate to the login screen on other platforms
  //         context.goNamed(loginNameRoute);
  //       }
  //     } else {
  //       Navigator.pop(context); // Close the loading circle
  //       genericErrorMessage("Οι κωδικοί δεν ταιριάζουν!");
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     Navigator.pop(context); // Close the loading circle
  //     genericErrorMessage(e.code);
  //   }
  // }

  void signUserUp(BuildContext dialogContext) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      // check if both password and confirm password are the same
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        final User? user = userCredential.user;

        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        if (!userSnapshot.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'displayName': user.displayName,
            'firstName': firstNameController.text,
            'lastName': lastNameController.text,
            'phone': phoneController.text,
            'email': user.email,
            'photoURL': user.photoURL,
          });
        }
        Navigator.pop(context); // Close the loading circle
        await FirebaseAuth.instance.signOut();
        if (kIsWeb) {
          Navigator.of(dialogContext).pop();
          context.goNamed('home');
        } else {
          context.goNamed(loginNameRoute);
        }
      } else {
        Navigator.pop(context); // Close the loading circle
        genericErrorMessage("Οι κωδικοί δεν ταιριάζουν!");
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the loading circle
      genericErrorMessage(e.code);
    }
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
      return 'Οι κωδικοί δεν ταιριάζουν.';
    }
    return null;
  }

  // void genericErrorMessage(String message) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text(message),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  void genericErrorMessage(String errorCode) {
    String errorMessage = registerTranslationMap[errorCode] ??
        'Κάτι πήγε στραβά. Παρακαλώ προσπαθήστε ξανά.';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Styles.secondaryColor,
          title: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: const Color.fromARGB(255, 243, 243, 243),
  //     // resizeToAvoidBottomInset: true,
  //     body: SafeArea(
  //       child: SingleChildScrollView(
  //         child: Center(
  //           child: Column(
  //             // mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               const SizedBox(height: 10),
  //               //logo
  //               if (kIsWeb) ...[
  //                 const Icon(
  //                   Icons.lock,
  //                   size: 70,
  //                   color: Color(0xFF0F9B0F),
  //                 ),
  //               ],
  //               if (!kIsWeb) ...[
  //                 const Icon(
  //                   Icons.lock,
  //                   size: 90,
  //                   color: Color(0xFF0F9B0F),
  //                 ),
  //               ],
  //               const SizedBox(height: 10),
  //               const Text(
  //                 'Δημιουργία Λογαριασμού!',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                     color: primary,
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.w700),
  //               ),
  //               const SizedBox(height: 25),
  //               MyTextField(
  //                 controller: firstNameController,
  //                 hintText: 'Όνομα',
  //                 obscureText: false,
  //               ),
  //               const SizedBox(height: 15),
  //               MyTextField(
  //                 controller: lastNameController,
  //                 hintText: 'Επίθετο',
  //                 obscureText: false,
  //               ),
  //               const SizedBox(height: 15),
  //               MyTextField(
  //                 controller: phoneController,
  //                 hintText: 'Αριθμός Τηλεφώνου',
  //                 obscureText: false,
  //               ),
  //               const SizedBox(height: 15),
  //               //username
  //               MyTextField(
  //                 controller: emailController,
  //                 hintText: 'Ηλεκτρονικό Ταχυδρομείο',
  //                 obscureText: false,
  //               ),
  //               const SizedBox(height: 15),
  //               //password
  //               MyTextField(
  //                 controller: passwordController,
  //                 hintText: 'Κωδικός',
  //                 obscureText: true,
  //               ),
  //               const SizedBox(height: 15),

  //               MyTextField(
  //                 controller: confirmPasswordController,
  //                 hintText: 'Επιβεβαίωση Κωδικού',
  //                 obscureText: true,
  //               ),
  //               const SizedBox(height: 10),

  //               //sign in button
  //               MyButton(
  //                 onTap: () => signUserUp(context),
  //                 text: 'Εγγραφή',
  //               ),

  //               const SizedBox(height: 20),
  //               if (!kIsWeb) ...[
  //                 // continue with
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 25),
  //                   child: Row(
  //                     children: [
  //                       Expanded(
  //                         child: Divider(
  //                           thickness: 0.5,
  //                           color: Colors.grey.shade400,
  //                         ),
  //                       ),
  //                       Padding(
  //                         padding: const EdgeInsets.only(left: 8, right: 8),
  //                         child: Text(
  //                           'ή σύνδεση μέσω',
  //                           style: TextStyle(color: Styles.textColor),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: Divider(
  //                           thickness: 0.5,
  //                           color: Colors.grey.shade400,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 //google button
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     //google button
  //                     SquareTile(
  //                       onTap: () => Authentication.signInWithGoogle(context),
  //                       imagePath: 'assets/images/google.svg',
  //                       height: 70,
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //               ],
  //               // not a memeber ? register now
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text(
  //                     'Έχεις ήδη λογαρμιασμό;',
  //                     style: TextStyle(color: Styles.textColor, fontSize: 12),
  //                   ),
  //                   if (!kIsWeb) ...[
  //                     GestureDetector(
  //                       onTap: () => context.goNamed(loginNameRoute),
  //                       child: const Text(
  //                         'Σύνδεση',
  //                         style: TextStyle(
  //                             color: primary,
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 14),
  //                       ),
  //                     ),
  //                   ],
  //                   if (kIsWeb) ...[
  //                     GestureDetector(
  //                       onTap: () => Navigator.of(context).pop(),
  //                       child: const Text(
  //                         'Σύνδεση',
  //                         style: TextStyle(
  //                             color: primary,
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 14),
  //                       ),
  //                     ),
  //                   ],
  //                 ],
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formKey, // Add form key
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  if (kIsWeb) ...[
                    const Icon(
                      Icons.lock,
                      size: 70,
                      color: Color(0xFF0F9B0F),
                    ),
                  ],
                  if (!kIsWeb) ...[
                    const Icon(
                      Icons.lock,
                      size: 90,
                      color: Color(0xFF0F9B0F),
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Text(
                    'Δημιουργία Λογαριασμού!',
                    style: TextStyle(
                        color: primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 25),

                  // First Name
                  MyTextField(
                    controller: firstNameController,
                    hintText: 'Όνομα',
                    obscureText: false,
                    validator: validateName,
                  ),
                  const SizedBox(height: 15),

                  // Last Name
                  MyTextField(
                    controller: lastNameController,
                    hintText: 'Επίθετο',
                    obscureText: false,
                    validator: validateLastName,
                  ),
                  const SizedBox(height: 15),

                  // Phone Number
                  MyTextField(
                    controller: phoneController,
                    hintText: 'Αριθμός Τηλεφώνου',
                    obscureText: false,
                    validator: validatePhone,
                  ),
                  const SizedBox(height: 15),

                  // Email
                  MyTextField(
                    controller: emailController,
                    hintText: 'Ηλεκτρονικό Ταχυδρομείο',
                    obscureText: false,
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 15),

                  // Password
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Κωδικός',
                    obscureText: true,
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 15),

                  // Confirm Password
                  MyTextField(
                    controller: confirmPasswordController,
                    hintText: 'Επιβεβαίωση Κωδικού',
                    obscureText: true,
                    validator: validateConfirmPassword,
                  ),
                  const SizedBox(height: 10),

                  // Sign Up Button
                  MyButton(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        // Proceed with sign-up
                        signUserUp(context);
                      }
                    },
                    text: 'Εγγραφή',
                  ),
                  const SizedBox(height: 20),

                  const SizedBox(height: 20),
                  if (!kIsWeb) ...[
                    // continue with
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Text(
                              'ή σύνδεση μέσω',
                              style: TextStyle(color: Styles.textColor),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    //google button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //google button
                        SquareTile(
                          onTap: () => Authentication.signInWithGoogle(context),
                          imagePath: 'assets/images/google.svg',
                          height: 70,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                  // not a memeber ? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Έχεις ήδη λογαρμιασμό;',
                        style: TextStyle(color: Styles.textColor, fontSize: 12),
                      ),
                      if (!kIsWeb) ...[
                        GestureDetector(
                          onTap: () => context.goNamed(loginNameRoute),
                          child: const Text(
                            'Σύνδεση',
                            style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                      ],
                      if (kIsWeb) ...[
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Σύνδεση',
                            style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                      ],
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
