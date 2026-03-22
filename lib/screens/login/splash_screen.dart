import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi AnimationController untuk efek zoom
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Membuat animasi zoom dari skala 0.5 ke skala penuh
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Tambahkan listener ke AnimationController untuk berpindah ke Onboarding
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToOnboarding();
      }
    });

    // Mulai animasi
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fungsi untuk berpindah ke halaman onboarding setelah animasi selesai
  void _navigateToOnboarding() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'assets/logo.png',
            height: 100,
            width: 100,
          ),
        ),
      ),
    );
  }
}
