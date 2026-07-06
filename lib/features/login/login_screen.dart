import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/measure_api.dart';
import '../../api/remote_api.dart';
import '../../app/session.dart';
import '../../design/tick_ruler.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../settings/privacy_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _agreed = false;
  bool _busy = false;
  bool _accountFormOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowGate());
  }

  /// First launch: modal privacy gate. Decline exits the app (store policy).
  Future<void> _maybeShowGate() async {
    final session = context.read<Session>();
    if (session.privacyAccepted) {
      setState(() => _agreed = true);
      return;
    }
    final accepted = await showPrivacyGate(context);
    if (accepted) {
      await session.acceptPrivacy();
      if (mounted) setState(() => _agreed = true);
    } else {
      await SystemNavigator.pop();
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() job) async {
    final l = AppLocalizations.of(context);
    if (!_agreed) {
      showToast(context, l.mustAgreePrivacy, error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await job();
    } catch (e) {
      if (mounted) showToast(context, '$e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _accountLogin() => _run(() async {
        final l = AppLocalizations.of(context);
        final session = context.read<Session>();
        if (_username.text.trim().isEmpty || _password.text.isEmpty) {
          throw ApiFailure(l.loginMissingCredentials);
        }
        final token = await _remoteLogin(session, {
          'username': _username.text.trim(),
          'password': _password.text,
        });
        await session.acceptPrivacy();
        await session.signIn(token, ApiMode.remote);
      });

  Future<void> _guestLogin() => _run(() async {
        final session = context.read<Session>();
        final prefs = await SharedPreferences.getInstance();
        var uuid = prefs.getString('guest.uuid') ?? '';
        if (uuid.isEmpty) {
          uuid = UniqueKey().hashCode.toRadixString(16) +
              DateTime.now().microsecondsSinceEpoch.toRadixString(16);
          await prefs.setString('guest.uuid', uuid);
        }
        final token = await _remoteLogin(session, {'deviceId': uuid});
        await session.acceptPrivacy();
        await session.signIn(token, ApiMode.remote);
      });

  /// Credentialed channels always talk to the production backend, regardless
  /// of a previous demo session's mode.
  Future<String> _remoteLogin(
      Session session, Map<String, String> credentials) {
    return RemoteMeasureApi(session.dio).login(credentials);
  }

  Future<void> _demoLogin() => _run(() async {
        final session = context.read<Session>();
        await session.acceptPrivacy();
        await session.signIn('demo-token', ApiMode.demo);
      });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: WorkingVeil(
        visible: _busy,
        child: SafeArea(
          child: LayoutBuilder(builder: (context, box) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Sp.x6),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Sp.x12),
                    // Brand block
                    Text(
                      l.brandMark,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 10,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: Sp.x2),
                    Text(
                      l.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: Sp.x5),
                    const TickRuler(height: 12),
                    const SizedBox(height: Sp.x10),

                    // Account form (collapsible)
                    AnimatedCrossFade(
                      duration: Motion.standard,
                      sizeCurve: Motion.easeOut,
                      crossFadeState: _accountFormOpen
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: BrassButton(
                        label: l.loginAccount,
                        icon: Icons.person_outline,
                        onPressed: () =>
                            setState(() => _accountFormOpen = true),
                      ),
                      secondChild: ContourCard(
                        child: Column(
                          children: [
                            TextField(
                              controller: _username,
                              autocorrect: false,
                              decoration:
                                  InputDecoration(labelText: l.username),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: Sp.x3),
                            TextField(
                              controller: _password,
                              obscureText: true,
                              decoration:
                                  InputDecoration(labelText: l.password),
                              onSubmitted: (_) => _accountLogin(),
                            ),
                            const SizedBox(height: Sp.x5),
                            BrassButton(
                              label: l.loginAccount,
                              onPressed: _accountLogin,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Sp.x4),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(44, 50),
                              side: BorderSide(
                                  color: scheme.outlineVariant, width: 0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              foregroundColor: scheme.onSurface,
                            ),
                            onPressed: _busy ? null : _guestLogin,
                            child: Text(l.loginGuest),
                          ),
                        ),
                        const SizedBox(width: Sp.x3),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(44, 50),
                              side: BorderSide(
                                  color: brassOf(context), width: 0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              foregroundColor: brassOf(context),
                            ),
                            onPressed: _busy ? null : _demoLogin,
                            child: Text(l.loginDemo),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.x2),
                    Text(
                      l.loginDemoHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Sp.x8),

                    // Privacy gate
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: Checkbox(
                            value: _agreed,
                            activeColor: brassOf(context),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            onChanged: (v) {
                              HapticFeedback.selectionClick();
                              setState(() => _agreed = v ?? false);
                            },
                          ),
                        ),
                        Text(
                          l.privacyAgreePrefix,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => showPrivacySheet(context),
                          child: Text(
                            l.privacyPolicyLink,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: brassOf(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.x6),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
