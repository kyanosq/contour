import 'dart:ui';

import 'package:flutter/material.dart';

import 'tokens.dart';

/// ------------------------------------------------------------------ ambient
///
/// The light source every glass surface refracts. Lives once behind the
/// Navigator (see main.dart), so pages keep visual continuity while routes
/// slide above it.
class AmbientBackdrop extends StatelessWidget {
  const AmbientBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _AmbientPainter(isDark: isDark),
        size: Size.infinite,
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base wash.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0D101C), Color(0xFF12172A), Color(0xFF0C0F1A)]
              : const [Color(0xFFFBF8F1), Color(0xFFF6F1E7), Color(0xFFF2ECDF)],
        ).createShader(rect),
    );

    void blob(Offset c, double r, Color color) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    final w = size.width, h = size.height;
    if (isDark) {
      // Brass aurora + indigo depths.
      blob(Offset(w * 0.85, h * 0.06), w * 0.75,
          const Color(0xFFC4A46B).withValues(alpha: 0.16));
      blob(Offset(w * 0.06, h * 0.34), w * 0.7,
          const Color(0xFF3B4A8F).withValues(alpha: 0.22));
      blob(Offset(w * 0.75, h * 0.85), w * 0.85,
          const Color(0xFF23407A).withValues(alpha: 0.20));
      blob(Offset(w * 0.2, h * 0.98), w * 0.5,
          const Color(0xFFC4A46B).withValues(alpha: 0.07));
    } else {
      // Morning-atelier window light.
      blob(Offset(w * 0.88, h * 0.02), w * 0.8,
          const Color(0xFFE9C892).withValues(alpha: 0.42));
      blob(Offset(w * 0.02, h * 0.30), w * 0.72,
          const Color(0xFFCBD4EC).withValues(alpha: 0.50));
      blob(Offset(w * 0.85, h * 0.78), w * 0.9,
          const Color(0xFFE5D3AE).withValues(alpha: 0.38));
      blob(Offset(w * 0.12, h * 0.96), w * 0.55,
          const Color(0xFFD9DFF0).withValues(alpha: 0.42));
    }

    // Diagonal light shaft (very faint) — echoes the studio photos. Soft
    // edges: fade in/out across the band instead of hard path borders.
    final shaft = Path()
      ..moveTo(w * -0.1, 0)
      ..lineTo(w * 0.55, 0)
      ..lineTo(w * 1.15, h)
      ..lineTo(w * 0.5, h)
      ..close();
    canvas.drawPath(
      shaft,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.016 : 0.10),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40)
        ..blendMode = BlendMode.plus,
    );
  }

  @override
  bool shouldRepaint(_AmbientPainter old) => old.isDark != isDark;
}

/// -------------------------------------------------------------------- panel
///
/// The house glass. Over the ambient backdrop, translucency + hairline +
/// top highlight read as glass at zero GPU cost; set [frosted] when content
/// scrolls or lives beneath (dialogs, docked bars, camera chrome) for a real
/// backdrop blur.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Sp.x5),
    this.radius = Corners.card,
    this.frosted = false,
    this.tint,
    this.onTap,
    this.borderAlpha,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool frosted;

  /// Optional colored tint mixed into the fill (e.g. brass banner).
  final Color? tint;
  final VoidCallback? onTap;
  final double? borderAlpha;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = BorderRadius.circular(radius);

    final fillTop = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.62);
    final fillBottom = isDark
        ? Colors.white.withValues(alpha: 0.045)
        : Colors.white.withValues(alpha: 0.34);

    Widget inner = Stack(
      children: [
        // Inner top highlight — the "polished edge".
        Positioned(
          top: 0,
          left: radius,
          right: radius,
          child: IgnorePointer(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: isDark ? 0.35 : 0.9),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(padding: padding, child: child),
      ],
    );

    // Ink wraps the content (not an overlay) so hit tests reach both the
    // child and the ripple.
    if (onTap != null) {
      inner = Material(
        color: Colors.transparent,
        child: InkWell(borderRadius: r, onTap: onTap, child: inner),
      );
    }

    Widget core = Container(
      decoration: BoxDecoration(
        borderRadius: r,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: tint == null
              ? [fillTop, fillBottom]
              : [
                  Color.alphaBlend(tint!.withValues(alpha: 0.16), fillTop),
                  Color.alphaBlend(tint!.withValues(alpha: 0.10), fillBottom),
                ],
        ),
        border: Border.all(
          color: Colors.white
              .withValues(alpha: borderAlpha ?? (isDark ? 0.14 : 0.72)),
          width: 1,
        ),
      ),
      child: inner,
    );

    if (frosted) {
      core = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: core,
      );
    }

    core = ClipRRect(borderRadius: r, child: core);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.42)
                : Atelier.ink.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: core,
    );
  }
}

/// Small glass chip (icon buttons, badges, camera chrome).
class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Sp.x2),
    this.radius = 22,
    this.frosted = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool frosted;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: padding,
      radius: radius,
      frosted: frosted,
      onTap: onTap,
      child: child,
    );
  }
}

/// ------------------------------------------------------------------- dialog
///
/// Glass replacement for AlertDialog: frosted panel, title/content/actions.
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required String title,
  Widget? content,
  required List<Widget> actions,
  bool dismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: title,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    transitionDuration: Motion.standard,
    pageBuilder: (context, _, _) => _GlassDialog(
      title: title,
      content: content,
      actions: actions,
      dismissible: dismissible,
    ),
    transitionBuilder: (context, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Motion.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _GlassDialog extends StatelessWidget {
  const _GlassDialog({
    required this.title,
    required this.content,
    required this.actions,
    required this.dismissible,
  });

  final String title;
  final Widget? content;
  final List<Widget> actions;
  final bool dismissible;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.x6),
              child: GlassPanel(
                frosted: true,
                radius: 24,
                padding: const EdgeInsets.fromLTRB(Sp.x6, Sp.x6, Sp.x6, Sp.x4),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (content != null) ...[
                        const SizedBox(height: Sp.x4),
                        Flexible(child: content!),
                      ],
                      const SizedBox(height: Sp.x4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          for (final a in actions) ...[
                            a,
                            if (a != actions.last) const SizedBox(width: Sp.x2),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
