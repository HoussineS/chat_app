import 'package:flutter/material.dart';

final ThemeData chatTheme = ThemeData(
  // Color Scheme
  colorScheme: ColorScheme.light(
    primary: Color(0xFF1976D2), // Primary blue
    primaryContainer: Color(0xFF1565C0),
    secondary: Color(0xFF03A9F4), // Accent blue
    secondaryContainer: Color(0xFF0288D1),
    surface: Colors.white,
    // ignore: deprecated_member_use
    background: Color(0xFFF5F5F5),
    error: Color(0xFFD32F2F),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    // ignore: deprecated_member_use
    onBackground: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  ),

  // App Bar Theme
  appBarTheme: AppBarTheme(
    color: Color(0xFF1976D2),
    elevation: 1,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
  ),

  // Floating Action Button
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF1976D2),
    foregroundColor: Colors.white,
    elevation: 4,
  ),

  // Input Decoration (for text fields)
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Color(0xFF1976D2), width: 1.5),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),

  // Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF1976D2),
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  ),

  // Text Theme
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  ),

  // Card Theme
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 1,
    margin: EdgeInsets.symmetric(vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);