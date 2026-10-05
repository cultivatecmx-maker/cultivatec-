import 'package:cultivatec_flutter/core/widgets/living_wokov.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';
import 'package:cultivatec_flutter/core/utils/validators.dart';
import 'package:cultivatec_flutter/core/widgets/blue_confetti.dart';
import 'package:cultivatec_flutter/core/widgets/cartoon_button.dart';
import 'package:cultivatec_flutter/core/widgets/password_checklist.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:cultivatec_flutter/providers/auth_provider.dart';

enum AuthViewState { welcome, login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthViewState _viewState = AuthViewState.welcome;
  bool _showPassword = false;
  bool _showConfirm = false;
  bool _submitted = false;
  bool _resetting = false;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();

  /// Errores por campo: 'username', 'email', 'password', 'confirm'.
  final Map<String, String?> _errors = {};

  /// Contador para re-disparar la animación de "temblor" de cada campo.
  final Map<String, int> _shake = {};
  String? _localError;

  @override
  void initState() {
    super.initState();
    // Bienvenida con una lluvia suave de confeti azul.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) BlueConfetti.show(context, style: ConfettiStyle.rain, count: 60);
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Validación
  // ---------------------------------------------------------------------------
  List<String> get _activeFields => _viewState == AuthViewState.login
      ? ['email', 'password']
      : ['username', 'email', 'password', 'confirm'];

  String? _validateField(String key) {
    final isLogin = _viewState == AuthViewState.login;
    switch (key) {
      case 'username':
        return Validators.username(_usernameCtrl.text);
      case 'email':
        if (isLogin) {
          return _emailCtrl.text.trim().isEmpty ? 'Escribe tu nombre de inventor o tu correo.' : null;
        }
        return Validators.email(_emailCtrl.text);
      case 'password':
        return isLogin ? Validators.loginPassword(_passwordCtrl.text) : Validators.newPassword(_passwordCtrl.text);
      case 'confirm':
        return Validators.confirmPassword(_passwordCtrl.text, _confirmCtrl.text);
    }
    return null;
  }

  bool _validateAll() {
    var ok = true;
    for (final k in _activeFields) {
      final e = _validateField(k);
      _errors[k] = e;
      if (e != null) {
        ok = false;
        _shake[k] = (_shake[k] ?? 0) + 1;
      }
    }
    return ok;
  }

  void _onChanged(String key) {
    final auth = context.read<AuthProvider>();
    if (auth.error != null) auth.clearError();
    setState(() {
      _localError = null;
      final live = _submitted || (key == 'confirm' && _confirmCtrl.text.isNotEmpty);
      if (live) _errors[key] = _validateField(key);
      if (key == 'password' && _confirmCtrl.text.isNotEmpty) {
        _errors['confirm'] = _validateField('confirm');
      }
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    auth.clearError();
    setState(() {
      _submitted = true;
      _localError = null;
    });
    final ok = _validateAll();
    setState(() {});
    if (!ok) {
      SoundService.playWrong();
      return;
    }

    // Permite que el sistema ofrezca guardar la contraseña.
    TextInput.finishAutofillContext();

    if (_viewState == AuthViewState.login) {
      auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    } else {
      auth.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        username: _usernameCtrl.text.trim(),
        fullName: _usernameCtrl.text.trim(), // Se usa el nombre de inventor para simplificar a los niños.
      );
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@') || Validators.email(email) != null) {
      setState(() {
        _errors['email'] = 'Escribe tu correo aquí arriba y vuelve a tocar "¿Olvidaste tu contraseña?".';
        _shake['email'] = (_shake['email'] ?? 0) + 1;
      });
      SoundService.playWrong();
      return;
    }
    setState(() => _resetting = true);
    final err = await context.read<AuthProvider>().sendPasswordReset(email);
    if (!mounted) return;
    setState(() => _resetting = false);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: err == null ? AppTheme.brandBlue : AppTheme.accentRed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          err ?? '¡Listo! Si existe una cuenta con ese correo, te enviamos un enlace para crear una nueva contraseña.',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
    if (err == null) SoundService.playXP();
  }

  void _changeState(AuthViewState newState) {
    SoundService.playClick();
    context.read<AuthProvider>().clearError();
    setState(() {
      _viewState = newState;
      _localError = null;
      _submitted = false;
      _errors.clear();
      _showPassword = false;
      _showConfirm = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Stack(
        children: [
          const Positioned.fill(child: _AuthBackdrop()),
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(anim),
                  child: child,
                ),
              ),
              child: _viewState == AuthViewState.welcome ? _buildWelcomeView() : _buildFormView(),
            ),
          ),
        ],
      ),
    );
  }

  // --- BIENVENIDA -------------------------------------------------------------
  Widget _buildWelcomeView() {
    return LayoutBuilder(
      key: const ValueKey('welcome'),
      builder: (context, c) {
        // Wokov se adapta al alto disponible; si aun así no cabe, la pantalla scrollea.
        final mascot = (c.maxHeight * 0.34).clamp(150.0, 290.0);
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 28),
                    const Text(
                      '¡Comencemos!',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, curve: Curves.easeOutBack),
                    const SizedBox(height: 4),
                    const Text(
                      '¡Vamos a crear e inventar!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.iceBlue),
                    ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/cultivatec_logo.png',
                          width: 16,
                          height: 16,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'by Cultivatec',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.8),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: mascot * 0.65,
                        height: 18,
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryDark.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      WokovMascot(
                        pose: WokovPose.idle,
                        size: mascot,
                        message: '¡Hola! Soy Wokov',
                        idleAction: WokovAction.wave,
                        actionInterval: const Duration(seconds: 4),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: Column(
                    children: [
                      CartoonButton.success(
                        text: 'Crear cuenta',
                        onPressed: () => _changeState(AuthViewState.register),
                      ),
                      const SizedBox(height: 12),
                      CartoonButton.secondary(
                        text: 'Ya tengo cuenta',
                        onPressed: () => _changeState(AuthViewState.login),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- LOGIN / REGISTRO --------------------------------------------------------
  Widget _buildFormView() {
    final isLogin = _viewState == AuthViewState.login;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Consumer<AuthProvider>(
      key: ValueKey(_viewState),
      builder: (context, auth, _) {
        final serverError = _localError ?? auth.error;
        final rules = PasswordRules.evaluate(_passwordCtrl.text);
        final strongPassword = !isLogin && rules.meetsRequired && rules.strength >= 3;

        WokovPose pose;
        String? message;
        if (auth.isLoading) {
          pose = WokovPose.think;
          message = '¡Un momento!';
        } else if (serverError != null || _errors.values.any((e) => e != null)) {
          pose = WokovPose.worried;
          message = '¡Ups! Revisa los datos';
        } else if (strongPassword) {
          pose = WokovPose.victory;
          message = '¡Contraseña genial!';
        } else {
          pose = WokovPose.idle;
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _BackChip(onTap: () => _changeState(AuthViewState.welcome)),
                  const Spacer(),
                ],
              ),
            ),
            // AnimatedSize (no altura fija): al abrir/cerrar el teclado no hay overflow.
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: keyboardOpen
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: SizedBox(
                        height: 145,
                        child: WokovMascot(
                          pose: pose,
                          size: 140,
                          message: message,
                          tappable: false,
                          idleAction: WokovAction.wave,
                          actionInterval: const Duration(seconds: 6),
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: AutofillGroup(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          isLogin ? 'Iniciar sesión' : 'Nuevo inventor',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!isLogin) ...[
                        _field(
                          id: 'username',
                          label: 'Tu nombre de inventor',
                          hint: 'Leo',
                          icon: Icons.badge_rounded,
                          controller: _usernameCtrl,
                          autofillHints: const [AutofillHints.newUsername],
                          helper: 'Solo letras, números y guion bajo (_)',
                          formatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                            LengthLimitingTextInputFormatter(20),
                          ],
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _field(
                        id: 'email',
                        label: isLogin ? 'Tu nombre de inventor o correo' : 'Tu correo o el de tus papás',
                        hint: isLogin ? 'leo  ·  inventor@cultivatec.com' : 'inventor@cultivatec.com',
                        icon: isLogin ? Icons.person_rounded : Icons.mail_rounded,
                        controller: _emailCtrl,
                        autofillHints: isLogin ? const [AutofillHints.username, AutofillHints.email] : const [AutofillHints.email],
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        formatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                      ),
                      const SizedBox(height: 16),
                      _field(
                        id: 'password',
                        label: isLogin ? 'Tu contraseña secreta' : 'Crea tu contraseña secreta',
                        hint: '••••••••',
                        icon: Icons.lock_rounded,
                        controller: _passwordCtrl,
                        autofillHints: isLogin ? const [AutofillHints.password] : const [AutofillHints.newPassword],
                        obscure: !_showPassword,
                        onToggleObscure: () => setState(() => _showPassword = !_showPassword),
                        showingPassword: _showPassword,
                        textInputAction: isLogin ? TextInputAction.done : TextInputAction.next,
                        onSubmitted: isLogin ? (_) => _submit() : null,
                      ),
                      if (isLogin) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _resetting ? null : _forgotPassword,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                _resetting ? 'Enviando correo…' : '¿Olvidaste tu contraseña?',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        PasswordChecklist(password: _passwordCtrl.text),
                        const SizedBox(height: 16),
                        _field(
                          id: 'confirm',
                          label: 'Repite tu contraseña',
                          hint: '••••••••',
                          icon: Icons.lock_reset_rounded,
                          controller: _confirmCtrl,
                          autofillHints: const [AutofillHints.newPassword],
                          obscure: !_showConfirm,
                          onToggleObscure: () => setState(() => _showConfirm = !_showConfirm),
                          showingPassword: _showConfirm,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          successWhen: _confirmCtrl.text.isNotEmpty && _confirmCtrl.text == _passwordCtrl.text,
                        ),
                      ],
                      const SizedBox(height: 20),
                      if (serverError != null) _buildError(serverError),
                      CartoonButton(
                        text: isLogin ? 'Iniciar sesión' : 'Crear cuenta',
                        isLoading: auth.isLoading,
                        onPressed: auth.isLoading ? null : _submit,
                      ),
                      const SizedBox(height: 16),
                      const _OrDivider(),
                      const SizedBox(height: 16),
                      _buildSocialButtons(auth),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () => _changeState(isLogin ? AuthViewState.register : AuthViewState.login),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              isLogin ? '¿No tienes cuenta? Crea una' : 'Ya tengo cuenta · Iniciar sesión',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Piezas
  // ---------------------------------------------------------------------------
  Widget _field({
    required String id,
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    bool showingPassword = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? formatters,
    Iterable<String>? autofillHints,
    String? helper,
    ValueChanged<String>? onSubmitted,
    bool successWhen = false,
  }) {
    final error = _errors[id];
    final hasError = error != null;

    OutlineInputBorder border(Color c, [double w = 2]) =>
        OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c, width: w));

    Widget? suffix;
    if (onToggleObscure != null) {
      suffix = IconButton(
        tooltip: showingPassword ? 'Ocultar' : 'Mostrar',
        icon: Icon(showingPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppTheme.textMuted),
        onPressed: onToggleObscure,
      );
    } else if (successWhen) {
      suffix = const Icon(Icons.check_circle_rounded, color: AppTheme.primaryBlue);
    }

    final tick = _shake[id] ?? 0;
    Widget textField = TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: formatters,
      autofillHints: autofillHints,
      autocorrect: false,
      enableSuggestions: !obscure,
      onSubmitted: onSubmitted,
      onChanged: (_) => _onChanged(id),
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textHint, fontWeight: FontWeight.w700),
        filled: true,
        fillColor: hasError ? const Color(0xFFFFF1F1) : AppTheme.bgPrimary,
        prefixIcon: Icon(icon, color: hasError ? AppTheme.accentRed : AppTheme.primaryLight),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        helperText: hasError ? null : helper,
        helperStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
        errorText: error,
        errorMaxLines: 3,
        errorStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppTheme.accentRed),
        enabledBorder: border(AppTheme.borderColor),
        focusedBorder: border(AppTheme.primaryBlue, 2.5),
        errorBorder: border(AppTheme.accentRed),
        focusedErrorBorder: border(AppTheme.accentRed, 2.5),
        border: border(AppTheme.borderColor),
      ),
    );

    // Temblor cuando el campo tiene un error nuevo.
    if (tick > 0 && hasError) {
      textField = textField
          .animate(key: ValueKey('shake_${id}_$tick'))
          .shake(hz: 5, duration: 380.ms, offset: const Offset(5, 0));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
        ),
        textField,
      ],
    );
  }

  Widget _buildSocialButtons(AuthProvider auth) {
    return CartoonButton.secondary(
      text: 'Continuar con Google',
      icon: Icons.g_mobiledata_rounded,
      onPressed: () {
        setState(() => _localError = null);
        auth.clearError();
        auth.loginWithGoogle();
      },
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accentRed, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_rounded, color: AppTheme.accentRed, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.accentRedDark),
              ),
            ),
          ],
        ),
      ).animate(key: ValueKey(message)).fadeIn(duration: 200.ms).shake(hz: 5, duration: 380.ms, offset: const Offset(4, 0)),
    );
  }
}

