import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primary = const Color(0xFF0F9B0F);

class Styles {
  final primaryFont = GoogleFonts.roboto;
  static Color primaryColor = primary;
  static Color textColor = Color(0xFF262626);
  static Color bgColor = Color.fromARGB(255, 240, 240, 240);
  static Color orangeColor = const Color(0xFFF37B67);
  static Color kakiColor = const Color(0xFFD2BDD6);
  static TextStyle textStyle = TextStyle(
    fontSize: 16,
    color: textColor,
    fontWeight: FontWeight.w500,
  );
  static TextStyle headLineStyle1 =
      TextStyle(fontSize: 26, color: textColor, fontWeight: FontWeight.bold);
  static TextStyle headLineStyle2 =
      TextStyle(fontSize: 21, color: textColor, fontWeight: FontWeight.bold);
  static TextStyle headLineStyle3 =
      const TextStyle(fontSize: 17, fontWeight: FontWeight.w500);
  static TextStyle headLineStyle4 =
      TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.w500);
}
