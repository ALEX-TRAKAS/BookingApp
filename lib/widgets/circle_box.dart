import 'package:bookingapp/routes/name_route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class circle_box extends StatelessWidget {
  final Map<String, dynamic> circle;
  const circle_box({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              InkWell(
                child: ClipOval(
                  child: Container(
                    width: 75,
                    height: 75,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 17),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      border: const Border(
                        top: BorderSide(
                            color: Color(0xFF0F9B0F),
                            width: 0.1,
                            style: BorderStyle.solid),
                        left: BorderSide(
                            color: Color(0xFF0F9B0F),
                            width: 0.1,
                            style: BorderStyle.solid),
                        bottom: BorderSide(
                            color: Color(0xFF0F9B0F),
                            width: 1.0,
                            style: BorderStyle.solid),
                        right: BorderSide(
                            color: Color(0xFF0F9B0F),
                            width: 0.1,
                            style: BorderStyle.solid),
                      ),
                      image: DecorationImage(
                        image: AssetImage('assets/images/${circle['image']}'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                onTap: () {
                  context.pushNamed(
                    homeSearchNameRoute,
                    queryParameters: {
                      'cuisine': circle['cuisine'].toString(),
                      'filterFlag': 'true',
                    },
                  );
                },
              ),
              const SizedBox(height: 5.0),
              Text(
                circle['cuisine'],
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
