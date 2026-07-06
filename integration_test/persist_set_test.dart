// Persistence pass 1/2 (run WITHOUT RESET): from a clean signed-out state,
// log into demo, switch language to English and theme to dark, save one
// measurement record. `persist_check_test.dart` relaunches and verifies.
import 'package:contour/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> _until(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 20)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 120));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('timeout waiting for $finder');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('set: demo login, EN + dark, one saved record', (tester) async {
    app.main();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    // privacy gate may or may not appear depending on prior state
    if (find.text('同意并继续').evaluate().isNotEmpty) {
      await tester.tap(find.text('同意并继续'));
      await tester.pumpAndSettle();
    }
    if (find.text('体验模式').evaluate().isNotEmpty) {
      await tester.tap(find.text('体验模式'));
    }
    await _until(tester, find.text('开始量体'));

    // settings: EN + dark
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    await _until(tester, find.text('设置'));
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    await _until(tester, find.text('Settings'));
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    await _until(tester, find.text('Begin measuring'));

    // quick measure run to persist one record
    await tester.tap(find.text('Begin measuring'));
    await tester.pumpAndSettle();
    await _until(tester, find.text('Who are we measuring?'));
    await tester.tap(find.text('Next · Capture'));
    await tester.pumpAndSettle(); // auto-scroll to identity errors
    await tester.enterText(
        find.widgetWithText(TextField, 'Name'), 'Persistence Kid');
    await tester.enterText(
        find.widgetWithText(TextField, 'Phone or email'), 'persist@x.io');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next · Capture'));
    await tester.pumpAndSettle();
    await _until(tester, find.text('Start capture'));
    await tester.tap(find.text('Start capture'));
    await tester.pumpAndSettle(const Duration(milliseconds: 800));
    await _until(tester, find.text('Use sample photos'),
        timeout: const Duration(seconds: 10));
    await tester.tap(find.text('Use sample photos'));
    await _until(tester, find.text('Use this shot'));
    await tester.tap(find.text('Use this shot'));
    await tester.pumpAndSettle();
    await _until(tester, find.text('Use sample photos'));
    await tester.tap(find.text('Use sample photos'));
    await _until(tester, find.text('Use this shot'));
    await tester.tap(find.text('Use this shot'));
    await tester.pump(const Duration(milliseconds: 400));
    await _until(tester, find.text('Save sizes'),
        timeout: const Duration(seconds: 15));
    await tester.tap(find.text('Save sizes'));
    await _until(tester, find.text('Saved'),
        timeout: const Duration(seconds: 15));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await _until(tester, find.text('Begin measuring'));
  });
}
