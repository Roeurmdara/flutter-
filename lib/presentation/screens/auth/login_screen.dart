import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/auth_provider.dart';
import 'forget_password.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────
class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

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

    // Safety check: if already authenticated in Riverpod, trigger login success
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(authProvider).isAuthenticated) {
        widget.onLoginSuccess();
      }
    });
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

    final success = _isLogin
        ? await authNotifier.login(
            username: _username.text,
            password: _password.text,
          )
        : await authNotifier.register(
            email: _email.text,
            username: _username.text,
            password: _password.text,
            confirmPassword: _confirmPassword.text,
            agreeToTerms: _agreeToTerms,
          );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin ? 'Login successful!' : 'Register successful!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
      widget.onLoginSuccess();
    } else if (!success && mounted) {
      final error = ref.read(authProvider).error;
      if (error != null) _showErrorSnackbar(error);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      debugPrint("LoginScreen: ref.listen authProvider: previous=${previous?.isAuthenticated}, next=${next.isAuthenticated}");
      if (next.isAuthenticated && !(previous?.isAuthenticated ?? false)) {
        debugPrint("LoginScreen: Transition to authenticated! Calling widget.onLoginSuccess()");
        if (mounted) {
          widget.onLoginSuccess();
        }
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),
              const SizedBox(height: 40),
              _TabRow(isLogin: _isLogin, onSwitch: _switchTab),
              const SizedBox(height: 32),

              // Error message display
              if (authState.error != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoft,
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: GoogleFonts.inter(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            ref.read(authProvider.notifier).clearError(),
                        child: Icon(Icons.close_rounded,
                            color: AppColors.error.withValues(alpha: 0.6), size: 18),
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
              const SizedBox(height: 32),
              _SubmitButton(
                label: _isLogin ? 'Sign in' : 'Create account',
                isLoading: authState.isLoading,
                onPressed: _submit,
              ),
              if (_isLogin) ...[
                const SizedBox(height: 32),
                _Divider(),
                const SizedBox(height: 24),
                const _SocialRow(),
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/meeeee.png',
              width: 130,
              height: 130,
              cacheWidth: 260,
              cacheHeight: 260,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'HabitFlow',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.lightText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Build one good day at a time.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.lightTextSecondary,
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
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.primaryPurple : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? AppColors.lightText : AppColors.lightTextSecondary,
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
      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.lightText),
      cursorColor: AppColors.primaryPurple,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.lightTextSecondary.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(icon, color: AppColors.lightTextSecondary, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.lightInputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
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
        const SizedBox(height: 14),
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
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: AppColors.primaryPurple,
          ),
          child: Text(
            'Forgot password?',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryPurple,
            ),
          ),
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
        const SizedBox(height: 14),
        _Field(
            controller: email,
            hint: 'Email address',
            icon: Icons.mail_outline_rounded),
        const SizedBox(height: 14),
        _Field(
          controller: password,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: !showPassword,
          suffix: _EyeButton(show: showPassword, onTap: onTogglePassword),
        ),
        const SizedBox(height: 14),
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
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: agreeToTerms ? AppColors.primaryPurple : AppColors.lightInputFill,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: agreeToTerms ? AppColors.primaryPurple : AppColors.lightBorder,
                    width: 1.5,
                  ),
                ),
                child: agreeToTerms
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => onToggleTerms(!agreeToTerms),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightTextSecondary,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                          text: 'Terms of Service',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryPurple,
                          )),
                      const TextSpan(text: ' and '),
                      TextSpan(
                          text: 'Privacy Policy',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryPurple,
                          )),
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
        size: 20,
        color: AppColors.lightTextSecondary,
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
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.heroGradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white12,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(label,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      )),
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
        const Expanded(child: Divider(color: AppColors.lightBorder, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('or',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.lightTextSecondary,
              )),
        ),
        const Expanded(child: Divider(color: AppColors.lightBorder, thickness: 1)),
      ],
    );
  }
}

// ─── Social row ───────────────────────────────────────────────────────────────
class _SocialRow extends ConsumerWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SocialBtn(
                label: 'Google',
                icon: FontAwesomeIcons.google,
                brandColor: const Color(0xFFDB4437),
                onPressed: () =>
                    ref.read(authProvider.notifier).loginWithGoogle(context),
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialBtn(
                label: 'GitHub',
                icon: FontAwesomeIcons.github,
                brandColor: const Color(0xFF24292F),
                onPressed: () =>
                    ref.read(authProvider.notifier).loginWithGithub(context),
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialBtn extends ConsumerStatefulWidget {
  final String label;
  final IconData icon;
  final Color brandColor;
  final Future<void> Function() onPressed;
  final bool isLoading;

  const _SocialBtn({
    required this.label,
    required this.icon,
    required this.brandColor,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  ConsumerState<_SocialBtn> createState() => __SocialBtnState();
}

class __SocialBtnState extends ConsumerState<_SocialBtn> {
  late bool _isButtonLoading = false;

  Future<void> _handlePress() async {
    setState(() => _isButtonLoading = true);
    try {
      debugPrint("_SocialBtn: _handlePress initiated for ${widget.label}");
      await widget.onPressed();
      final authState = ref.read(authProvider);
      debugPrint("_SocialBtn: onPressed completed. authState.isAuthenticated = ${authState.isAuthenticated}");
      if (authState.isAuthenticated && mounted) {
        // Navigation will be handled by the main app logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Authenticated successfully!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.label} login failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isButtonLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: widget.brandColor.withValues(alpha: 0.06),
        border: Border.all(color: widget.brandColor.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isButtonLoading || widget.isLoading ? null : _handlePress,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isButtonLoading || widget.isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.brandColor,
                  ),
                )
              else
                FaIcon(widget.icon, size: 20, color: widget.brandColor),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.lightText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
