import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/responsive_helper.dart';
import 'number_screen.dart';

class OnboardingSlider extends StatefulWidget {
  const OnboardingSlider({super.key});

  @override
  State<OnboardingSlider> createState() => _OnboardingSliderState();
}

class _OnboardingSliderState extends State<OnboardingSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _autoSlideTimer;

  final List<Map<String, String>> _sliderContent = [
    {
      'title': 'Sign Up For A Free Account',
      'description': 'An event organizer plans, coordinates, and executes events such as corporate gatherings, weddings, or parties',
    },
    {
      'title': 'Discover Amazing Events',
      'description': 'Find and join exciting events happening around you. Connect with like-minded people and create memorable experiences',
    },
    {
      'title': 'Create Your Own Events',
      'description': 'Organize and host your own events with ease. Share your passion and bring people together for unforgettable moments',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _sliderContent.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _goToNumberScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const NumberScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getResponsivePadding(context, 24.0);
    final buttonWidth = ResponsiveHelper.isDesktop(context) ? 400.0 : double.infinity;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/SplashScreen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                const Color(0xFF140825).withOpacity(0.6),
                const Color(0xFF140825).withOpacity(0.85),
                const Color(0xFF0F051D).withOpacity(0.95),
                const Color(0xFF0A0315).withOpacity(0.98),
                const Color(0xFF050210).withOpacity(0.995),
                const Color(0xFF000000),
              ],
              stops: const [0.0, 0.25, 0.35, 0.5, 0.65, 0.75, 0.9, 1.0],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveHelper.getMaxContentWidth(context),
                ),
                child: Column(
                  children: [
                    // Top spacing to push content to bottom
                    const Spacer(),

                    // Content area with defined height
                    SizedBox(
                      height: 160.0,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        itemCount: _sliderContent.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _sliderContent[index]['title']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28.0),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 1.2,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    _sliderContent[index]['description']!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14.0),
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.8),
                                      height: 1.4,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _sliderContent.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 4.0,
                          width: _currentPage == index ? 24.0 : 4.0,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? const Color(0xFFCC3263)
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32.0),

                    // Get Started button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: SizedBox(
                        width: buttonWidth,
                        height: 56.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF4081), Color(0xFFE91E63)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28.0),
                          ),
                          child: ElevatedButton(
                            onPressed: _goToNumberScreen,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28.0),
                              ),
                            ),
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16.0),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}