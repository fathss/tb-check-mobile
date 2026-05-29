import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/auth/auth_page.dart';
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart';
import 'widgets/landing_slide.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final AuthStorage _authStorage = AuthStorage();
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final AnimationController _splashCtrl;
  late final Animation<double> _splashOpacity;
  bool _showSlides = false;

  final slides = [
    {
      "imageUrl": "assets/images/landing_image1.png",
      "title": "Welcome to\nTBCheck👋",
    },
    {
      "imageUrl": "assets/images/landing_image2.png",
      "title": "Pantau zona sekitarmu & temukan faskes terdekat.",
    },
    {
      "imageUrl": "assets/images/landing_image3.png",
      "title": "Rutin minum obat, mari wujudkan kesembuhan.",
    },
  ];

  int currentSlideIndex = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // splash overlay anim: start after ~2s then fade out,
    _splashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _splashOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _splashCtrl, curve: Curves.easeOut));

    _initializeFlow();
  }

  Future<void> _initializeFlow() async {
    final seenLanding = await _authStorage.hasSeenLanding();

    if (!mounted) return;

    if (!seenLanding) {
      await _authStorage.markLandingSeen();
      if (!mounted) return;
      setState(() {
        _showSlides = true;
      });
    }

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    await _splashCtrl.forward();
    if (!mounted) return;

    if (_showSlides) {
      _ctrl.forward();
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _splashCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Landing content (slides, indicators, next button)
            SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _fade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Slide widget
                      SizedBox(
                        height: 360,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              if (animation.status == AnimationStatus.reverse) {
                                // Outgoing: fade out (first half)
                                final fadeOut = Tween<double>(begin: 1, end: 0)
                                    .animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: const Interval(0, 0.5),
                                      ),
                                    );
                                return FadeTransition(
                                  opacity: fadeOut,
                                  child: child,
                                );
                              } else {
                                // Incoming: fade in (second half)
                                final fadeIn = Tween<double>(begin: 0, end: 1)
                                    .animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: const Interval(0.5, 1.0),
                                      ),
                                    );
                                return FadeTransition(
                                  opacity: fadeIn,
                                  child: child,
                                );
                              }
                            },
                            child: LandingSlide(
                              key: ValueKey<int>(currentSlideIndex),
                              imageUrl: slides[currentSlideIndex]['imageUrl']!,
                              title: slides[currentSlideIndex]['title']!,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(slides.length, (i) {
                          final active = i == currentSlideIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: active ? 26 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active ? AppColors.primary : Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 26),
                      // Next button
                      FractionallySizedBox(
                        widthFactor: 0.9,
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentSlideIndex < slides.length - 1) {
                              setState(() => currentSlideIndex += 1);
                            } else {
                              // Navigate with simultaneous fade animations
                              Navigator.of(context).pushReplacement(
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const AuthPage(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            currentSlideIndex < slides.length - 1
                                ? 'Next'
                                : 'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Splash overlay that fades out after ~2s
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: FadeTransition(
                  opacity: _splashOpacity,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/heart_icon.png',
                            width: 32,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'TBCheck',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
