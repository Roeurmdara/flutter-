import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../data/providers/auth_provider.dart';
import 'forget_password.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
class _C {
// =========================
// CLEAN MODERN LIGHT COLORS
// =========================

  static const Color bg = Color(0xFFFFFFFF); // clean white background
  static const Color ink = Color(0xFF1F2937); // modern dark text
  static const Color inkSoft = Color(0xFF6B7280); // secondary text

// Purple + Green Theme
  static const Color accent = Color(0xFF7C3AED); // vibrant purple
  static const Color accentSecondary = Color(0xFF3D6B4F); // forest green

// Soft UI Colors
  static const Color accentSoft = Color(0xFFF3E8FF); // soft purple tint
  static const Color divider = Color(0xFFE5E7EB); // modern border/divider
  static const Color field = Color(0xFFF8FAFC); // input/card background

  static const Color white = Color(0xFFFFFFFF);
}

// ─── Typography helpers ────────────────────────────────────────────────────────
TextStyle _t(double size, FontWeight w, Color c,
        {double? letterSpacing, double? height}) =>
    TextStyle(
      fontSize: size,
      fontWeight: w,
      color: c,
      letterSpacing: letterSpacing,
      height: height,
      fontFamily:
          'Georgia', // Elegant serif — swap to any Google Font you prefer
    );

// ─── Screen ───────────────────────────────────────────────────────────────────
class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreeToTerms = false;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();
  final _confirmPassword = TextEditingController();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _email.dispose();
    _password.dispose();
    _username.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _switchTab(bool login) {
    _fadeCtrl.reset();
    setState(() => _isLogin = login);
    _fadeCtrl.forward();

    // Clear error messages when switching tabs
    ref.read(authProvider.notifier).clearError();
  }

  Future<void> _submit() async {
    final authNotifier = ref.read(authProvider.notifier);

    if (_isLogin) {
      // Login
      if (_username.text.isEmpty || _password.text.isEmpty) {
        _showErrorSnackbar('Please enter username and password');
        return;
      }

      final success = await authNotifier.login(
        username: _username.text,
        password: _password.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        widget.onLoginSuccess();
      }
    } else {
      // Register
      if (_username.text.isEmpty ||
          _email.text.isEmpty ||
          _password.text.isEmpty ||
          _confirmPassword.text.isEmpty) {
        _showErrorSnackbar('Please fill in all fields');
        return;
      }

      if (_password.text != _confirmPassword.text) {
        _showErrorSnackbar('Passwords do not match');
        return;
      }

      if (!_agreeToTerms) {
        _showErrorSnackbar('Please agree to the terms and conditions');
        return;
      }

      final success = await authNotifier.register(
        email: _email.text,
        username: _username.text,
        password: _password.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Register successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        widget.onLoginSuccess();
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),
              const SizedBox(height: 48),
              _TabRow(isLogin: _isLogin, onSwitch: _switchTab),
              const SizedBox(height: 36),

              // Error message display
              if (authState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            ref.read(authProvider.notifier).clearError(),
                        child: Icon(Icons.close,
                            color: Colors.red.shade600, size: 18),
                      ),
                    ],
                  ),
                ),

              FadeTransition(
                opacity: _fadeAnim,
                child: _isLogin
                    ? _LoginFields(
                        email: _username,
                        password: _password,
                        showPassword: _showPassword,
                        onTogglePassword: () =>
                            setState(() => _showPassword = !_showPassword),
                      )
                    : _RegisterFields(
                        name: _username,
                        email: _email,
                        password: _password,
                        confirmPassword: _confirmPassword,
                        showPassword: _showPassword,
                        showConfirm: _showConfirmPassword,
                        agreeToTerms: _agreeToTerms,
                        onTogglePassword: () =>
                            setState(() => _showPassword = !_showPassword),
                        onToggleConfirm: () => setState(
                            () => _showConfirmPassword = !_showConfirmPassword),
                        onToggleTerms: (v) =>
                            setState(() => _agreeToTerms = v ?? false),
                      ),
              ),
              const SizedBox(height: 36),
              _SubmitButton(
                label: _isLogin ? 'Sign in' : 'Create account',
                isLoading: authState.isLoading,
                onPressed: _submit,
              ),
              if (_isLogin) ...[
                const SizedBox(height: 32),
                _Divider(),
                const SizedBox(height: 24),
                _SocialRow(),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/meeeee.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 12),
          Text(
            'HabitFlow',
            textAlign: TextAlign.center,
            style: _t(32, FontWeight.w700, _C.ink, height: 1.1),
          ),
          const SizedBox(height: 6),
          Text(
            'Build one good day at a time.',
            textAlign: TextAlign.center,
            style: _t(
              14,
              FontWeight.w400,
              _C.inkSoft,
              height: 1.5,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab row ──────────────────────────────────────────────────────────────────
class _TabRow extends StatelessWidget {
  final bool isLogin;
  final void Function(bool) onSwitch;

  const _TabRow({required this.isLogin, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Tab(label: 'Sign in', active: isLogin, onTap: () => onSwitch(true)),
        const SizedBox(width: 28),
        _Tab(
            label: 'Create account',
            active: !isLogin,
            onTap: () => onSwitch(false)),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? _C.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: _t(
            15,
            active ? FontWeight.w600 : FontWeight.w400,
            active ? _C.ink : _C.inkSoft,
          ),
        ),
      ),
    );
  }
}

