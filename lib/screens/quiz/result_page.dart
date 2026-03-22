import 'dart:async'; // Tambahkan import ini untuk Timer
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Untuk screenshot
import 'package:share_plus/share_plus.dart'; // Package share_plus untuk berbagi
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart'; // Import just_audio

import '../home/home_screen.dart';

class ResultPage extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int points;

  const ResultPage({
    Key? key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.points,
  }) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final GlobalKey _globalKey = GlobalKey(); // Key untuk screenshot
  late final AudioPlayer _audioPlayer;

  // Variabel untuk countdown tombol "Back to Home"
  int _backButtonCountdown = 10;
  bool _isBackButtonEnabled = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initAudio();
    _startBackButtonCountdown();
  }

  // Inisialisasi dan mulai putar audio menggunakan just_audio
  Future<void> _initAudio() async {
    _audioPlayer = AudioPlayer();
    try {
      // Set asset audio dan mulai putar
      await _audioPlayer.setAsset('assets/result.mp3');
      _audioPlayer.play();
    } catch (e) {
      print("Gagal memuat audio: $e");
    }
  }

  // Mulai timer untuk countdown tombol "Back to Home"
  void _startBackButtonCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_backButtonCountdown > 0) {
          _backButtonCountdown--;
        }
        if (_backButtonCountdown == 0) {
          _isBackButtonEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // Fungsi untuk menyimpan gambar ke file sementara
  Future<String> _saveToFile(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/result.png';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  // Fungsi untuk berbagi hasil dengan screenshot dan teks
  Future<void> _shareResult(BuildContext context) async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      // Gunakan pixelRatio yang lebih tinggi untuk resolusi gambar yang lebih baik
      var image = await boundary.toImage(pixelRatio: 3.0);
      var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();

      // Menyimpan gambar ke file sementara
      final filePath = await _saveToFile(pngBytes);

      // Teks yang ingin dibagikan
      final String shareText =
          "Aku berhasil mendapatkan skor ${widget.correctAnswers}/${widget.totalQuestions} di aplikasi sekolah SMK Negeri 1 Tangerang. Ayo ikut main bersamaku di sini: https://drive.google.com/file/d/1IrhTJjawquYaknZw-RXofVtOzmPQffOW/view?usp=drive_link";

      // Berbagi gambar dan teks menggunakan share_plus
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        text: shareText,
        subject: "Quiz Result",
      );

      if (result.status == ShareResultStatus.success) {
        print('Terima kasih sudah membagikan hasilnya!');
      } else {
        print('Gagal membagikan hasil');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membagikan hasil: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int incorrectAnswers = widget.totalQuestions - widget.correctAnswers;
    double percentage = (widget.correctAnswers / widget.totalQuestions) * 100;

    return Scaffold(
      // Gunakan background container untuk menampilkan gambar
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image dari assets
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/bg.jpg"),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            // Overlay semi-transparan agar konten mudah dibaca
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            // Konten halaman yang dibungkus dalam RepaintBoundary untuk screenshot
            RepaintBoundary(
              key: _globalKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Quiz Result",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 30),
                      // Lingkaran skor dengan gradient dan shadow
                      Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.redAccent.shade100,
                              Colors.redAccent
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${percentage.toStringAsFixed(0)}%",
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Score: ${widget.correctAnswers}/${widget.totalQuestions}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        percentage >= 50 ? "Great Job!" : "Keep Practicing!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 30),
                      // Kartu informasi dengan background semi-transparan
                      Card(
                        color: Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildInfoRow("Category", "History"),
                              Divider(),
                              _buildInfoRow(
                                  "Questions", "${widget.totalQuestions}"),
                              Divider(),
                              _buildInfoRow(
                                  "Correct Answers", "${widget.correctAnswers}"),
                              Divider(),
                              _buildInfoRow(
                                  "Incorrect Answers", "$incorrectAnswers"),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      // Tombol Navigasi dan Share
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isBackButtonEnabled
                                ? () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()),
                                    );
                                  }
                                : null, // Jika belum selesai countdown, tombol nonaktif
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isBackButtonEnabled
                                  ? Colors.blue
                                  : Colors.blue.shade200,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(Icons.home, size: 20),
                            label: Text(
                              _isBackButtonEnabled
                                  ? "Back to Home"
                                  : "Back to Home (${_backButtonCountdown}s)",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _shareResult(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(Icons.share, size: 20),
                            label: Text("Share", style: TextStyle(fontSize: 16)),
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
      ),
    );
  }

  // Widget pembantu untuk membangun baris informasi pada kartu
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, color: Colors.black87)),
        Text(value,
            style: TextStyle(fontSize: 16, color: Colors.black87)),
      ],
    );
  }
}
