import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/app_localizations.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  PermissionStatus? _camera;
  PermissionStatus? _photos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from system Settings → live-refresh the statuses.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    PermissionStatus? cam, photos;
    try {
      cam = await Permission.camera.status;
      photos = await Permission.photos.status;
    } catch (_) {}
    if (mounted) {
      setState(() {
        _camera = cam;
        _photos = photos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsPermissions)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Sp.x6),
          children: [
            ContourCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: Sp.x5, vertical: Sp.x2),
              child: Column(
                children: [
                  _PermRow(
                    icon: Icons.photo_camera_outlined,
                    label: l.permCamera,
                    why: l.permCameraWhy,
                    status: _camera,
                    granted: l.permGranted,
                    denied: l.permDenied,
                    onTap: () async {
                      final s = await Permission.camera.request();
                      if (s.isPermanentlyDenied) await openAppSettings();
                      _refresh();
                    },
                  ),
                  Divider(color: scheme.outlineVariant),
                  _PermRow(
                    icon: Icons.photo_library_outlined,
                    label: l.permPhotos,
                    why: l.permPhotosWhy,
                    status: _photos,
                    granted: l.permGranted,
                    denied: l.permDenied,
                    onTap: () async {
                      final s = await Permission.photos.request();
                      if (s.isPermanentlyDenied) await openAppSettings();
                      _refresh();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sp.x5),
            BrassButton(
              label: l.permOpenSystem,
              icon: Icons.settings_outlined,
              onPressed: openAppSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermRow extends StatelessWidget {
  const _PermRow({
    required this.icon,
    required this.label,
    required this.why,
    required this.status,
    required this.granted,
    required this.denied,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String why;
  final PermissionStatus? status;
  final String granted;
  final String denied;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isGranted =
        status == PermissionStatus.granted || status == PermissionStatus.limited;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sp.x4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: scheme.onSurfaceVariant),
            const SizedBox(width: Sp.x4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    why,
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Sp.x3, vertical: 5),
              decoration: BoxDecoration(
                color: isGranted
                    ? Atelier.success.withValues(alpha: 0.12)
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(Corners.chip),
              ),
              child: Text(
                status == null ? '—' : (isGranted ? granted : denied),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isGranted ? Atelier.success : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
