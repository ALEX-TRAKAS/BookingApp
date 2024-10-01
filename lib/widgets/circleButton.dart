import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.grey,
    required MaterialColor iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        iconSize: 30.0,
        splashRadius: 24.0,
        padding: const EdgeInsets.all(0.0),
        color: Colors.white,
        tooltip: 'Open menu',
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
    );
  }
}
