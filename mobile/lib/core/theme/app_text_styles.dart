import 'package:flutter/material.dart';

class AppTextStyles {
  static const String fontName = 'Inter';

  // Display Styles
  static TextStyle displayLarge = TextStyle(
    fontFamily: fontName,
    fontSize: 48.0,
    fontWeight: FontWeight.bold,
    height: 56.0 / 48.0,
  );

  static TextStyle displayMedium = TextStyle(
    fontFamily: fontName,
    fontSize: 36.0,
    fontWeight: FontWeight.bold,
    height: 44.0 / 36.0,
  );

  // Heading Styles
  static TextStyle headingH1 = TextStyle(
    fontFamily: fontName,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    height: 32.0 / 24.0,
  );

  static TextStyle headingH2 = TextStyle(
    fontFamily: fontName,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    height: 28.0 / 20.0,
  );

  static TextStyle headingH3 = TextStyle(
    fontFamily: fontName,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    height: 26.0 / 18.0,
  );

  static TextStyle headingH4 = TextStyle(
    fontFamily: fontName,
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    height: 24.0 / 16.0,
  );

  // Body Styles
  static TextStyle bodyLarge = TextStyle(
    fontFamily: fontName,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    height: 24.0 / 16.0,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: fontName,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    height: 22.0 / 14.0,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: fontName,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    height: 20.0 / 12.0,
  );

  // Label & Metrics
  static TextStyle labelMedium = TextStyle(
    fontFamily: fontName,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 20.0 / 12.0,
  );

  static TextStyle metricsLarge = TextStyle(
    fontFamily: fontName,
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
