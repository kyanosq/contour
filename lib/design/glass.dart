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

    // Base wash — midnight wool: Obsidian (deep) vs Graphite (lifted).
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF060810), Color(0xFF0B101E), Color(0xFF070912)]
              : const [Color(0xFF191D2A), Color(0xFF1C2231), Color(0xFF151923)],
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
      // One warm work lamp + deep indigo night.
      blob(Offset(w * 0.85, h * 0.04), w * 0.72,
          const Color(0xFFE8DCBB).withValues(alpha: 0.10));
      blob(Offset(w * 0.04, h * 0.32), w * 0.7,
          const Color(0xFF31418F).withValues(alpha: 0.20));
      blob(Offset(w * 0.78, h * 0.86), w * 0.85,
          const Color(0xFF20315E).withValues(alpha: 0.22));
      blob(Offset(w * 0.16, h * 0.99), w * 0.5,
          const Color(0xFFE8DCBB).withValues(alpha: 0.045));
    } else {
      // Same night, the lamp turned a notch brighter.
      blob(Offset(w * 0.85, h * 0.04), w * 0.75,
          const Color(0xFFEDE2C3).withValues(alpha: 0.12));
      blob(Offset(w * 0.04, h * 0.30), w * 0.72,
          const Color(0xFF44549E).withValues(alpha: 0.24));
      blob(Offset(w * 0.82, h * 0.84), w * 0.9,
          const Color(0xFF2A3C6E).withValues(alpha: 0.26));
      blob(Offset(w * 0.14, h * 0.98), w * 0.55,
          const Color(0xFFEDE2C3).withValues(alpha: 0.055));
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
            Colors.white.withValues(alpha: isDark ? 0.016 : 0.028),
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

/// ------------------------------------------------------------------- press
///
/// The house press feedback: every tappable surface settles 3% under the
/// finger. One curve, one duration — a single tactile language app-wide.
class PressTract extends StatefulWidget {
  const PressTract({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<PressTract> createState() => _PressTractState();
}

class _PressTractState extends State<PressTract> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (_) => setState(() => _down = true),
      onPointerUp: (_) => setState(() => _down = false),
      onPointerCancel: (_) => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
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

  /// Optional colored tint mixed into the fill (e.g. accent banner).
  final Color? tint;
  final VoidCallback? onTap;
  final double? borderAlpha;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = BorderRadius.circular(radius);

    // Both variants are dark glass; Graphite runs slightly milkier.
    final fillTop = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.13);
    final fillBottom = isDark
        ? Colors.white.withValues(alpha: 0.045)
        : Colors.white.withValues(alpha: 0.06);

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
                    Colors.white.withValues(alpha: isDark ? 0.35 : 0.42),
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
              .withValues(alpha: borderAlpha ?? (isDark ? 0.14 : 0.17)),
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

    core = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.42 : 0.36),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: core,
    );

    return onTap == null ? core : PressTract(child: core);
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
