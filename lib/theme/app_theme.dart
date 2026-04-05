import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.gold,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.dark(
        primary: AppColors.gold,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        onPrimary: Colors.black,
        secondary: AppColors.gold2,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.bebasNeue(
          color: AppColors.text,
          fontSize: 34,
          letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.bebasNeue(
          color: AppColors.gold,
          fontSize: 26,
          letterSpacing: 2,
        ),
        titleLarge: GoogleFonts.bebasNeue(
          color: AppColors.text,
          fontSize: 20,
          letterSpacing: 3,
        ),
        bodyLarge: GoogleFonts.dmSans(
          color: AppColors.text,
          fontSize: 14,
        ),
        bodyMedium: GoogleFonts.dmSans(
          color: AppColors.muted,
          fontSize: 12,
        ),
        labelSmall: GoogleFonts.dmSans(
          color: AppColors.dim,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.8,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.dim,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 10),
        unselectedLabelStyle: TextStyle(fontSize: 10),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.gold,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: AppColors.gold,
        surface: Colors.grey[100]!,
        onSurface: Colors.black87,
        onPrimary: Colors.white,
        secondary: AppColors.gold,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.bebasNeue(
          color: Colors.black,
          fontSize: 34,
          letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.bebasNeue(
          color: AppColors.gold,
          fontSize: 26,
          letterSpacing: 2,
        ),
        titleLarge: GoogleFonts.bebasNeue(
          color: Colors.black,
          fontSize: 20,
          letterSpacing: 3,
        ),
        bodyLarge: GoogleFonts.dmSans(
          color: Colors.black87,
          fontSize: 14,
        ),
        bodyMedium: GoogleFonts.dmSans(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        labelSmall: GoogleFonts.dmSans(
          color: Colors.grey[500],
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.8,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );
  }
}
