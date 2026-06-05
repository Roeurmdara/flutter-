import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/auth_provider.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────
class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState
    extends ConsumerState<ForgetPasswordScreen> {
  final TextEditingController _email = TextEditingController();

  bool _sent = false;
  String? _errorMessage;

  Future<void> _resetPassword() async {
    final email = _email.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return;
    }

    final emailRegex =
        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Invalid email format';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    final authNotifier =
        ref.read(authProvider.notifier);

    // IMPORTANT:
    // Replace with backend allowed redirect URI
    const redirectUri =
        'http://localhost:8080';

    final success =
        await authNotifier.requestPasswordReset(
      email: email,
      redirectUri: redirectUri,
    );

    if (success && mounted) {
      setState(() {
        _sent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reset link sent successfully!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final authState = ref.read(authProvider);

      setState(() {
        _errorMessage =
            authState.error ??
                'Failed to send reset link';
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: AppColors.lightText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Logo
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.12),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/mee.png',
                  width: 140,
                  height: 140,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Center(
              child: Text(
                'HabitFlow',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightText,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Center(
              child: Text(
                'Recover your account in seconds.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightTextSecondary,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.errorSoft,
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Email Field
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.lightText,
              ),
              cursorColor: AppColors.primaryPurple,
              decoration: InputDecoration(
                hintText: 'Email address',
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.lightTextSecondary.withOpacity(0.6),
                ),
                filled: true,
                fillColor: AppColors.lightInputFill,
                prefixIcon: const Icon(
                  Icons.mail_outline_rounded,
                  color: AppColors.lightTextSecondary,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primaryPurple,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Button
            SizedBox(
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
                      color: AppColors.primaryPurple.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: authState.isLoading ? null : _resetPassword,
                    borderRadius: BorderRadius.circular(16),
                    splashColor: Colors.white12,
                    child: Center(
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Send Reset Link',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Success Box
            if (_sent)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Reset link sent! Check your email.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.lightText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}