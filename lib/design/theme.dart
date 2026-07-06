import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Both appearance variants are dark ("midnight atelier"):
/// - Obsidian (`darkTheme`): the deep default.
/// - Graphite (`lightTheme`): a lifted charcoal for bright surroundings.
ThemeData _base(Brightness b) {
  final isObsidian = b == Brightness.dark;
  final scheme = ColorScheme(
    brightness: b,
    primary: isObsidian ? Atelier.accentBright : Atelier.accent,
    onPrimary: Atelier.onAccent,
    secondary: Atelier.thread,
    onSecondary: Atelier.nightBg,
    error: Atelier.danger,
    onError: Colors.white,
    surface: isObsidian ? Atelier.nightBg : Atelier.chalk,
    onSurface: Atelier.ink,
    surfaceContainerLow: isObsidian ? Atelier.nightCard : Atelier.card,
    surfaceContainerHighest:
        isObsidian ? const Color(0xFF1B2233) : const Color(0xFF262D3D),
    onSurfaceVariant: isObsidian ? Atelier.nightThread : Atelier.thread,
    outlineVariant: Colors.white.withValues(alpha: isObsidian ? 0.10 : 0.12),
  );

  final textTheme = Typography.material2021(platform: TargetPlatform.iOS)
      .white
      .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    // Transparent: the AmbientBackdrop behind the Navigator is the real
    // page background (see main.dart builder).
    scaffoldBackgroundColor: Colors.transparent,
    splashFactory: InkSparkle.splashFactory,
    fontFamilyFallback: const ['PingFang SC', 'Heiti SC'],
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      // Dark chrome in both variants → light status-bar icons always.
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 0.5,
      space: 0.5,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isObsidian ? Atelier.nightCard : Atelier.card,
      contentTextStyle: const TextStyle(color: Atelier.ink, fontSize: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Corners.control),
      ),
    ),
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
    }),
  );
}

final lightTheme = _base(Brightness.light);
final darkTheme = _base(Brightness.dark);
