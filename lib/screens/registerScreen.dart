import 'package:bookingapp/routes/name_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bookingapp/widgets/squareTile.dart';
import 'package:bookingapp/widgets/myButton.dart';
import 'package:bookingapp/widgets/myTextfield.dart';
import 'package:bookingapp/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:bookingapp/utils/AppStyles.dart';

class registerScreen extends StatefulWidget {
  //final Function()? onTap;
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

  void signUserUp() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      // check if both password and confirm pasword is same
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        final User? user = userCredential.user;
        // Check if the user already exists in Firestore
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        if (!userSnapshot.exists) {
          // Create a new user document in Firestore
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
            // Add any other user-related information you want to store
          });
        }
      } else {
        //show error password dont match
        genericErrorMessage("Οι κωδικοι δεν ταιριαζοθν!");
      }

      //pop the loading circle
      context.goNamed(loginNameRoute);
    } on FirebaseAuthException catch (e) {
      //pop the loading circle
      Navigator.pop(context);

      genericErrorMessage(e.code);
    }
  }

  void genericErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      // resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                //logo
                const Icon(
                  Icons.lock,
                  size: 100,
                  color: Color(0xFF0F9B0F),
                ),
                const SizedBox(height: 10),
                //welcome back you been missed
                const Text(
                  'Δημιουργία Λογαριασμού!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: firstNameController,
                  hintText: 'Όνομα',
                  obscureText: false,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: lastNameController,
                  hintText: 'Επίθετο',
                  obscureText: false,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: phoneController,
                  hintText: 'Αριθμός Τηλεφώνου',
                  obscureText: false,
                ),
                const SizedBox(height: 15),
                //username
                MyTextField(
                  controller: emailController,
                  hintText: 'Ηλεκτρονικό Ταχυδρομείο',
                  obscureText: false,
                ),
                const SizedBox(height: 15),
                //password
                MyTextField(
                  controller: passwordController,
                  hintText: 'Κωδικός',
                  obscureText: true,
                ),
                const SizedBox(height: 15),

                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Επιβεβαίωση Κωδικού',
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                //sign in button
                MyButton(
                  onTap: signUserUp,
                  text: 'Εγγραφή',
                ),
                const SizedBox(height: 20),

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
                // not a memeber ? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Έχεις ήδη λογαρμιασμό;',
                      style: TextStyle(color: Styles.textColor, fontSize: 12),
                    ),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
