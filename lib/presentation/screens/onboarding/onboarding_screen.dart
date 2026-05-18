import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Palette (matches login screen) ───────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF7F5F0);
  static const ink = Color(0xFF1A1A18);
  static const inkSoft = Color(0xFF6B6860);
  static const accent =  Color(0xFF7C3AED);    // forest green
  static const white = Color(0xFFFFFFFF);
  static const divider = Color(0xFFDDD9D0);
}

TextStyle _t(double size, FontWeight w, Color c,
    {double? letterSpacing, double? height}) =>
    TextStyle(
      fontSize: size,
      fontWeight: w,
      color: c,
      letterSpacing: letterSpacing,
      height: height,
      fontFamily: 'Georgia',
    );

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

  const OnboardingScreen({Key? key, required this.onCompleted})
      : super(key: key);

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
      backgroundColor: _C.ink,
      body: Stack(
        children: [
          // ── Full-bleed paged background images ──
          PageView.builder(
            controller: _controller,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (_, i) => _BgImage(url: _pages[i].imagePath),
          ),

          // ── Dark gradient scrim (bottom half) ──
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 0.95, 2.0],
                  colors: [
                    Colors.transparent,
                    _C.ink.withOpacity(0.15),
                    _C.ink.withOpacity(0.15),
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
                  Container(
                    width: 36,
                    height: 36,
              
                  ),
                  // Skip
                  if (_current < _pages.length - 1)
                    GestureDetector(
                      onTap: _skip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _C.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _C.accent.withOpacity(0.2), width: 1),
                        ),
                        child: Text('Skip',
                            style: _t(13, FontWeight.w500,
                                _C.accent.withOpacity(0.85))),
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
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _C.accent.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _pages[_current].tag,
                            style: _t(11, FontWeight.w600, _C.white,
                                letterSpacing: 1.2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Title
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Text(
                          _pages[_current].title,
                          style: _t(38, FontWeight.w700, _C.white,
                              height: 1.12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Text(
                        _pages[_current].description,
                        style: _t(15, FontWeight.w400,
                            _C.white.withOpacity(0.72),
                            height: 1.55),
                      ),
                    ),
                    const SizedBox(height: 36),

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

// ─── Background image with fade between pages ─────────────────────────────────
class _BgImage extends StatelessWidget {
  final String url;

  const _BgImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(color: const Color(0xFF1A1A18));
      },
      errorBuilder: (_, __, ___) =>
          Container(color: const Color(0xFF2A2A28)),
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
            color: active ? _C.accent : _C.white.withOpacity(0.35),
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
          horizontal: isLast ? 24 : 0,
          vertical: isLast ? 14 : 0,
        ),
        width: isLast ? null : 52,
        height: isLast ? null : 52,
        decoration: BoxDecoration(
          color: _C.accent,
          borderRadius: BorderRadius.circular(isLast ? 12 : 26),
        ),
        child: isLast
            ? Text('Get Started',
                style: _t(15, FontWeight.w600, _C.white, letterSpacing: 0.2))
            : const Icon(Icons.arrow_forward_rounded,
                color: _C.white, size: 22),
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