import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/auth_provider.dart';

// ─── Theme Colors ─────────────────────────────────────────────
class _C {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1F2937);
  static const Color inkSoft = Color(0xFF6B7280);
  static const Color accent = Color(0xFF7C3AED);
  static const Color field = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
}

// ─── Text Style Helper ────────────────────────────────────────
TextStyle _t(
  double size,
  FontWeight w,
  Color c, {
  double? letterSpacing,
  double? height,
}) {
  return TextStyle(
    fontSize: size,
    fontWeight: w,
    color: c,
    letterSpacing: letterSpacing,
    height: height,
  );
}

// ─── Screen ───────────────────────────────────────────────────
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
          backgroundColor: Colors.green,
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
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: _C.ink),
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
              child: Image.asset(
                'assets/images/mee.png',
                width: 160,
                height: 160,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Center(
              child: Text(
                'HabitFlow',
                style: _t(
                  30,
                  FontWeight.w700,
                  _C.ink,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Center(
              child: Text(
                'Recover your account in seconds.',
                textAlign: TextAlign.center,
                style: _t(
                  14,
                  FontWeight.w400,
                  _C.inkSoft,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding:
                    const EdgeInsets.all(12),
                margin:
                    const EdgeInsets.only(
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(
                    color: Colors.red.shade300,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color:
                              Colors.red.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Email Field
            TextField(
              controller: _email,
              keyboardType:
                  TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email address',
                filled: true,
                fillColor: _C.field,
                prefixIcon:
                    const Icon(Icons.mail_outline),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    authState.isLoading
                        ? null
                        : _resetPassword,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      _C.accent,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Send Reset Link',
                        style: _t(
                          15,
                          FontWeight.w600,
                          _C.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Success Box
            if (_sent)
              Container(
                padding:
                    const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE8FFF1),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color:
                          Color(0xFF10B981),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Reset link sent! Check your email.',
                        style: _t(
                          14,
                          FontWeight.w500,
                          _C.ink,
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