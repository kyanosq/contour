import 'package:contour/app/measure_flow.dart';
import 'package:contour/design/theme.dart';
import 'package:contour/features/measure/subject_screen.dart';
import 'package:contour/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _host() => ChangeNotifierProvider(
      create: (_) => MeasureFlow(),
      child: MaterialApp(
        theme: lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
        home: const SubjectScreen(),
      ),
    );

void main() {
  testWidgets('empty identity blocks continue with inline errors',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.tap(find.text('下一步 · 拍摄'));
    // Continue with empty identity auto-scrolls to the offending section.
    await tester.pumpAndSettle();

    expect(find.text('请输入姓名'), findsOneWidget);
    expect(find.text('请输入手机或邮箱'), findsOneWidget);
  });
}
