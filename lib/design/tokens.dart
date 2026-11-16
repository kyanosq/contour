import 'package:flutter/material.dart';

/// Contour design tokens — the "wool & chalk" language.
///
/// Motif: a bespoke tailor's studio after dark. Midnight wool surfaces
/// (navy-charcoal), and every measuring element — tape needles, bands,
/// level ring, dial sweep — is a chalk mark: warm ivory, the tailor's
/// chalk on dark cloth. Both appearance variants are dark: Obsidian
/// (deep, default) and Graphite (lifted charcoal).
abstract final class Atelier {
  // Text.
  static const ink = Color(0xFFECF1F8); // primary text on dark
  static const thread = Color(0xFF8C97AC); // secondary text

  // Accent — tailor's chalk, warm ivory.
  static const accent = Color(0xFFE7DFCB); // graphite variant
  static const accentBright = Color(0xFFF2EBDA); // obsidian variant
  static const onAccent = Color(0xFF181C2A); // deep ink on chalk

  // Obsidian (dark mode) surfaces — midnight wool.
  static const nightBg = Color(0xFF070A12);
  static const nightCard = Color(0xFF111726);
  static const nightThread = Color(0xFF939DB2);

  // Graphite ("light" appearance — a lifted charcoal, still dark).
  static const chalkBg = Color(0xFF161A26); // page base
  static const card = Color(0xFF1E2432);

  static const success = Color(0xFF4FC98F);
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
