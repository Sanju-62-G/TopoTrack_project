import 'package:flutter/material.dart';

class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
  }

  // Returns a value scaled according to screen width
  // Using a more restrained scaling factor for "medium small" look
  static double setWidth(double width) {
    // Reference width 375
    if (screenWidth <= 375) return (width / 375) * screenWidth;
    
    // For larger screens, we scale up by only 10% of the difference
    double scale = 1.0 + (screenWidth - 375) / 375 * 0.1;
    return width * scale.clamp(1.0, 1.3);
  }

  // Returns a value scaled according to screen height
  static double setHeight(double height) {
    if (screenHeight <= 812) return (height / 812) * screenHeight;
    
    double scale = 1.0 + (screenHeight - 812) / 812 * 0.1;
    return height * scale.clamp(1.0, 1.3);
  }

  // Adaptive font size - subtle scaling
  static double setSp(double fontSize) {
    if (screenWidth <= 375) return (fontSize / 375) * screenWidth;
    
    // On larger screens, font size only grows by 15% maximum
    double t = (screenWidth - 375) / (1200 - 375);
    t = t.clamp(0.0, 1.0);
    double scale = 1.0 + (t * 0.15);
    
    return fontSize * scale;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;
}

// Extension to make it easier to use
extension ResponsiveExtension on num {
  double get sp => Responsive.setSp(toDouble());
  double get w => Responsive.setWidth(toDouble());
  double get h => Responsive.setHeight(toDouble());
}
