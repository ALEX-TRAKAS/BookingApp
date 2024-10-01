// ignore_for_file: use_build_context_synchronously

import 'package:bookingapp/routes/name_route.dart';
import 'package:bookingapp/screens/registerScreen.dart';
import 'package:bookingapp/utils/loginTranslationMap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookingapp/services/auth_service.dart';
import 'package:bookingapp/widgets/squareTile.dart';
import 'package:bookingapp/widgets/myButton.dart';
import 'package:bookingapp/widgets/myTextfield.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../utils/AppStyles.dart';

class LoginDialog extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginDialog({super.key, required this.onLoginSuccess});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signUserIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final loadingDialog = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final User? user = authResult.user;

      if (user != null) {
        widget.onLoginSuccess();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        _showErrorDialog('Η σύνδεση απέτυχε. Παρακαλώ προσπαθήστε ξανά.');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();

      String errorMessage = firebaseErrorMessagesInGreek[e.code] ??
          'Προέκυψε ένα σφάλμα: ${e.message}';

      _showErrorDialog(errorMessage);
    } catch (e) {
      Navigator.of(context).pop();
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

  void _showRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 600) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Stack(
                  children: [
                    const registerScreen(),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.close, size: 24),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Container(
                  color: Colors.white,
                  constraints: BoxConstraints(maxWidth: 600, maxHeight: 690),
                  child: Stack(
                    children: [
                      const registerScreen(),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 600) {
            return Container(
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(20),
              child: buildContent(),
            );
          } else {
            return Container(
              color: Colors.white,
              width: 600,
              height: 600,
              padding: const EdgeInsets.all(20),
              child: buildContent(),
            );
          }
        },
      ),
    );
  }

  Widget buildContent() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Συνδέσου στο λογαριασμό σου',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 25),
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Παρακαλώ εισάγετε το Email σας.';
                  }
                  // Additional email validation logic (e.g., regex) can be added here
                  return null;
                },
              ),
              const SizedBox(height: 15),
              MyTextField(
                controller: passwordController,
                hintText: 'Κωδικός',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Παρακαλώ εισάγετε τον κωδικό σας.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
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
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const Text(
                      'Επαναφορά κωδικού πρόσβασης.',
                      style: TextStyle(
                        color: primary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareTile(
                    onTap: () => Authentication.signInWithGoogle(context),
                    imagePath: 'assets/images/google.svg',
                    height: 70,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Δεν έχεις λογαριασμό;',
                    style: TextStyle(color: Styles.textColor, fontSize: 12),
                  ),
                  GestureDetector(
                    onTap: () => _showRegisterDialog(context),
                    child: const Text(
                      'Εγγραφή τώρα',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
