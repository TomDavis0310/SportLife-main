import 'package:flutter/material.dart';

class AppTheme {
  static const String fontFamily = 'Poppins';
  static const List<String> fontFallback = <String>[
    'Roboto',
    'Arial',
    'Helvetica'
  ];
  // Brand Colors - Modern Gen Z Pastel
  static const Color primary = Color(0xFF6C5CE7); // Soft Purple
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF4834D4);

  static const Color secondary = Color(0xFF00CEC9); // Teal/Mint
  static const Color secondaryLight = Color(0xFF81ECEC);
  static const Color secondaryDark = Color(0xFF00B894);

  static const Color accent = Color(0xFFFF7675); // Pastel Red/Pink
  static const Color accentLight = Color(0xFFFAB1A0);
  static const Color accentDark = Color(0xFFD63031);

  // Neutral Colors
  static const Color black = Color(0xFF2D3436);
  static const Color darkGrey = Color(0xFF636E72);
  static const Color grey = Color(0xFFB2BEC3);
  static const Color lightGrey = Color(0xFFDFE6E9);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF0F3F5); // Very light grey-blue

  // Semantic Colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFFF7675);
  static const Color info = Color(0xFF74B9FF);

  // Match Status Colors
  static const Color live = Color(0xFFFF7675);
  static const Color scheduled = Color(0xFF74B9FF);
  static const Color finished = Color(0xFF636E72);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallback,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: white,
        error: error,
        onPrimary: white,
        onSecondary: black,
        onSurface: black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        iconTheme: const IconThemeData(color: black),
      ),
      textTheme: _buildTextTheme(black),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: white.withOpacity(0.5), width: 1),
        ),
        margin: const EdgeInsets.only(bottom: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        hintStyle: const TextStyle(color: grey),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primary,
        unselectedItemColor: grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color textColor) {
    TextStyle style(double size, FontWeight weight) => TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFallback,
          fontSize: size,
          fontWeight: weight,
          color: textColor,
          height: 1.2,
        );

    return TextTheme(
      displayLarge: style(32, FontWeight.w700),
      displayMedium: style(28, FontWeight.w700),
      displaySmall: style(24, FontWeight.w700),
      headlineMedium: style(20, FontWeight.w600),
      titleMedium: style(16, FontWeight.w600),
      bodyLarge: style(16, FontWeight.w400),
      bodyMedium: style(14, FontWeight.w400),
    );
  }
}
