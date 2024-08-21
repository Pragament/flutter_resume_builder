import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppThemes {
  ThemeData get lightTheme => ThemeData(
    primaryColor: Colors.blueAccent,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(primary:Colors.blueAccent),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Poppins',
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Poppins',
      ),
      bodyMedium: TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: 'Poppins',
      ),
      bodySmall: TextStyle(
        color: Colors.black,
        fontSize: 8,
        fontWeight: FontWeight.w300,
        fontFamily: 'Poppins',
      ),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Poppins',
      ),
      bodyMedium: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: 'Poppins',
      ),
      bodySmall: TextStyle(
        color: Colors.white,
        fontSize: 8,
        fontWeight: FontWeight.w300,
        fontFamily: 'Poppins',
      ),
    ),
  );
}
