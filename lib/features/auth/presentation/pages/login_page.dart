import 'package:dolibarr_mobile/core/config/env.dart';
import 'package:dolibarr_mobile/core/errors/failure.dart';
import 'package:dolibarr_mobile/core/routing/route_paths.dart';
import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/features/auth/domain/entities/credentials.dart';
import 'package:dolibarr_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController();
  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();

  AuthMode _mode = AuthMode.apiKeyDirect;
  bool _passwordVisible = false;
  bool _apiKeyVisible = false;
  bool _busyTest = false;
  bool _busySubmit = false;
  String? _testResult;
  String? _testError;

  @override
  void initState() {
    super.initState();
    if (Env.defaultDolibarrUrl.isNotEmpty) {
      _urlCtrl.text = Env.defaultDolibarrUrl;
    }
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  Credentials _buildCredentials() {
    return _mode == AuthMode.loginPassword
        ? Credentials.loginPassword(
            baseUrl: _urlCtrl.text.trim(),
            login: _loginCtrl.text.trim(),
            password: _passwordCtrl.text,
          )
        : Credentials.apiKey(
            baseUrl: _urlCtrl.text.trim(),
            apiKey: _apiKeyCtrl.text.trim(),
          );
  }

  Future<void> _onTest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busyTest = true;
      _testResult = null;
      _testError = null;
    });
    final result = await ref
        .read(authNotifierProvider.notifier)
        .testConnection(_buildCredentials());
    if (!mounted) return;
    setState(() {
      _busyTest = false;
      result.fold(
        onSuccess: (login) => _testResult = 'Connecté en tant que $login',
        onFailure: (f) => _testError = _humanize(f),
      );
    });
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busySubmit = true);
    final result = await ref
        .read(authNotifierProvider.notifier)
        .login(_buildCredentials());
    if (!mounted) return;
    setState(() => _busySubmit = false);
    result.fold(
      onSuccess: (_) {
        final next = GoRouterState.of(context).uri.queryParameters['next'];
        context.go(next ?? RoutePaths.dashboard);
      },
      onFailure: (f) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_humanize(f)),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      },
    );
  }

  String _humanize(Failure f) => switch (f) {
    UnauthorizedFailure() =>
      'Identifiants ou clé API invalides. Vérifiez et réessayez.',
    NetworkFailure() =>
      'Impossible de joindre l’instance. Vérifiez l’URL et la connexion.',
    ServerFailure(:final statusCode) =>
      'Erreur serveur ($statusCode). Réessayez plus tard.',
    ValidationFailure() => 'Requête invalide.',
    _ => 'Erreur inattendue. Réessayez.',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTokens.spaceLg),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppTokens.spaceLg),
                    Icon(
                      Icons.business_center_outlined,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: AppTokens.spaceMd),
                    Text(
                      'Connexion à votre instance',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTokens.spaceXl),
                    TextFormField(
                      controller: _urlCtrl,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'URL de l’instance',
                        hintText: 'https://erp.exemple.com',
                        prefixIcon: Icon(LucideIcons.link),
                      ),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'Champ requis';
                        if (!value.startsWith('http')) {
                          return 'URL invalide (http:// ou https://)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTokens.spaceLg),
                    _ModeSelector(
                      mode: _mode,
                      onChanged: (m) => setState(() => _mode = m),
                    ),
                    const SizedBox(height: AppTokens.spaceMd),
                    if (_mode == AuthMode.apiKeyDirect)
                      _apiKeyField(theme)
                    else
                      _loginPasswordFields(theme),
                    if (_testResult != null) ...[
                      const SizedBox(height: AppTokens.spaceMd),
                      _ResultBanner(message: _testResult!, isError: false),
                    ],
                    if (_testError != null) ...[
                      const SizedBox(height: AppTokens.spaceMd),
                      _ResultBanner(message: _testError!, isError: true),
                    ],
                    const SizedBox(height: AppTokens.spaceLg),
                    OutlinedButton.icon(
                      onPressed: _busyTest || _busySubmit ? null : _onTest,
                      icon: _busyTest
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(LucideIcons.checkCircle),
                      label: const Text('Tester la connexion'),
                    ),
                    const SizedBox(height: AppTokens.spaceMd),
                    FilledButton(
                      onPressed: _busySubmit || _busyTest ? null : _onSubmit,
                      child: _busySubmit
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Se connecter'),
                    ),
                    const SizedBox(height: AppTokens.spaceLg),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.spaceXs),
                child: IconButton(
                  icon: const Icon(LucideIcons.helpCircle),
                  tooltip: 'Aide à la connexion',
                  onPressed: () => context.push(RoutePaths.loginHelp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _apiKeyField(ThemeData theme) => TextFormField(
    controller: _apiKeyCtrl,
    obscureText: !_apiKeyVisible,
    decoration: InputDecoration(
      labelText: 'Clé API',
      helperText: 'Recommandé — créez-la dans votre profil Dolibarr',
      prefixIcon: const Icon(LucideIcons.key),
      suffixIcon: IconButton(
        icon: Icon(_apiKeyVisible ? LucideIcons.eyeOff : LucideIcons.eye),
        onPressed: () => setState(() => _apiKeyVisible = !_apiKeyVisible),
      ),
    ),
    validator: (v) => (v?.trim().isEmpty ?? true) ? 'Champ requis' : null,
  );

  Widget _loginPasswordFields(ThemeData theme) => Column(
    children: [
      TextFormField(
        controller: _loginCtrl,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Identifiant',
          prefixIcon: Icon(LucideIcons.user),
        ),
        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Champ requis' : null,
      ),
      const SizedBox(height: AppTokens.spaceMd),
      TextFormField(
        controller: _passwordCtrl,
        obscureText: !_passwordVisible,
        decoration: InputDecoration(
          labelText: 'Mot de passe',
          prefixIcon: const Icon(LucideIcons.lock),
          suffixIcon: IconButton(
            icon: Icon(_passwordVisible ? LucideIcons.eyeOff : LucideIcons.eye),
            onPressed: () =>
                setState(() => _passwordVisible = !_passwordVisible),
          ),
        ),
        validator: (v) => (v?.isEmpty ?? true) ? 'Champ requis' : null,
      ),
    ],
  );
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.mode, required this.onChanged});
  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AuthMode>(
      segments: const [
        ButtonSegment(
          value: AuthMode.apiKeyDirect,
          label: Text('Clé API'),
          icon: Icon(LucideIcons.key, size: 16),
        ),
        ButtonSegment(
          value: AuthMode.loginPassword,
          label: Text('Identifiants'),
          icon: Icon(LucideIcons.user, size: 16),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.message, required this.isError});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      decoration: BoxDecoration(
        color: isError
            ? scheme.errorContainer
            : scheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTokens.radiusChip),
      ),
      child: Row(
        children: [
          Icon(
            isError ? LucideIcons.alertCircle : LucideIcons.checkCircle,
            color: isError ? scheme.onErrorContainer : scheme.primary,
          ),
          const SizedBox(width: AppTokens.spaceSm),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
