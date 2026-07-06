// Evaluator walkthrough #2 — the corners the main journey skips:
//   • agreement checkbox gate on login
//   • settings → privacy policy page (built-in text offline)
//   • settings → permissions page (live statuses, must not crash)
//   • cancel-account double confirmation (dismissed)
//   • dark-mode subject + results pages
//   • share sheet launch from success page (last step; sheet stays up)
//
// Run:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/walk_misc_test.dart \
//     --dart-define=RESET=1 -d <device> --keep-app-running
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:contour/main.dart' as app;

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
    await tester.pump(const Duration(milliseconds: 120));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('timeout waiting for $finder');
}

Future<void> _see(WidgetTester tester, Finder finder,
    {double delta = 120}) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, delta,
        scrollable: find.byType(Scrollable).first, maxScrolls: 60);
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('gates, settings corners, dark funnel, share sheet',
      (tester) async {
    app.main();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    // ---- privacy gate, then UNCHECK the agreement to verify the block
    await tester.tap(find.text('同意并继续'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('体验模式'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('请先阅读并同意隐私政策'), findsOneWidget);
    await _shot(binding, tester, 'm01_agreement_block');
    await tester.pumpAndSettle(const Duration(seconds: 3)); // toast fades

    // re-check and enter demo
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('体验模式'));
    await _until(tester, find.text('开始量体'));

    // ---- settings corners
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    await _until(tester, find.text('设置'));

    // privacy policy page (offline → built-in text)
    await tester.tap(find.text('隐私政策'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.textContaining('身体数据'), findsWidgets);
    await _shot(binding, tester, 'm02_privacy_page');
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();

    // permissions page renders live statuses
    await tester.tap(find.text('权限管理'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await _until(tester, find.text('相机'));
    await _shot(binding, tester, 'm03_permissions');
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();

    // cancel-account double confirm — dismiss
    await _see(tester, find.text('注销账号'));
    await tester.tap(find.text('注销账号'));
    await tester.pumpAndSettle();
    expect(find.text('取消'), findsOneWidget);
    await _shot(binding, tester, 'm04_cancel_confirm');
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsOneWidget); // still signed in

    // ---- dark mode + funnel screenshots
    await tester.tap(find.text('深色'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始量体'));
    await tester.pumpAndSettle();
    await _until(tester, find.text('这次为谁量体？'));
    await _shot(binding, tester, 'm05_subject_dark');

    await tester.tap(find.text('下一步 · 拍摄'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '姓名'), '深色评测');
    await tester.enterText(
        find.widgetWithText(TextField, '手机或邮箱'), 'dark@contour.app');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一步 · 拍摄'));
    await tester.pumpAndSettle();
    await _until(tester, find.text('拍摄要领'));
    await _shot(binding, tester, 'm06_briefing_dark');
    await tester.tap(find.text('开始拍摄'));
    await tester.pumpAndSettle(const Duration(milliseconds: 800));
    await _until(tester, find.text('使用示例照片'),
        timeout: const Duration(seconds: 10));
    await tester.tap(find.text('使用示例照片'));
    await _until(tester, find.text('就用这张'));
    await tester.tap(find.text('就用这张'));
    await tester.pumpAndSettle();
    await _until(tester, find.text('使用示例照片'));
    await tester.tap(find.text('使用示例照片'));
    await _until(tester, find.text('就用这张'));
    await tester.tap(find.text('就用这张'));
    await tester.pump(const Duration(milliseconds: 500));

    // measuring page in dark (demo latency ≈1.5 s makes it capturable)
    await _shot(binding, tester, 'm07_measuring_dark');
    await _until(tester, find.text('量体结果'),
        timeout: const Duration(seconds: 15));
    await tester.pump(const Duration(seconds: 1));
    await _shot(binding, tester, 'm08_results_dark');

    // save → success → SHARE (final step; the native sheet stays up and the
    // host takes a simctl screenshot right after flutter drive returns)
    await _see(tester, find.text('保存尺寸'));
    await tester.tap(find.text('保存尺寸'));
    await _until(tester, find.text('已保存'),
        timeout: const Duration(seconds: 15));
    await tester.pumpAndSettle();
    await _shot(binding, tester, 'm09_success_dark');
    await tester.tap(find.text('分享量体码'));
    await tester.pump(const Duration(seconds: 2));
    // No crash = pass; the ShareResult future stays pending while the sheet
    // is open, so don't await anything share-related here.
  });
}
