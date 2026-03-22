import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../admin/dashboard_screen.dart';
import '../teacher/dashboard_guru_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'TermsPolicyScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // Cek status login saat aplikasi dibuka
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username != null) {
      // Cek data siswa
      final siswaResponse = await http.get(
        Uri.parse('https://ilyasa.fazrilsh.com/api/siswa?username=$username'),
      );

      if (siswaResponse.statusCode == 200) {
        final siswaData = json.decode(siswaResponse.body);
        // Arahkan ke HomeScreen jika data siswa ditemukan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        return; // Keluar setelah menemukan data siswa
      } else {
        print("Gagal mengambil data siswa. Status code: ${siswaResponse.statusCode}");
      }

      // Cek data guru jika tidak ditemukan data siswa
      final guruResponse = await http.get(
        Uri.parse('https://ilyasa.fazrilsh.com/api/guru?username=$username'),
      );

      if (guruResponse.statusCode == 200) {
        final guruData = json.decode(guruResponse.body);

        // Arahkan ke DashboardScreen jika guru adalah admin
        if (guruData['is_admin'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        } else if (guruData['is_teacher'] == true) {
          // Arahkan ke DashboardguruPage jika guru biasa
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardguruPage()),
          );
        } else {
          // Jika tidak ada akses yang sesuai
          _showErrorDialog("Akses Terbatas", "Akun Anda tidak memiliki akses yang sesuai.");
        }
      } else {
        print("Gagal mengambil data guru. Status code: ${guruResponse.statusCode}");
      }
    } else {
      // Jika username tidak ada di SharedPreferences
      print("Username tidak ditemukan di SharedPreferences.");
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    // Cek dulu apakah input sesuai dengan dummy credentials
    if (username == "dummy" && password == "dummy") {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('username', username);
      prefs.setString('name', "Dummy User");
      prefs.setString('jurusan', "Dummy Jurusan");
      prefs.setString('kelas', "Dummy Kelas");
      prefs.setString('foto_profil',
          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png");
      // Arahkan langsung ke HomeScreen dengan data dummy
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false,
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://ilyasa.fazrilsh.com/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Login berhasil: ${data.toString()}"); // Debug log

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);

        // Cek data siswa
        final siswaResponse = await http.get(
          Uri.parse('https://ilyasa.fazrilsh.com/api/siswa?username=$username'),
        );

        if (siswaResponse.statusCode == 200) {
          final siswaData = json.decode(siswaResponse.body);
          prefs.setString('name', siswaData['name']);
          prefs.setString('jurusan', siswaData['jurusan']);
          prefs.setString('kelas', siswaData['kelas']);
          prefs.setString('foto_profil', siswaData['foto_profil']);

          // Mengarahkan siswa ke HomeScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false,
          );
          return; // Berhenti setelah siswa ditemukan
        }

        // Cek data guru
        final guruResponse = await http.get(
          Uri.parse('https://ilyasa.fazrilsh.com/api/guru?username=$username'),
        );

        if (guruResponse.statusCode == 200) {
          final guruData = json.decode(guruResponse.body);
          prefs.setString('name', guruData['name']);
          prefs.setString('wali_kelas', guruData['wali_kelas']);
          prefs.setString('foto_profil', guruData['foto_profil']);
          prefs.setString('jenis_kelamin', guruData['jenis_kelamin']);
          prefs.setString('role', 'guru');
          prefs.setBool('is_teacher', guruData['is_teacher'] ?? false);
          prefs.setBool('is_admin', guruData['is_admin'] ?? false);

          if (guruData['is_admin'] == true) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
              (Route<dynamic> route) => false,
            );
          } else if (guruData['is_teacher'] == true) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardguruPage()),
              (Route<dynamic> route) => false,
            );
          } else {
            _showErrorDialog("Data Tidak Ditemukan", "Akun tidak terdaftar sebagai siswa atau guru.");
          }
          return; // Berhenti setelah guru ditemukan
        }

        _showErrorDialog("Login Gagal", "Akun tidak ditemukan.");
      } else {
        print("Login gagal, status code: ${response.statusCode}");
        _showErrorDialog("Login Gagal", "Username atau password salah.");
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog("Terjadi Kesalahan", "Terjadi kesalahan saat login, coba lagi.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Mencegah menutup dialog dengan klik di luar
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Sudut melengkung
        ),
        backgroundColor: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ukuran sesuai isi
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Divider(
                color: Colors.white24,
                thickness: 1,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Batal",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Coba Lagi",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/logo.png'),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(height: 30),
                        Text(
                          "Selamat Datang di Aplikasi Sekolah",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Silakan masuk untuk melanjutkan",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        _buildTextField(
                            _usernameController, "Username", Icons.person),
                        SizedBox(height: 20),
                        _buildPasswordTextField(),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            elevation: 5,
                            shadowColor: Colors.black45,
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 15),
                            Text(
                              "© 2025 SMKN 1 KOTA TANGERANG",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TermsPolicyScreen()),
                                );
                              },
                              child: Text("Terms of Policy"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLoadingAnimation(),
                      SizedBox(height: 20),
                      Text(
                        "Sedang memuat... Mohon tunggu",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                        ),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.greenAccent),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        labelText: "Password",
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.lock, color: Colors.greenAccent),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.greenAccent,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = Tween<double>(begin: 1.0, end: 1.5).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0 + index * 0.2, 0.6 + index * 0.2,
                    curve: Curves.easeInOut),
              ),
            );
            return Transform.scale(
              scale: scale.value,
              child: Container(
                width: 20,
                height: 20,
                margin: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
