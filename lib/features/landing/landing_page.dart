import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'widgets/landing_slide.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final AnimationController _splashCtrl;
  late final Animation<double> _splashOpacity;

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

    // keep splash visible ~2s, then fade it out and start content animation
    Future.delayed(const Duration(milliseconds: 2000), () async {
      if (!mounted) return;
      await _splashCtrl.forward();
      if (!mounted) return;
      _ctrl.forward();
    });
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
                              // Reached last slide (index 2): navigate to Login page
                              // TODO: Navigator.of(context).pushReplacement(... to LoginPage);
                              setState(() => currentSlideIndex = 0);
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
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.favorite,
                                  size: 32,
                                  color: AppColors.primary,
                                ),
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
