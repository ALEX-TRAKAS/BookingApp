import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/utils/loginTranslationMap.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookingapp/services/auth_service.dart';
import 'package:bookingapp/widgets/squareTile.dart';
import 'package:bookingapp/widgets/myButton.dart';
import 'package:bookingapp/widgets/myTextfield.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../utils/AppStyles.dart';

class loginScreen extends StatefulWidget {
  //final Function()? onTap;
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _login_screenState();
}

class _login_screenState extends State<loginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  void signUserIn() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    try {
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? user = authResult.user;

      if (user != null) {
        context.goNamed(navigationHubNameRoute);
      } else {
        _showErrorDialog('Η σύνδεση απέτυχε. Παρακαλώ προσπαθήστε ξανά.');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      print('FirebaseAuthException: ${e.message}');

      String errorMessage = firebaseErrorMessagesInGreek[e.code] ??
          'Προέκυψε ένα σφάλμα: ${e.message}';

      _showErrorDialog(errorMessage);
    } on PlatformException catch (e) {
    } catch (e) {
      _showErrorDialog('Προέκυψε ένα απρόσμενο σφάλμα: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Styles.secondaryColor,
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                const Icon(Icons.lock_person,
                    size: 150, color: Color(0xFF0F9B0F)),
                const SizedBox(height: 10),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 66.0),
                    child: Text(
                      'Εισαγάγετε τα διαπιστευτήριά σας για να συνεχίσετε.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                //username
                MyTextField(
                  controller: emailController,
                  hintText: 'Ηλεκτρονικό  Ταχυδρομείο',
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

                //sign in button
                MyButton(
                  onTap: signUserIn,
                  text: 'Σύνδεση',
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ξεχάσατε τον κωδικό πρόσβασής σας? ',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const Text(
                        'Επαναφορά κωδικού πρόσβασης.',
                        style: TextStyle(
                          color: primary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

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
                const SizedBox(height: 40),

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
                  height: 70,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Δεν έχεις λογαρμιασμό;',
                      style: TextStyle(color: Styles.textColor, fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () => context.goNamed(signupNameRoute),
                      child: const Text(
                        'Εγγραφή τώρα',
                        style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
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
