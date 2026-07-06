// Evaluator walkthrough: drives the real app on a device/simulator through
// the complete user journey in demo mode, saving screenshots as evidence.
//
// Run:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/walk_full_test.dart \
//     --dart-define=RESET=1 -d <device>
import 'package:contour/design/tape_picker.dart';
import 'package:contour/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> _shot(
    IntegrationTestWidgetsFlutterBinding binding, WidgetTester tester,
    String name) async {
  // Plain pumps only: screens with looping ambient animation (measuring ring)
  // would make pumpAndSettle spin until its 10-minute timeout.
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 120));
  try {
    await binding.convertFlutterSurfaceToImage();
  } catch (_) {}
  await tester.pump(const Duration(milliseconds: 80));
  try {
    await binding.takeScreenshot(name);
  } catch (_) {}
}

/// Pump until [finder] matches, failing after [timeout].
Future<void> _until(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 20)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 120));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('timeout waiting for $finder');
}

/// Scroll [finder] into view inside the first Scrollable, then settle.
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

  testWidgets('full demo journey', (tester) async {
    app.main();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    // ---- privacy gate on first run
    expect(find.text('隐私政策'), findsWidgets);
    await _shot(binding, tester, 'w01_privacy_gate');
    await tester.tap(find.text('同意并继续'));
    await tester.pumpAndSettle();

    // ---- login: demo channel
    await _shot(binding, tester, 'w02_login');
    await tester.tap(find.text('体验模式'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // ---- home
    await _until(tester, find.text('开始量体'));
    await _shot(binding, tester, 'w03_home');
    await tester.tap(find.text('开始量体'));
    await tester.pumpAndSettle();

    // ---- subject: validation error path first
    await _until(tester, find.text('这次为谁量体？'));
    await tester.tap(find.text('下一步 · 拍摄'));
    await tester.pumpAndSettle(); // auto-scrolls to offending section
    expect(find.text('请输入姓名'), findsOneWidget);
    await _shot(binding, tester, 'w04_subject_validation');

    // fill identity (visible after the auto-scroll)
    await tester.enterText(
        find.widgetWithText(TextField, '姓名'), '王小明');
    await tester.enterText(
        find.widgetWithText(TextField, '手机或邮箱'), '13800001234');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    // gender female then male
    await _see(tester, find.text('女'), delta: -120);
    await tester.tap(find.text('女'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('男'));
    await tester.pump(const Duration(milliseconds: 300));

    // drag height tape (first TapePicker)
    await _see(tester, find.byType(TapePicker).first);
    await tester.drag(find.byType(TapePicker).first, const Offset(-60, 0));
    await tester.pumpAndSettle();

    // unit switch to imperial and back
    await _see(tester, find.text('英尺 · 磅'), delta: -120);
    await tester.tap(find.text('英尺 · 磅'));
    await tester.pumpAndSettle();
    await _shot(binding, tester, 'w05_subject_imperial');
    await _see(tester, find.text('厘米 · 公斤'), delta: -120);
    await tester.tap(find.text('厘米 · 公斤'));
    await tester.pumpAndSettle();

    // garment fit
    await _see(tester, find.text('宽松'));
    await tester.tap(find.text('宽松'));
    await tester.pump(const Duration(milliseconds: 300));
    await _shot(binding, tester, 'w06_subject_filled');

    // continue → briefing
    await tester.tap(find.text('下一步 · 拍摄'));
    await tester.pumpAndSettle();
    await _until(tester, find.text('拍摄要领'));
    expect(find.textContaining('贴身衣物'), findsOneWidget);
    await _shot(binding, tester, 'w07_briefing');

    // ---- capture (simulator: no camera → sample fallback)
    await tester.tap(find.text('开始拍摄'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await _until(tester, find.text('使用示例照片'),
        timeout: const Duration(seconds: 10));
    expect(find.text('第 1 张 · 正面'), findsOneWidget);
    await _shot(binding, tester, 'w08_capture_front_fallback');
    await tester.tap(find.text('使用示例照片'));
    await tester.pump(const Duration(milliseconds: 800));
    await _until(tester, find.text('就用这张'));
    await _shot(binding, tester, 'w09_capture_front_review');
    // retake once, then re-shoot
    await tester.tap(find.text('重拍'));
    await tester.pumpAndSettle();
    await _until(tester, find.text('使用示例照片'));
    await tester.tap(find.text('使用示例照片'));
    await _until(tester, find.text('就用这张'));
    await tester.tap(find.text('就用这张'));
    await tester.pumpAndSettle();

    // side step
    await _until(tester, find.text('第 2 张 · 侧面'));
    await _shot(binding, tester, 'w10_capture_side');
    await tester.tap(find.text('使用示例照片'));
    await _until(tester, find.text('就用这张'));
    await tester.tap(find.text('就用这张'));
    await tester.pump(const Duration(milliseconds: 400));

    // ---- measuring → results
    await tester.pump(const Duration(milliseconds: 300));
    await _shot(binding, tester, 'w11_measuring');
    await _until(tester, find.text('量体结果'),
        timeout: const Duration(seconds: 15));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await _shot(binding, tester, 'w12_results');

    // three part groups present (scroll each into view — list is lazy)
    expect(find.text('围度'), findsOneWidget);
    await _see(tester, find.text('长度'));
    await _see(tester, find.text('宽与高'));
    await _shot(binding, tester, 'w12b_results_groups');
    await _see(tester, find.text('胸围'), delta: -160);

    // edit first row out of range → invalid state + save disabled
    await tester.tap(find.text('胸围'));
    await tester.pumpAndSettle();
    final plus = find.byIcon(Icons.add_rounded).first;
    for (var i = 0; i < 25; i++) {
      await tester.tap(plus);
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pumpAndSettle();
    expect(find.textContaining('超出可信范围'), findsOneWidget);
    await _shot(binding, tester, 'w13_results_invalid');
    final minus = find.byIcon(Icons.remove_rounded).first;
    for (var i = 0; i < 25; i++) {
      await tester.tap(minus);
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pumpAndSettle();
    expect(find.textContaining('超出可信范围'), findsNothing);

    // save → success
    await tester.tap(find.text('保存尺寸'));
    await _until(tester, find.text('已保存'),
        timeout: const Duration(seconds: 15));
    await tester.pumpAndSettle();
    await _shot(binding, tester, 'w14_success_qr');

    // done → home shows badge 1
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await _until(tester, find.text('开始量体'));
    expect(find.text('1 条'), findsOneWidget);
    await _shot(binding, tester, 'w15_home_badge');

    // ---- records list → detail
    await tester.tap(find.text('量体记录'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await _until(tester, find.text('王小明'));
    await _shot(binding, tester, 'w16_records_list');
    await tester.tap(find.text('王小明'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await _until(tester, find.text('量体码'));
    expect(find.text('胸围'), findsOneWidget);
    await _shot(binding, tester, 'w17_record_detail');

    // delete from detail
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await _until(tester, find.text('还没有量体记录'));
    await _shot(binding, tester, 'w18_records_empty');

    // ---- settings: language + theme
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    await _until(tester, find.text('开始量体'));
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    await _until(tester, find.text('设置'));
    await _shot(binding, tester, 'w19_settings');

    // dark theme
    await tester.tap(find.text('深色'));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    await _shot(binding, tester, 'w20_settings_dark');

    // language → English
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    await _until(tester, find.text('Settings'));
    await _shot(binding, tester, 'w21_settings_en_dark');

    // back home (EN, dark)
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    await _until(tester, find.text('Begin measuring'));
    await _shot(binding, tester, 'w22_home_en_dark');

    // restore zh + light for next runs
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('中文'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    await tester.tap(find.text('浅色'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    // sign out → login
    await tester.tap(find.text('退出登录'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await _until(tester, find.text('体验模式'));
    await _shot(binding, tester, 'w23_signed_out');
  });
}
