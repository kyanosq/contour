import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass.dart';
import 'tokens.dart';

/// Primary action button — polished accent bar with a soft glow.
class AccentButton extends StatelessWidget {
  const AccentButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final base = destructive ? Atelier.danger : scheme.primary;
    final top = destructive
        ? const Color(0xFFFF7F76)
        : const Color(0xFF6FF2E6); // lumen highlight

    final button = AnimatedOpacity(
      duration: Motion.standard,
      opacity: enabled ? 1 : 0.45,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [top, base],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.30),
            width: 1,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: base.withValues(alpha: 0.30),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: destructive ? Colors.white : scheme.onPrimary,
            disabledForegroundColor:
                destructive ? Colors.white : scheme.onPrimary,
            shadowColor: Colors.transparent,
            minimumSize: const Size(64, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          onPressed: !enabled
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: Sp.x2),
              ],
              Text(label),
            ],
          ),
        ),
      ),
    );
    return expanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Quiet secondary button.
class ThreadButton extends StatelessWidget {
  const ThreadButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        minimumSize: const Size(44, 44),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

/// Secondary pill on glass — used for the login channels and review actions.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.accent = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Brass text/border treatment.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = accent ? accentOf(context) : scheme.onSurface;
    return GlassPanel(
      radius: 25,
      padding: EdgeInsets.zero,
      onTap: onPressed == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed!();
            },
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: Sp.x2),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// House card — glass over the ambient backdrop.
class ContourCard extends StatelessWidget {
  const ContourCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Sp.x5),
    this.onTap,
    this.frosted = false,
    this.tint,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool frosted;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: padding,
      onTap: onTap,
      frosted: frosted,
      tint: tint,
      child: child,
    );
  }
}

/// Section label in the atelier style: small caps tracking + tick accent.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(width: 14, height: 2, color: accentOf(context)),
        const SizedBox(width: Sp.x2),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Non-blocking progress veil used during async work.
class WorkingVeil extends StatelessWidget {
  const WorkingVeil({super.key, required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Spinner exists only while visible — an off-screen indeterminate
        // spinner would otherwise animate (and burn frames) forever.
        if (visible)
          Positioned.fill(
            child: AnimatedOpacity(
              duration: Motion.standard,
              opacity: 1,
              child: Container(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.4),
                alignment: Alignment.center,
                child: GlassPanel(
                  frosted: true,
                  radius: 20,
                  padding: const EdgeInsets.all(Sp.x5),
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

void showToast(BuildContext context, String message, {bool error = false}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.hideCurrentSnackBar();
  messenger?.showSnackBar(
    SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 3),
      content: GlassPanel(
        frosted: true,
        radius: 18,
        padding:
            const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x3),
        child: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.check_circle_outline,
              color: error ? Atelier.danger : Atelier.success,
              size: 18,
            ),
            const SizedBox(width: Sp.x2),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