/// Fondo azul sólido con círculos translucidos y chispas (sin degradados).
class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    Widget circle(double size, double alpha) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
        );
    return Stack(
      children: [
        Positioned(top: -70, left: -60, child: circle(220, 0.07)),
        Positioned(top: 120, right: -80, child: circle(200, 0.06)),
        Positioned(bottom: 160, left: -90, child: circle(240, 0.05)),
        for (final p in const [
          Offset(0.12, 0.12),
          Offset(0.85, 0.08),
          Offset(0.9, 0.34),
          Offset(0.07, 0.4),
          Offset(0.78, 0.55),
        ])
          Positioned.fill(
            child: Align(
              alignment: Alignment(p.dx * 2 - 1, p.dy * 2 - 1),
              child: Icon(Icons.add_rounded, size: 18, color: Colors.white.withValues(alpha: 0.35))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(begin: 0.3, end: 1, duration: (1200 + (p.dx * 1000).toInt()).ms),
            ),
          ),
      ],
    );
  }
}

class _BackChip extends StatelessWidget {
  final VoidCallback onTap;
  const _BackChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppTheme.primaryDark.withValues(alpha: 0.6), offset: const Offset(0, 4), blurRadius: 0)],
        ),
        child: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryBlue),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppTheme.borderColor, thickness: 2)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('o', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
        ),
        Expanded(child: Divider(color: AppTheme.borderColor, thickness: 2)),
      ],
    );
  }
}
