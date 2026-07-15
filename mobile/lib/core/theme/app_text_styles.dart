import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Display Styles
  static TextStyle displayLarge = GoogleFonts.rubik(
    fontSize: 48.0,
    fontWeight: FontWeight.bold,
    height: 56.0 / 48.0,
  );

  static TextStyle displayMedium = GoogleFonts.rubik(
    fontSize: 36.0,
    fontWeight: FontWeight.bold,
    height: 44.0 / 36.0,
  );

  // Heading Styles
  static TextStyle headingH1 = GoogleFonts.rubik(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    height: 32.0 / 24.0,
  );

  static TextStyle headingH2 = GoogleFonts.rubik(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    height: 28.0 / 20.0,
  );

  static TextStyle headingH3 = GoogleFonts.rubik(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    height: 26.0 / 18.0,
  );

  static TextStyle headingH4 = GoogleFonts.rubik(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    height: 24.0 / 16.0,
  );

  // Body Styles
  static TextStyle bodyLarge = GoogleFonts.rubik(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    height: 24.0 / 16.0,
  );

  static TextStyle bodyMedium = GoogleFonts.rubik(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    height: 22.0 / 14.0,
  );

  static TextStyle bodySmall = GoogleFonts.rubik(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    height: 20.0 / 12.0,
  );

  // Label & Metrics
  static TextStyle labelMedium = GoogleFonts.rubik(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 20.0 / 12.0,
  );

  static TextStyle metricsLarge = GoogleFonts.rubik(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    height: 36.0 / 28.0,
  );
}

extension TextStyleWeight on TextStyle {
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
}
