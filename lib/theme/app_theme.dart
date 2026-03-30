import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
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
}