// ─── Shared field widget ───────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: _t(15, FontWeight.w400, _C.ink),
      cursorColor: _C.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: _t(15, FontWeight.w400, _C.inkSoft.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: _C.inkSoft, size: 18),
        suffixIcon: suffix,
        filled: true,
        fillColor: _C.field,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _C.accent, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Login form ───────────────────────────────────────────────────────────────
class _LoginFields extends StatelessWidget {
  final TextEditingController email, password;
  final bool showPassword;
  final VoidCallback onTogglePassword;

  const _LoginFields({
    required this.email,
    required this.password,
    required this.showPassword,
    required this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _Field(
            controller: email,
            hint: 'Username or Email',
            icon: Icons.person_outline_rounded),
        const SizedBox(height: 12),
        _Field(
          controller: password,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: !showPassword,
          suffix: _EyeButton(show: showPassword, onTap: onTogglePassword),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ForgetPasswordScreen(),
              ),
            );
          },
          style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            minimumSize: MaterialStateProperty.all(Size.zero),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,

            // normal + hover color
            foregroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.hovered)) {
                return _C.accent;
              }
              return _C.accent.withOpacity(0.7);
            }),

            // remove hover background
            overlayColor: MaterialStateProperty.all(Colors.transparent),

            textStyle: MaterialStateProperty.all(
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          child: const Text('Forgot password?'),
        )
      ],
    );
  }
}

// ─── Register form ────────────────────────────────────────────────────────────
class _RegisterFields extends StatelessWidget {
  final TextEditingController name, email, password, confirmPassword;
  final bool showPassword, showConfirm, agreeToTerms;
  final VoidCallback onTogglePassword, onToggleConfirm;
  final ValueChanged<bool?> onToggleTerms;

  const _RegisterFields({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.showPassword,
    required this.showConfirm,
    required this.agreeToTerms,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onToggleTerms,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Field(
            controller: name,
            hint: 'Username',
            icon: Icons.person_outline_rounded),
        const SizedBox(height: 12),
        _Field(
            controller: email,
            hint: 'Email address',
            icon: Icons.mail_outline_rounded),
        const SizedBox(height: 12),
        _Field(
          controller: password,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: !showPassword,
          suffix: _EyeButton(show: showPassword, onTap: onTogglePassword),
        ),
        const SizedBox(height: 12),
        _Field(
          controller: confirmPassword,
          hint: 'Confirm password',
          icon: Icons.lock_outline_rounded,
          obscure: !showConfirm,
          suffix: _EyeButton(show: showConfirm, onTap: onToggleConfirm),
        ),
        const SizedBox(height: 20),
        // Terms
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => onToggleTerms(!agreeToTerms),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: agreeToTerms ? _C.accent : _C.field,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: agreeToTerms ? _C.accent : _C.divider,
                    width: 1.5,
                  ),
                ),
                child: agreeToTerms
                    ? const Icon(Icons.check, size: 13, color: _C.white)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => onToggleTerms(!agreeToTerms),
                child: RichText(
                  text: TextSpan(
                    style: _t(13, FontWeight.w400, _C.inkSoft, height: 1.5),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                          text: 'Terms of Service',
                          style: _t(13, FontWeight.w600, _C.accent)),
                      const TextSpan(text: ' and '),
                      TextSpan(
                          text: 'Privacy Policy',
                          style: _t(13, FontWeight.w600, _C.accent)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Eye toggle ───────────────────────────────────────────────────────────────
class _EyeButton extends StatelessWidget {
  final bool show;
  final VoidCallback onTap;

  const _EyeButton({required this.show, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        show ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 18,
        color: _C.inkSoft,
      ),
      onPressed: onTap,
      splashRadius: 18,
    );
  }
}

// ─── Submit button ────────────────────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton(
      {required this.label, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _C.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.white12,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: _C.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(label,
                      style: _t(15, FontWeight.w600, _C.white,
                          letterSpacing: 0.3)),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Divider ──────────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: _C.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('or', style: _t(13, FontWeight.w400, _C.inkSoft)),
        ),
        const Expanded(child: Divider(color: _C.divider, thickness: 1)),
      ],
    );
  }
}

// ─── Social row ───────────────────────────────────────────────────────────────
class _SocialRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialBtn(
            label: 'Google',
            icon: FontAwesomeIcons.google,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialBtn(
            label: 'Facebook',
            icon: FontAwesomeIcons.facebookF,
          ),
        ),
      ],
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SocialBtn({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
