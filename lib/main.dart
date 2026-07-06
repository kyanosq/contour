import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/measure_flow.dart';
import 'app/records_store.dart';
import 'app/router.dart';
import 'app/session.dart';
import 'design/theme.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  final session = Session(prefs);
  unawaited(session.loadAppVersion());
  runApp(ContourApp(session: session));
}

class ContourApp extends StatefulWidget {
  const ContourApp({super.key, required this.session});

  final Session session;

  @override
  State<ContourApp> createState() => _ContourAppState();
}

class _ContourAppState extends State<ContourApp> {
  late final router = buildRouter(widget.session);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.session),
        ChangeNotifierProvider(create: (_) => MeasureFlow()),
        ChangeNotifierProvider(create: (_) => RecordsStore(widget.session)),
      ],
      child: Consumer<Session>(
        builder: (context, session, _) => MaterialApp.router(
          title: 'Contour',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: session.themeMode,
          locale: session.locale,
          supportedLocales: const [Locale('zh'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
  }
}
