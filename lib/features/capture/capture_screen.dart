import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../app/measure_flow.dart';
import '../../app/session.dart';
import '../../capture/capture_flow.dart';
import '../../capture/level.dart';
import '../../capture/metadata.dart';
import '../../capture/silhouette_overlay.dart';
import '../../capture/tts_service.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Scripted gravity for simulator evaluation:
/// `--dart-define=SIM_GRAVITY=1` → 2.5 s tilted, then level.
/// (String-based: `bool.fromEnvironment` only accepts the literal `true`.)
const bool kSimGravity =
    String.fromEnvironment('SIM_GRAVITY', defaultValue: '') != '';

enum _CameraState { probing, ready, none, denied }

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with WidgetsBindingObserver {
  late final CaptureFlowMachine _machine;
  final TtsService _tts = TtsService();

  CameraController? _camera;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  _CameraState _cameraState = _CameraState.probing;

  StreamSubscription<AccelerometerEvent>? _gravitySub;
  Timer? _simTimer;
  Timer? _sensorFallback;
  bool _sensorSeen = false;

  LevelReading _reading = const LevelReading(
    dx: 0,
    dy: 0,
    pitchDeg: 0,
    rollDeg: 0,
  );
  double _ax = 0, _ay = -9.8, _az = 0;

  Uint8List? _lastShot;
  bool _spokePromptForView = false;

  MeasureFlow get _flow => context.read<MeasureFlow>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _machine =
        CaptureFlowMachine(
          onShutter: _shoot,
          onCount: (n) {
            HapticFeedback.lightImpact();
            _speak('$n');
          },
        )..addListener(() {
          if (mounted) setState(() {});
        });
    _startSensors();
    _initCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakViewPrompt());
  }

  // ---------------------------------------------------------------- sensors

  void _startSensors() {
    if (kSimGravity) {
      final start = DateTime.now();
      _simTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
        final elapsed = DateTime.now().difference(start);
        final tilted = elapsed < const Duration(milliseconds: 2500);
        _feedGravity(tilted ? 3.4 : 0.15, -9.2, tilted ? 2.8 : 0.2);
      });
      _sensorSeen = true;
      return;
    }
    try {
      _gravitySub =
          accelerometerEventStream(
            samplingPeriod: const Duration(milliseconds: 80),
          ).listen((e) {
            _sensorSeen = true;
            _feedGravity(e.x, e.y, e.z);
          }, onError: (_) {});
    } catch (_) {}
    // No accelerometer (simulator/desktop): manual-only capture, treat level.
    _sensorFallback = Timer(const Duration(milliseconds: 2000), () {
      if (_sensorSeen || !mounted) return;
      _machine.autoShutter = false;
      _feedGravity(0, -9.8, 0);
      setState(() {});
    });
  }

  void _feedGravity(double x, double y, double z) {
    _ax = x;
    _ay = y;
    _az = z;
    final r = readLevel(x, y, z);
    final wasLevel = _machine.isLevel;
    _reading = r;
    _machine.onLevel(r);
    if (!wasLevel && !_machine.isLevel && mounted) {
      setState(() {}); // keep bubble live even without phase change
    }
  }

  // ----------------------------------------------------------------- camera

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _cameraState = _CameraState.none);
        return;
      }
      // Prefer the back camera (subject is someone else / phone propped).
      _cameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (_cameraIndex < 0) _cameraIndex = 0;
      await _openCamera();
    } on CameraException catch (e) {
      setState(
        () => _cameraState =
            e.code.contains('AccessDenied') || e.code.contains('Permission')
            ? _CameraState.denied
            : _CameraState.none,
      );
    } catch (_) {
      setState(() => _cameraState = _CameraState.none);
    }
  }

  Future<void> _openCamera() async {
    final old = _camera;
    _camera = null;
    await old?.dispose();
    final controller = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _cameraState = _CameraState.ready;
      });
    } on CameraException catch (e) {
      setState(
        () => _cameraState =
            e.code.contains('AccessDenied') || e.code.contains('Permission')
            ? _CameraState.denied
            : _CameraState.none,
      );
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _openCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cam = _camera;
    if (cam == null || !cam.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      cam.dispose();
      _camera = null;
    } else if (state == AppLifecycleState.resumed) {
      _openCamera();
    }
  }

  // ---------------------------------------------------------------- shutter

  Future<void> _shoot() async {
    HapticFeedback.mediumImpact();
    Uint8List bytes;
    int? w, h;
    String lens = 'sample';
    final cam = _camera;
    if (cam != null && cam.value.isInitialized) {
      final file = await cam.takePicture();
      bytes = await file.readAsBytes();
      w = cam.value.previewSize?.height.round();
      h = cam.value.previewSize?.width.round();
      lens = _cameras[_cameraIndex].lensDirection.name;
    } else {
      final view = _machine.view == CaptureView.front ? 'front' : 'side';
      final data = await rootBundle.load('assets/samples/$view.jpg');
      bytes = data.buffer.asUint8List();
    }
    final viewName = _machine.view == CaptureView.front ? 'front' : 'side';
    _flow.setPhoto(
      viewName,
      bytes,
      buildViewMeta(
        view: viewName,
        level: _reading,
        gx: _ax,
        gy: _ay,
        gz: _az,
        imageWidth: w,
        imageHeight: h,
        lens: lens,
      ),
    );
    _lastShot = bytes;
    if (mounted) _speak(AppLocalizations.of(context).ttsCaptured);
  }

  void _onShutterTap() {
    if (_machine.phase == CapturePhase.review ||
        _machine.phase == CapturePhase.shooting) {
      return;
    }
    if (!_machine.isLevel && _sensorSeen) {
      _speak(AppLocalizations.of(context).ttsLevelPrompt);
      HapticFeedback.heavyImpact();
      return;
    }
    _machine.manualShutter();
  }

  void _retake() {
    _lastShot = null;
    _machine.retake();
    _speakViewPrompt();
  }

  void _confirm() {
    final flow = _flow;
    final done = _machine.confirm();
    if (done) {
      flow.deviceInfo = buildDeviceInfo(
        appVersion: context.read<Session>().appVersion,
      );
      context.pushReplacement('/measuring');
    } else {
      _lastShot = null;
      _spokePromptForView = false;
      _speakViewPrompt();
      setState(() {});
    }
  }

  // -------------------------------------------------------------------- tts

  void _speak(String text) {
    final lang = Localizations.localeOf(context).languageCode;
    _tts.speak(text, languageCode: lang);
  }

  void _speakViewPrompt() {
    if (_spokePromptForView || !mounted) return;
    _spokePromptForView = true;
    final l = AppLocalizations.of(context);
    _speak(
      _machine.view == CaptureView.front ? l.ttsFrontPrompt : l.ttsSidePrompt,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gravitySub?.cancel();
    _simTimer?.cancel();
    _sensorFallback?.cancel();
    _machine.dispose();
    _camera?.dispose();
    _tts.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------- ui

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final inReview = _machine.phase == CapturePhase.review;
    final front = _machine.view == CaptureView.front;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ------- layer 1: preview / fallback
          if (_cameraState == _CameraState.ready && _camera != null)
            _CameraFill(controller: _camera!)
          else
            Container(color: const Color(0xFF14161F)),

          // ------- layer 2: pose silhouette
          if (!inReview && _cameraState != _CameraState.denied)
            SilhouetteOverlay(side: !front),

          // ------- layer 3: scrims
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  stops: const [0, 0.2, 0.72, 1],
                ),
              ),
            ),
          ),

          // ------- layer 4: review photo
          if (inReview && _lastShot != null)
            Image.memory(_lastShot!, fit: BoxFit.cover, gaplessPlayback: true),

          // ------- layer 5: chrome
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  label: front ? l.captureStepFront : l.captureStepSide,
                  onClose: () => context.pop(),
                  onSwitch:
                      (_cameraState == _CameraState.ready &&
                          _cameras.length > 1 &&
                          !inReview)
                      ? _switchCamera
                      : null,
                  switchTooltip: l.captureSwitchCamera,
                ),
                const Spacer(),

                // level ring / countdown (shown whenever gravity is live,
                // so the guidance also works in sample-photo mode)
                if (!inReview &&
                    _cameraState != _CameraState.denied &&
                    _sensorSeen) ...[
                  if (_machine.phase == CapturePhase.countdown)
                    _CountdownBadge(n: _machine.countdown)
                  else
                    LevelRing(
                      dx: _reading.dx,
                      dy: _reading.dy,
                      level: _machine.isLevel,
                    ),
                  const SizedBox(height: Sp.x4),
                  _HintStrip(
                    text: switch (_machine.phase) {
                      CapturePhase.unlevel => l.captureLevelHint,
                      CapturePhase.holding => l.captureHoldSteady,
                      _ => '',
                    },
                  ),
                  const SizedBox(height: Sp.x4),
                ],

                // no-camera / permission fallback cards
                if (!inReview &&
                    (_cameraState == _CameraState.none ||
                        _cameraState == _CameraState.denied))
                  Padding(
                    padding: const EdgeInsets.all(Sp.x6),
                    child: _FallbackCard(
                      denied: _cameraState == _CameraState.denied,
                      onUseSample: () => _machine.manualShutter(),
                    ),
                  ),

                // bottom controls
                if (inReview)
                  _ReviewBar(onRetake: _retake, onUse: _confirm)
                else if (_cameraState == _CameraState.ready)
                  _ShutterBar(
                    enabled: _machine.phase != CapturePhase.shooting,
                    level: _machine.isLevel || !_sensorSeen,
                    onTap: _onShutterTap,
                  ),
                const SizedBox(height: Sp.x4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- sub-widgets

class _CameraFill extends StatelessWidget {
  const _CameraFill({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.previewSize;
    if (size == null) return const SizedBox.shrink();
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        // portrait: preview size is landscape, swap
        width: size.height,
        height: size.width,
        child: CameraPreview(controller),
      ),
    );
  }
}

