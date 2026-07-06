import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Primary action button — brass, pill-shaped, with press feedback.
class BrassButton extends StatelessWidget {
  const BrassButton({
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
    final bg = destructive ? Atelier.danger : scheme.primary;
    final child = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: scheme.onPrimary,
        disabledBackgroundColor: bg.withValues(alpha: 0.35),
        minimumSize: const Size(64, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
      onPressed: onPressed == null
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
    );
    return expanded ? SizedBox(width: double.infinity, child: child) : child;
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

/// Card with the atelier hairline + soft shadow.
class ContourCard extends StatelessWidget {
  const ContourCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Sp.x5),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = AnimatedContainer(
      duration: Motion.standard,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Corners.card),
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Atelier.ink.withValues(alpha: 0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      padding: padding,
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Corners.card),
        onTap: onTap,
        child: card,
      ),
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
        Container(width: 14, height: 2, color: brassOf(context)),
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
                ).colorScheme.surface.withValues(alpha: 0.55),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
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
      content: Row(
        children: [
          Icon(
            error ? Icons.error_outline : Icons.check_circle_outline,
            color: error ? const Color(0xFFE7A6A1) : const Color(0xFFA9CBB9),
            size: 18,
          ),
          const SizedBox(width: Sp.x2),
          Expanded(child: Text(message)),
        ],
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}
