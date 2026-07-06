import 'package:contour/app/measure_flow.dart';
import 'package:contour/app/records_store.dart';
import 'package:contour/app/session.dart';
import 'package:contour/design/theme.dart';
import 'package:contour/features/home/home_screen.dart';
import 'package:contour/features/measure/subject_screen.dart';
import 'package:contour/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _host(Widget screen, {double scale = 1.3}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final session = Session(prefs);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: session),
      ChangeNotifierProvider(create: (_) => MeasureFlow()),
      ChangeNotifierProvider(create: (_) => RecordsStore(session)),
    ],
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
        home: screen,
      ),
    ),
  );
}

void main() {
  testWidgets('home survives textScale 1.3 without overflow', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(await _host(const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
    expect(find.text('开始量体'), findsOneWidget);
  });

  testWidgets('subject form survives textScale 1.3 without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(await _host(const SubjectScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
    expect(find.text('下一步 · 拍摄'), findsOneWidget);
  });
}
