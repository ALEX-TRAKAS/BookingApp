import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final bool isSelected;

  const MenuButton({
    required this.text,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.green : const Color(0xFFBDBDBD),
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.green : const Color(0xFFBDBDBD),
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
