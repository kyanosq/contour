import 'package:flutter/material.dart';

/// Contour design tokens — the "midnight atelier" language.
///
/// Motif: a tailor's studio after dark. Obsidian and graphite surfaces,
/// lumen-teal instrument light as the single accent, and ruler ticks as the
/// recurring decorative DNA. Both appearance variants are dark: Obsidian
/// (deep, default) and Graphite (lifted charcoal).
abstract final class Atelier {
  // Text.
  static const ink = Color(0xFFECF1F8); // primary text on dark
  static const thread = Color(0xFF8C97AC); // secondary text

  // Accent — "lumen" teal, the instrument light.
  static const accent = Color(0xFF35D0C4); // graphite variant
  static const accentBright = Color(0xFF4FE3D6); // obsidian variant
  static const onAccent = Color(0xFF04211D);

  // Obsidian (dark mode) surfaces.
  static const nightBg = Color(0xFF070A11);
  static const nightCard = Color(0xFF121826);
  static const nightThread = Color(0xFF939DB2);

  // Graphite ("light" appearance — a lifted charcoal, still dark).
  static const chalk = Color(0xFF151924); // page base
  static const card = Color(0xFF1D2331);

  static const success = Color(0xFF43CE8C);
  static const danger = Color(0xFFF0655F);
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

/// Hairline color (both variants are dark → always a white haze).
Color hairlineOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.12);

/// Accent that adapts to the appearance variant.
Color accentOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Atelier.accentBright
        : Atelier.accent;
