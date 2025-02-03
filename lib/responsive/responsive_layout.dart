import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.aspectRatio < 0.8;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.aspectRatio >= 0.8;
  }
}