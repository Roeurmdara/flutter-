import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

// ─── Data model ───────────────────────────────────────────────────────────────
class _PageData {
  final String imagePath;   // full-bleed image path
  final String tag;        // small eyebrow label
  final String title;
  final String description;

  const _PageData({
    required this.imagePath,
    required this.tag,
    required this.title,
    required this.description,
  });
}


const _pages = [
  _PageData(
    imagePath: 'assets/images/onboard1.jpg',
    tag: '01 — Focus',
    title: 'Build Better\nHabits',
    description:
        'Create and track daily habits to improve your life one step at a time.',
  ),
  _PageData(
    imagePath: 'assets/images/onboard2.jpg',
    tag: '02 — Momentum',
    title: 'Maintain Your\nStreaks',
    description:
        'Stay motivated by tracking your daily streaks and celebrating progress.',
  ),
  _PageData(
    imagePath: 'assets/images/onboard3.jpg',
    tag: '03 — Insight',
    title: 'Track Your\nProgress',
    description:
        'Visualize your improvement with detailed analytics and insights.',
  ),
  _PageData(
    imagePath: 'assets/images/onboard5.jpg',
    tag: '04 — Together',
    title: 'Join the\nCommunity',
    description:
        'Connect with others on the same journey and stay motivated together.',
  ),
];
// ─── Screen ───────────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  final Future<void> Function() onCompleted;

  const OnboardingScreen({super.key, required this.onCompleted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  int _current = 0;

  late final AnimationController _textAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _textAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _fadeAnim =
        CurvedAnimation(parent: _textAnim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textAnim, curve: Curves.easeOut));

    _textAnim.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textAnim.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    _textAnim.reset();
    setState(() => _current = i);
    _textAnim.forward();
  }

  Future<void> _next() async {
    if (_current == _pages.length - 1) {
      await widget.onCompleted();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _skip() async => widget.onCompleted();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0B1A),
      body: Stack(
        children: [
          // ── Full-bleed paged background images ──
          PageView.builder(
            controller: _controller,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (_, i) => _BgImage(path: _pages[i].imagePath),
          ),

          // ── Dark gradient scrim (bottom half) ──
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.25, 0.55, 0.85],
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0E0B1A).withOpacity(0.5),
                    const Color(0xFF0E0B1A).withOpacity(0.92),
                  ],
                ),
              ),
            ),
          ),

          // ── Top bar: logo + skip ──
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo mark
                  SizedBox(
                    width: 36,
                    height: 36,
                  ),
                  // Skip
                  if (_current < _pages.length - 1)
                    GestureDetector(
                      onTap: _skip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15), width: 1),
                        ),
                        child: Text('Skip',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                            )),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Bottom content ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Eyebrow tag
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.heroGradient,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _pages[_current].tag,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Text(
                          _pages[_current].title,
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.12,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Description
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Text(
                        _pages[_current].description,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.7),
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Dots + button row
                    Row(
                      children: [
                        // Dot indicators
                        _Dots(count: _pages.length, current: _current),
                        const Spacer(),
                        // Next / Get Started button
                        _NextButton(
                          isLast: _current == _pages.length - 1,
                          onTap: _next,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Background image ─────────────────────────────────────────────────────────
class _BgImage extends StatelessWidget {
  final String path;

  const _BgImage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) =>
          Container(color: const Color(0xFF1A1628)),
    );
  }
}

// ─── Dot indicators ───────────────────────────────────────────────────────────
class _Dots extends StatelessWidget {
  final int count;
  final int current;

  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 6),
          width: active ? 28 : 7,
          height: 7,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(colors: AppColors.heroGradient)
                : null,
            color: active ? null : Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Next / Get Started button ────────────────────────────────────────────────
class _NextButton extends StatelessWidget {
  final bool isLast;
  final VoidCallback onTap;

  const _NextButton({required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isLast ? 28 : 0,
          vertical: isLast ? 16 : 0,
        ),
        width: isLast ? null : 56,
        height: isLast ? null : 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.heroGradient,
          ),
          borderRadius: BorderRadius.circular(isLast ? 16 : 28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isLast
            ? Text('Get Started',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ))
            : const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 22),
      ),
    );
  }
}

// ─── Data model (keep outside widget tree) ───────────────────────────────────
class OnboardingPage {
  final String imageUrl;
  final String tag;
  final String title;
  final String description;

  const OnboardingPage({
    required this.imageUrl,
    required this.tag,
    required this.title,
    required this.description,
  });
}