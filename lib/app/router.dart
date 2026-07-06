import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/capture/briefing_screen.dart';
import '../features/capture/capture_screen.dart';
import '../features/home/home_screen.dart';
import '../features/login/login_screen.dart';
import '../features/measure/measuring_screen.dart';
import '../features/measure/results_screen.dart';
import '../features/measure/subject_screen.dart';
import '../features/measure/success_screen.dart';
import '../features/records/record_detail_screen.dart';
import '../features/records/records_screen.dart';
import '../features/settings/permissions_screen.dart';
import '../features/settings/privacy_screen.dart';
import '../features/settings/settings_screen.dart';
import 'session.dart';

GoRouter buildRouter(Session session) {
  return GoRouter(
    initialLocation: session.isAuthenticated ? '/' : '/login',
    refreshListenable: session,
    redirect: (context, state) {
      final loggedIn = session.isAuthenticated;
      final onLogin = state.matchedLocation == '/login';
      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            _fade(state, const LoginScreen(), ms: 400),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _fade(state, const HomeScreen()),
        routes: [
          GoRoute(
            path: 'subject',
            builder: (context, state) => const SubjectScreen(),
          ),
          GoRoute(
            path: 'briefing',
            builder: (context, state) => const BriefingScreen(),
          ),
          GoRoute(
            path: 'capture',
            builder: (context, state) => const CaptureScreen(),
          ),
          GoRoute(
            path: 'measuring',
            pageBuilder: (context, state) =>
                _fade(state, const MeasuringScreen()),
          ),
          GoRoute(
            path: 'results',
            builder: (context, state) => const ResultsScreen(),
          ),
          GoRoute(
            path: 'success',
            pageBuilder: (context, state) =>
                _fade(state, const SuccessScreen()),
          ),
          GoRoute(
            path: 'records',
            builder: (context, state) => const RecordsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => RecordDetailScreen(
                  recordId:
                      int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
                  seed: state.extra is MeasureRecordSeed
                      ? state.extra as MeasureRecordSeed
                      : null,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'permissions',
                builder: (context, state) => const PermissionsScreen(),
              ),
              GoRoute(
                path: 'privacy',
                builder: (context, state) => const PrivacyScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

CustomTransitionPage<void> _fade(GoRouterState state, Widget child,
    {int ms = 240}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration(milliseconds: ms),
    transitionsBuilder: (context, animation, secondary, child) =>
        FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: child,
    ),
  );
}
