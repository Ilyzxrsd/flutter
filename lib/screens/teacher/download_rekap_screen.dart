import 'package:flutter/material.dart';
import '../../constants/constant.dart';

class DownloadRekapScreen extends StatefulWidget {
  @override
  _DownloadRekapScreenState createState() => _DownloadRekapScreenState();
}

class _DownloadRekapScreenState extends State<DownloadRekapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Rekap Absensi'),
        backgroundColor: primaryAccentColor,
      ),
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock,
                size: 100,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Fitur ini akan tersedia di akhir semester',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
