import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor; // Add this line

  const CircleIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.grey,
    required MaterialColor iconColor, // Set a default color or modify as needed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor, // Set the background color here
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        iconSize: 30.0,
        splashRadius: 24.0,
        padding: EdgeInsets.all(0.0),
        color: Colors.white, // Set the icon color here
        tooltip: 'Open menu',
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        // You can customize other properties as needed
      ),
    );
  }
}
