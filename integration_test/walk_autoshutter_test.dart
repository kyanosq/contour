// Auto-shutter verification: scripted gravity (SIM_GRAVITY=1) starts tilted,
// goes level after 2.5 s; the capture machine must hold, count down and fire
// the shutter without any tap.
//
// Run:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/walk_autoshutter_test.dart \
//     --dart-define=RESET=1 --dart-define=SIM_GRAVITY=1 -d <device>
import 'package:contour/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> _shot(
    IntegrationTestWidgetsFlutterBinding binding, WidgetTester tester,
    String name) async {
  await tester.pump(const Duration(milliseconds: 250));
  try {
    await binding.convertFlutterSurfaceToImage();
  } catch (_) {}
  await tester.pump(const Duration(milliseconds: 80));
  try {
    await binding.takeScreenshot(name);
  } catch (_) {}
}

Future<void> _until(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 20)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('timeout waiting for $finder');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('level gate blocks, then auto-shutter fires', (tester) async {
    app.main();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    // first-run gate + demo login
    await tester.tap(find.text('同意并继续'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('体验模式'));
    await _until(tester, find.text('开始量体'));
    await tester.tap(find.text('开始量体'));
    await tester.pumpAndSettle();

    // subject (identity only — defaults are valid)
    await _until(tester, find.text('这次为谁量体？'));
    await tester.tap(find.text('下一步 · 拍摄'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '姓名'), '自动门');
    await tester.enterText(
        find.widgetWithText(TextField, '手机或邮箱'), 'auto@contour.app');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一步 · 拍摄'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始拍摄'));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    // tilted phase: hint visible, no countdown yet
    await _until(tester, find.text('第 1 张 · 正面'));
    await _shot(binding, tester, 'a01_tilted');
    expect(find.text('微调手机，让气泡进入圆环'), findsOneWidget);

    // wait for level → holding → countdown → auto shutter → review
    // (2.5 s tilt + 1 s hold + 3 s count ≈ 6.5 s, give slack)
    await _until(tester, find.text('保持稳定…'),
        timeout: const Duration(seconds: 8));
    await _shot(binding, tester, 'a02_holding');
    await _until(tester, find.text('就用这张'),
        timeout: const Duration(seconds: 10));
    await _shot(binding, tester, 'a03_auto_fired_review');
  });
}