/// Frosted dark glass used by the camera chrome — blurs the live preview.
Widget _cameraGlass({required Widget child, double radius = 22}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.26),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
        child: child,
      ),
    ),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.label,
    required this.onClose,
    this.onSwitch,
    required this.switchTooltip,
  });

  final String label;
  final VoidCallback onClose;
  final VoidCallback? onSwitch;
  final String switchTooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.x3, vertical: Sp.x2),
      child: Row(
        children: [
          _cameraGlass(
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
            ),
          ),
          const Spacer(),
          _cameraGlass(
            radius: 20,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: 8),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const Spacer(),
          _cameraGlass(
            child: IconButton(
              onPressed: onSwitch,
              tooltip: switchTooltip,
              icon: Icon(
                Icons.cameraswitch_outlined,
                color: onSwitch == null
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.white,
              ),
              style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.n});

  final int n;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(n),
      tween: Tween(begin: 1.35, end: 1.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Text(
        '$n',
        style: TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.w200,
          color: Colors.white,
          fontFeatures: Numerals.features,
          shadows: [
            Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24),
          ],
        ),
      ),
    );
  }
}

class _HintStrip extends StatelessWidget {
  const _HintStrip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Motion.standard,
      child: text.isEmpty
          ? const SizedBox(height: 32)
          : Center(
              key: ValueKey(text),
              child: _cameraGlass(
                radius: 16,
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: Sp.x4),
                  // Hug the text: an aligning Container would expand to the
                  // full (bounded) width instead.
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      text,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _ShutterBar extends StatelessWidget {
  const _ShutterBar({
    required this.enabled,
    required this.level,
    required this.onTap,
  });

  final bool enabled;
  final bool level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const brass = Color(0xFFC4A46B);
    return Semantics(
      button: true,
      label: 'shutter',
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: Motion.standard,
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: level ? brass : Colors.white.withValues(alpha: 0.5),
              width: 4,
            ),
          ),
          padding: const EdgeInsets.all(6),
          child: AnimatedContainer(
            duration: Motion.standard,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: level
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewBar extends StatelessWidget {
  const _ReviewBar({required this.onRetake, required this.onUse});

  final VoidCallback onRetake;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.x6),
      child: Row(
        children: [
          Expanded(
            child: _cameraGlass(
              radius: 27,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 54),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                onPressed: onRetake,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(l.captureRetake),
              ),
            ),
          ),
          const SizedBox(width: Sp.x4),
          Expanded(
            flex: 2,
            child: BrassButton(
              label: l.captureUse,
              icon: Icons.check_rounded,
              onPressed: onUse,
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackCard extends StatelessWidget {
  const _FallbackCard({required this.denied, required this.onUseSample});

  final bool denied;
  final VoidCallback onUseSample;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // The camera stage is always cinematic-dark; use dark glass regardless
    // of the app theme so text stays legible over the black backdrop.
    return _cameraGlass(
      radius: Corners.card,
      child: Padding(
        padding: const EdgeInsets.all(Sp.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              denied
                  ? Icons.no_photography_outlined
                  : Icons.videocam_off_outlined,
              size: 30,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(height: Sp.x3),
            Text(
              denied ? l.capturePermissionTitle : l.captureNoCameraTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: Sp.x2),
            Text(
              denied ? l.capturePermissionBody : l.captureNoCameraBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: Sp.x5),
            if (denied) ...[
              BrassButton(
                label: l.captureOpenSettings,
                icon: Icons.settings_outlined,
                onPressed: openAppSettings,
              ),
              const SizedBox(height: Sp.x2),
            ],
            BrassButton(
              label: l.captureUseSample,
              icon: Icons.image_outlined,
              onPressed: onUseSample,
            ),
          ],
        ),
      ),
    );
  }
}
