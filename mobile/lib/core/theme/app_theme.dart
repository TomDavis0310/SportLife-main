import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const String fontFamily = 'Poppins';
  static const List<String> fontFallback = <String>[
    'Roboto',
    'Arial',
    'Helvetica'
  ];

  // ============================================
  // BRAND COLORS - Consistent across themes
  // ============================================
  static const Color primary = Color(0xFF6C5CE7); // Soft Purple
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF5849C2);

  static const Color secondary = Color(0xFF00CEC9); // Teal/Mint
  static const Color secondaryLight = Color(0xFF81ECEC);
  static const Color secondaryDark = Color(0xFF00B894);

  static const Color accent = Color(0xFFFF7675); // Pastel Red/Pink
  static const Color accentLight = Color(0xFFFAB1A0);
  static const Color accentDark = Color(0xFFD63031);

  // ============================================
  // SEMANTIC COLORS
  // ============================================
  static const Color success = Color(0xFF00B894);
  static const Color successLight = Color(0xFF55EFC4);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color warningDark = Color(0xFFE17055);
  static const Color error = Color(0xFFFF7675);
  static const Color errorDark = Color(0xFFD63031);
  static const Color info = Color(0xFF74B9FF);
  static const Color infoDark = Color(0xFF0984E3);

  // Match Status Colors
  static const Color live = Color(0xFFFF7675);
  static const Color scheduled = Color(0xFF74B9FF);
  static const Color finished = Color(0xFF636E72);

  // ============================================
  // LIGHT THEME COLORS
  // ============================================
  static const Color _lightBackground = Color(0xFFF8F9FA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightTextPrimary = Color(0xFF1A1A2E);
  static const Color _lightTextSecondary = Color(0xFF4A4A68);
  static const Color _lightTextHint = Color(0xFF9E9E9E);
  static const Color _lightDivider = Color(0xFFE8E8E8);
  static const Color _lightBorder = Color(0xFFE0E0E0);
  static const Color _lightInputFill = Color(0xFFF5F5F5);
  static const Color _lightNavBar = Color(0xFFFFFFFF);
  static const Color _lightShadow = Color(0x1A000000);

  // ============================================
  // DARK THEME COLORS
  // ============================================
  static const Color _darkBackground = Color(0xFF0D1117);
  static const Color _darkSurface = Color(0xFF161B22);
  static const Color _darkCard = Color(0xFF21262D);
  static const Color _darkTextPrimary = Color(0xFFF0F6FC);
  static const Color _darkTextSecondary = Color(0xFF8B949E);
  static const Color _darkTextHint = Color(0xFF6E7681);
  static const Color _darkDivider = Color(0xFF30363D);
  static const Color _darkBorder = Color(0xFF30363D);
  static const Color _darkInputFill = Color(0xFF21262D);
  static const Color _darkNavBar = Color(0xFF161B22);
  static const Color _darkShadow = Color(0x40000000);

  // Legacy color names for backward compatibility
  static const Color black = _lightTextPrimary;
  static const Color darkGrey = _lightTextSecondary;
  static const Color grey = Color(0xFFB2BEC3);
  static const Color lightGrey = Color(0xFFDFE6E9);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = _lightBackground;

  // ============================================
  // LIGHT THEME
  // ============================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallback,
      scaffoldBackgroundColor: _lightBackground,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryLight,
        secondary: secondary,
        secondaryContainer: secondaryLight,
        surface: _lightSurface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: _lightTextPrimary,
        onSurface: _lightTextPrimary,
        onError: Colors.white,
        outline: _lightBorder,
        shadow: _lightShadow,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        shadowColor: _lightShadow,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _lightTextPrimary,
        ),
        iconTheme: IconThemeData(color: _lightTextPrimary, size: 24),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Text Theme
      textTheme: _buildTextTheme(_lightTextPrimary, _lightTextSecondary),

      // Card Theme
      cardTheme: CardThemeData(
        color: _lightCard,
        elevation: 0,
        shadowColor: _lightShadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _lightBorder, width: 1),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: grey.withOpacity(0.3),
          disabledForegroundColor: grey,
          elevation: 0,
          shadowColor: primary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightInputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        hintStyle: const TextStyle(
          color: _lightTextHint,
          fontFamily: fontFamily,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: _lightTextSecondary,
          fontFamily: fontFamily,
          fontSize: 14,
        ),
        errorStyle: const TextStyle(
          color: error,
          fontFamily: fontFamily,
          fontSize: 12,
        ),
        prefixIconColor: _lightTextSecondary,
        suffixIconColor: _lightTextSecondary,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _lightNavBar,
        selectedItemColor: primary,
        unselectedItemColor: _lightTextHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Navigation Bar Theme (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _lightNavBar,
        indicatorColor: primary.withOpacity(0.15),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return const TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _lightTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: _lightTextSecondary, size: 24);
        }),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: _lightDivider,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _lightInputFill,
        selectedColor: primary.withOpacity(0.15),
        disabledColor: grey.withOpacity(0.2),
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          color: _lightTextPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          color: primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: _lightBorder),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: _lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _lightTextPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: _lightTextSecondary,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _lightTextPrimary,
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: _lightTextSecondary,
        indicatorColor: primary,
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryLight;
          return _lightBorder;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: _lightBorder, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _lightTextPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: _lightTextSecondary,
        ),
        iconColor: _lightTextSecondary,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: _lightInputFill,
        circularTrackColor: _lightInputFill,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: _lightTextPrimary,
        size: 24,
      ),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
    );
  }

  // ============================================
  // DARK THEME
  // ============================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallback,
      scaffoldBackgroundColor: _darkBackground,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primary,
        primaryContainer: primaryDark,
        secondary: secondary,
        secondaryContainer: secondaryDark,
        surface: _darkSurface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _darkTextPrimary,
        onError: Colors.white,
        outline: _darkBorder,
        shadow: _darkShadow,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        shadowColor: _darkShadow,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
        ),
        iconTheme: IconThemeData(color: _darkTextPrimary, size: 24),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Text Theme
      textTheme: _buildTextTheme(_darkTextPrimary, _darkTextSecondary),

      // Card Theme
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 0,
        shadowColor: _darkShadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _darkBorder, width: 1),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _darkBorder,
          disabledForegroundColor: _darkTextHint,
          elevation: 0,
          shadowColor: primary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkInputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        hintStyle: const TextStyle(
          color: _darkTextHint,
          fontFamily: fontFamily,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: _darkTextSecondary,
          fontFamily: fontFamily,
          fontSize: 14,
        ),
        errorStyle: const TextStyle(
          color: error,
          fontFamily: fontFamily,
          fontSize: 12,
        ),
        prefixIconColor: _darkTextSecondary,
        suffixIconColor: _darkTextSecondary,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkNavBar,
        selectedItemColor: primary,
        unselectedItemColor: _darkTextHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Navigation Bar Theme (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkNavBar,
        indicatorColor: primary.withOpacity(0.2),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return const TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _darkTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: _darkTextSecondary, size: 24);
        }),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: _darkDivider,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _darkInputFill,
        selectedColor: primary.withOpacity(0.2),
        disabledColor: _darkBorder,
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          color: _darkTextPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          color: primaryLight,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: _darkBorder),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: _darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: _darkTextSecondary,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkCard,
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: _darkTextPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: _darkTextSecondary,
        indicatorColor: primary,
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return _darkTextHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryDark;
          return _darkBorder;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: _darkBorder, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _darkTextPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: _darkTextSecondary,
        ),
        iconColor: _darkTextSecondary,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: _darkInputFill,
        circularTrackColor: _darkInputFill,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: _darkTextPrimary,
        size: 24,
      ),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
    );
  }

  // ============================================
  // TEXT THEME BUILDER
  // ============================================
  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    TextStyle style(double size, FontWeight weight, Color color) => TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFallback,
          fontSize: size,
          fontWeight: weight,
          color: color,
          height: 1.4,
          letterSpacing: 0.1,
        );

    return TextTheme(
      // Display styles - for large hero text
      displayLarge: style(32, FontWeight.w700, primaryColor),
      displayMedium: style(28, FontWeight.w700, primaryColor),
      displaySmall: style(24, FontWeight.w700, primaryColor),
      
      // Headline styles - for section headers
      headlineLarge: style(22, FontWeight.w600, primaryColor),
      headlineMedium: style(20, FontWeight.w600, primaryColor),
      headlineSmall: style(18, FontWeight.w600, primaryColor),
      
      // Title styles - for card titles, list item titles
      titleLarge: style(18, FontWeight.w600, primaryColor),
      titleMedium: style(16, FontWeight.w600, primaryColor),
      titleSmall: style(14, FontWeight.w600, primaryColor),
      
      // Body styles - for regular content
      bodyLarge: style(16, FontWeight.w400, primaryColor),
      bodyMedium: style(14, FontWeight.w400, primaryColor),
      bodySmall: style(12, FontWeight.w400, secondaryColor),
      
      // Label styles - for buttons, chips, tabs
      labelLarge: style(14, FontWeight.w600, primaryColor),
      labelMedium: style(12, FontWeight.w500, primaryColor),
      labelSmall: style(11, FontWeight.w500, secondaryColor),
    );
  }

  // ============================================
  // EXTENSION COLORS (for custom widgets)
  // ============================================
  static AppColors lightColors = const AppColors(
    background: _lightBackground,
    surface: _lightSurface,
    card: _lightCard,
    textPrimary: _lightTextPrimary,
    textSecondary: _lightTextSecondary,
    textHint: _lightTextHint,
    divider: _lightDivider,
    border: _lightBorder,
    inputFill: _lightInputFill,
    navBar: _lightNavBar,
    shadow: _lightShadow,
    shimmerBase: Color(0xFFE0E0E0),
    shimmerHighlight: Color(0xFFF5F5F5),
    gradientStart: Color(0xFF6C5CE7),
    gradientEnd: Color(0xFFA29BFE),
  );

  static AppColors darkColors = const AppColors(
    background: _darkBackground,
    surface: _darkSurface,
    card: _darkCard,
    textPrimary: _darkTextPrimary,
    textSecondary: _darkTextSecondary,
    textHint: _darkTextHint,
    divider: _darkDivider,
    border: _darkBorder,
    inputFill: _darkInputFill,
    navBar: _darkNavBar,
    shadow: _darkShadow,
    shimmerBase: Color(0xFF2D333B),
    shimmerHighlight: Color(0xFF444C56),
    gradientStart: Color(0xFF6C5CE7),
    gradientEnd: Color(0xFF5849C2),
  );

  /// Get colors based on current theme brightness
  static AppColors getColors(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkColors
        : lightColors;
  }
}

/// Custom color palette for extended theming
class AppColors {
  final Color background;
  final Color surface;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color divider;
  final Color border;
  final Color inputFill;
  final Color navBar;
  final Color shadow;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color gradientStart;
  final Color gradientEnd;

  const AppColors({
    required this.background,
    required this.surface,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.divider,
    required this.border,
    required this.inputFill,
    required this.navBar,
    required this.shadow,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.gradientStart,
    required this.gradientEnd,
  });
}

/// Extension to easily access custom colors from context
extension AppThemeExtension on BuildContext {
  AppColors get appColors => AppTheme.getColors(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
