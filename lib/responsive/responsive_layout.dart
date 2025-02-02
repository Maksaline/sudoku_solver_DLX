import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.aspectRatio < 1;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.aspectRatio >= 1;
  }
}