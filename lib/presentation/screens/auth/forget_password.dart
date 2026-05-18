import 'package:flutter/material.dart';

// ─── Theme Colors ───────────────────────────────────────────────────────────
class _C {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1F2937);
  static const Color inkSoft = Color(0xFF6B7280);
  static const Color accent = Color(0xFF7C3AED);
  static const Color field = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
}

// ─── Text Style Helper ───────────────────────────────────────────────────────
TextStyle _t(double size, FontWeight w, Color c,
    {double? letterSpacing, double? height}) {
  return TextStyle(
    fontSize: size,
    fontWeight: w,
    color: c,
    letterSpacing: letterSpacing,
    height: height,
  );
}

// ─── Screen ─────────────────────────────────────────────────────────────────
class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  Future<void> _resetPassword() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _sent = true;
    });
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _C.ink),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ─── HEADER (same style as login) ───────────────────────────────
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/mee.png',
                    width: 160,
                    height: 160,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'HabitFlow',
                    style: _t(30, FontWeight.w700, _C.ink),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Recover your account in seconds.',
                    textAlign: TextAlign.center,
                    style: _t(
                      14,
                      FontWeight.w400,
                      _C.inkSoft,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Text(
              'Forgot Password',
              style: _t(22, FontWeight.w700, _C.ink),
            ),

            const SizedBox(height: 8),

            Text(
              'Enter your email and we will send you a reset link.',
              style: _t(14, FontWeight.w400, _C.inkSoft, height: 1.5),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              style: _t(15, FontWeight.w400, _C.ink),
              decoration: InputDecoration(
                hintText: 'Email address',
                filled: true,
                fillColor: _C.field,
                prefixIcon: const Icon(Icons.mail_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Send Reset Link',
                        style: _t(15, FontWeight.w600, _C.white),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            if (_sent)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FFF1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Reset link sent! Check your email.',
                        style: _t(14, FontWeight.w500, _C.ink),
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