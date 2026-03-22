import 'package:flutter/material.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/event/event_list_screen.dart';
import 'screens/home/leaderboard_screen.dart';
import 'screens/home/profile_screen.dart';
import 'screens/login/splash_screen.dart';
import 'screens/admin/attendance_screen.dart';
import 'screens/admin/news_event_screen.dart';
import 'screens/home/qr_scanner_screen.dart';
import 'screens/quiz/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Aplikasi Sekolah',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/splash',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/events': (context) => EventListScreen(),
        '/leaderboard': (context) => LeaderboardScreen(),
        '/scan': (context) => QRScannerScreen(),
        '/splash': (context) => SplashScreen(),
        '/profile': (context) => ProfileScreen(),
        '/admin/attendance': (context) => AttendanceScreen(),
        '/admin/news-event': (context) => NewsEventScreen(),
        '/detective-game': (context) =>  Home(),
      },
    );
  }
}
