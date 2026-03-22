import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  final List<Map<String, String>> onboardingPages = [
    {
      "animation": "assets/lottie/robot.json",
      "title": "Selamat Datang!",
      "description": "Aplikasi sekolah modern untuk mendukung kegiatan belajarmu setiap hari.",
    },
    {
      "animation": "assets/lottie/education2.json",
      "title": "Fitur Interaktif",
      "description": "Dari presensi, event, hingga leaderboard, semua ada di genggaman tanganmu.",
    },
    {
      "animation": "assets/lottie/education3.json",
      "title": "Ayo Mulai!",
      "description": "Buka peluang baru dan maksimalkan pengalaman belajarmu bersama kami.",
    },
  ];

  void _onNextPressed() {
    if (_currentPageIndex == onboardingPages.length - 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSkipPressed() {
    _pageController.jumpToPage(onboardingPages.length - 1);
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingPages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 10,
          width: _currentPageIndex == index ? 24 : 10,
          decoration: BoxDecoration(
            color: _currentPageIndex == index ? Colors.black : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(Map<String, String> page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 300,
            child: Lottie.asset(page['animation']!, fit: BoxFit.contain),
          ),
          const SizedBox(height: 40),
          Text(
            page['title']!,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page['description']!,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // background tetap konsisten
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingPages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = onboardingPages[index];
                  return _buildOnboardingPage(page);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _onSkipPressed,
                    child: Text(
                      "Skip",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                  _buildPageIndicator(),
                  _currentPageIndex == onboardingPages.length - 1
                      ? ElevatedButton(
                          onPressed: _onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Get Started",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        )
                      : TextButton(
                          onPressed: _onNextPressed,
                          child: Text(
                            "Next",
                            style: TextStyle(fontSize: 16, color: Colors.black),
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
