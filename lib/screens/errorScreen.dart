import 'package:flutter/material.dart';
import 'package:bookingapp/routes/name_route.dart';
import 'package:go_router/go_router.dart';

class ErrorScreen extends StatelessWidget {
  final Exception? exception;
  const ErrorScreen({
    super.key,
    this.exception,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SelectableText(exception.toString()),
            TextButton(
                onPressed: () => context.goNamed(navigationHubNameRoute),
                child: const Text('Home'))
          ],
        ),
      ),
    );
  }
}
