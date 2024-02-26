import 'package:flutter/material.dart';

class circle_box extends StatelessWidget {
  final Map<String, dynamic> circle;
  const circle_box({Key? key, required this.circle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Container(
            width: 75,
            height: 75,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
            margin: const EdgeInsets.only(
              right: 30,
              top: 5,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/${circle['image']}'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 10.0),
        Align(
          alignment: Alignment
              .center, // Align however you like (i.e .centerRight, centerLeft)
          child: Text(
            circle['cuisine'],
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
    // Container(
    //   width: 100,
    //   height: 100,
    //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
    //   margin: const EdgeInsets.only(
    //     right: 17,
    //     top: 5,
    //   ),
    //   decoration: BoxDecoration(
    //       shape: BoxShape.circle,
    //       image: DecorationImage(
    //         image: AssetImage('assets/images/${circle['image']}'),
    //         fit: BoxFit.cover,
    //       ),
    //       boxShadow: [
    //         BoxShadow(
    //             color: Colors.grey.shade200, blurRadius: 20, spreadRadius: 5),
    //       ]),
    //   child: Text(
    //     circle['cuisine'],
    //     style: TextStyle(
    //       fontSize: 16.0,
    //       fontWeight: FontWeight.bold,
    //     ),
    //   ),
    //   // InkWell(onTap: () {
    //   //   SimpleDialog(
    //   //     title: const Text('Select assignment'),
    //   //   );
    //   // }),
    //   // Column(
    //   //   crossAxisAlignment: CrossAxisAlignment.start,
    //   //   children: [
    //   //     CircleAvatar(
    //   //       radius: 32,
    //   //     ),
    //   //   ],
    //   // ),
    // );
  }
}
