import 'package:flutter/material.dart';

/// Contour design tokens — the "digital atelier" language.
///
/// Motif: tailor's tools. Ink-navy wool, chalk-warm surfaces, brass hardware,
/// and ruler ticks as the recurring decorative DNA.
abstract final class Atelier {
  static const ink = Color(0xFF171C30); // 藏蓝呢 — primary text / dark surface
  static const inkSoft = Color(0xFF2A3149);
  static const chalk = Color(0xFFFAF7F2); // 划粉暖白 — light page background
  static const card = Color(0xFFFFFFFF);
  static const brass = Color(0xFFA8874F); // 黄铜 — action / accent
  static const brassBright = Color(0xFFC4A46B); // brass on dark
  static const thread = Color(0xFF8B93A7); // secondary text
  static const success = Color(0xFF3E7C5B);
  static const danger = Color(0xFFB4443C);

  // Dark theme surfaces.
  static const nightBg = Color(0xFF101321);
  static const nightCard = Color(0xFF1A1F31);
  static const nightThread = Color(0xFF9AA1B5);
}

abstract final class Sp {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;
}

abstract final class Corners {
  static const card = 20.0;
  static const control = 14.0;
  static const chip = 10.0;
}

abstract final class Motion {
  static const fast = Duration(milliseconds: 160);
  static const standard = Duration(milliseconds: 240);
  static const emphasized = Duration(milliseconds: 400);
  static const numberRoll = Duration(milliseconds: 600);
  static const easeOut = Curves.easeOutCubic;
  static const spring = Curves.easeOutBack;
}

/// Measurement numerals: large, light, tabular — the soul of the app.
abstract final class Numerals {
  static const features = [FontFeature.tabularFigures()];

  static TextStyle display(BuildContext context, {double size = 56}) =>
      TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w200,
        letterSpacing: -1.0,
        fontFeatures: features,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.0,
      );

  static TextStyle value(BuildContext context, {double size = 22}) =>
      TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w300,
        fontFeatures: features,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.0,
      );
}

/// Hairline color that adapts to brightness.
Color hairlineOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.08);

/// Brass accent that adapts to brightness.
Color brassOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Atelier.brassBright
        : Atelier.brass;
