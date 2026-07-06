import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../../design/glass.dart';
import '../../design/tick_ruler.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Full privacy policy page (settings). Remote text with built-in fallback.
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String? _remote;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final text = await context.read<Session>().api.privacyPolicy();
      if (mounted) setState(() => _remote = text);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.privacyTitle)),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(Sp.x6),
                children: [
                  const TickRuler(height: 10),
                  const SizedBox(height: Sp.x5),
                  Text(
                    _remote?.isNotEmpty == true ? _remote! : l.privacyBuiltin,
                    style: const TextStyle(fontSize: 15, height: 1.7),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Bottom-sheet variant used from the login screen — frosted glass slab.
Future<void> showPrivacySheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      builder: (context, scroll) => GlassPanel(
        frosted: true,
        radius: Corners.card,
        padding: EdgeInsets.zero,
        child: ListView(
        controller: scroll,
        padding: const EdgeInsets.all(Sp.x6),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: Sp.x5),
          Text(
            l.privacyTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Sp.x4),
          Text(
            l.privacyBuiltin,
            style: const TextStyle(fontSize: 15, height: 1.7),
          ),
          const SizedBox(height: Sp.x8),
        ],
        ),
      ),
    ),
  );
}

/// First-launch modal gate: accept → continue; decline → leave the app.
/// Returns true when accepted.
Future<bool> showPrivacyGate(BuildContext context) async {
  final l = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  final result = await showGlassDialog<bool>(
    context: context,
    dismissible: false,
    title: l.privacyTitle,
    content: Builder(
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.42,
        ),
        child: SingleChildScrollView(
          child: Text(
            l.privacyBuiltin,
            style:
                TextStyle(fontSize: 14, height: 1.65, color: scheme.onSurface),
          ),
        ),
      ),
    ),
    actions: [
      Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            l.privacyDecline,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
      ),
      Builder(
        builder: (context) => BrassButton(
          label: l.privacyAccept,
          expanded: false,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ),
    ],
  );
  return result ?? false;
}
