import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

ThemeData _base(Brightness b) {
  final isDark = b == Brightness.dark;
  final scheme = ColorScheme(
    brightness: b,
    primary: isDark ? Atelier.brassBright : Atelier.brass,
    onPrimary: isDark ? Atelier.nightBg : Colors.white,
    secondary: Atelier.inkSoft,
    onSecondary: Colors.white,
    error: Atelier.danger,
    onError: Colors.white,
    surface: isDark ? Atelier.nightBg : Atelier.chalk,
    onSurface: isDark ? Atelier.chalk : Atelier.ink,
    surfaceContainerLow: isDark ? Atelier.nightCard : Atelier.card,
    surfaceContainerHighest:
        isDark ? const Color(0xFF232941) : const Color(0xFFF0EBE2),
    onSurfaceVariant: isDark ? Atelier.nightThread : Atelier.thread,
    outlineVariant: isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.08),
  );

  final textTheme = Typography.material2021(platform: TargetPlatform.iOS)
      .black
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
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
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
      backgroundColor: isDark ? Atelier.nightCard : Atelier.ink,
      contentTextStyle: const TextStyle(color: Atelier.chalk, fontSize: 14),
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
