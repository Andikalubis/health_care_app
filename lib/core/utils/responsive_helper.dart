import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double _referenceWidth = 390;

  final double width;
  final double height;
  final double pad;
  final double sp;
  final double localCardMargin;
  final double localCardRadius;

  ResponsiveHelper._(this.width, this.height)
      : pad = _contentPadding(width),
        sp = _spacing(width),
        localCardMargin = _cardMargin(width),
        localCardRadius = _cardRadius(width);

  factory ResponsiveHelper.of(BuildContext context) {
    final mq = MediaQuery.of(context);
    return ResponsiveHelper._(mq.size.width, mq.size.height);
  }

  double scaleByWidth(double size) => size * (width / _referenceWidth);

  static double _contentPadding(double w) {
    if (w < 360) return 12;
    if (w < 600) return 20;
    if (w < 1024) return 32;
    return 48;
  }

  static double _cardMargin(double w) {
    if (w < 600) return 10;
    return 14;
  }

  static double _cardRadius(double w) {
    if (w < 360) return 12;
    if (w < 600) return 16;
    return 20;
  }

  static double _spacing(double w) {
    if (w < 360) return 8;
    if (w < 600) return 12;
    if (w < 1024) return 16;
    return 20;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double scale(BuildContext context, double size) =>
      size * (screenWidth(context) / _referenceWidth);

  static double fontSize(BuildContext context, double size) {
    return scale(context, size).clamp(size * 0.8, size * 1.4);
  }

  static double contentPadding(BuildContext context) =>
      _contentPadding(MediaQuery.of(context).size.width);

  static double cardMargin(BuildContext context) =>
      _cardMargin(MediaQuery.of(context).size.width);

  static double cardRadius(BuildContext context) =>
      _cardRadius(MediaQuery.of(context).size.width);

  static double iconSize(BuildContext context, double size) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return size * 0.85;
    if (w < 600) return size;
    return size * 1.15;
  }

  static int gridColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return 1;
    if (w < 600) return 2;
    if (w < 900) return 3;
    if (w < 1200) return 4;
    return 6;
  }

  static double spacing(BuildContext context) =>
      _spacing(MediaQuery.of(context).size.width);

  static double avatarRadius(BuildContext context, double size) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return size * 0.8;
    if (w < 600) return size;
    return size * 1.2;
  }
}
