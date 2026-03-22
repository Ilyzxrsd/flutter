import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../home/profile_screen.dart'; // Tambahkan ini
import '../home/home_screen.dart'; // Tambahkan ini
import 'category_model.dart';
import 'category_widget.dart';
import 'quiz_page.dart'; // Halaman berbeda untuk kategori
import 'package:awesome_dialog/awesome_dialog.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String username = "siswa"; 
  String name = "Siswa"; 
  String fotoProfil = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"; // Default path jika data tidak ditemukan

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? "user"; // Ambil 'username' dari SharedPreferences

    // Ambil nama dan foto profil berdasarkan username dari API
    final url = Uri.parse('https://ilyasa.fazrilsh.com/api/siswa?username=$username');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          name = data['name'] ?? "Name not found";
          fotoProfil = data['foto_profil'] ?? fotoProfil; // Ambil foto_profil dari API
        });
      } else {
        setState(() {
          name = "Siswa not found";
          fotoProfil = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"; // Gambar default jika gagal
        });
      }
    } catch (e) {
      setState(() {
        name = "Error fetching user";
        fotoProfil = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"; // Gambar default jika error
      });
    }
  }

 @override
  Widget build(BuildContext context) {
    final List<Category> categories = [
      Category(title: "Quiz Jurusan", imagePath: "images/pngtree-smk-logo-can-be-full-color-png-image_9041275.png"),
      Category(title: "?????", imagePath: "images/STK-20250124-WA0028.png"),
    ];

    return Scaffold(
      backgroundColor: const Color(0xffedf3f6),
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: const Color(0xFFFFFFFF),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Stack(
              children: [
                // Background Header
                Container(
                  height: 230,
                  padding: const EdgeInsets.only(left: 20.0, top: 50.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2a2b31),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Arahkan ke profile_screen.dart
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfileScreen()),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            fotoProfil,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "images/boy.png", // Gambar default jika error
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          name, // Nama dinamis
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Quiz Banner
                Container(
                  margin: const EdgeInsets.only(top: 140.0, left: 20.0, right: 20.0),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          "images/quiz.PNG",
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Play & Win",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              "Play Quiz and earn points",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                "Top Quiz Categories",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 23.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                  childAspectRatio: 0.9,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryWidget(
                    category: categories[index],
                    onTap: () {
                      // Menentukan rute berdasarkan kategori yang dipilih
                      switch (categories[index].title) {
                        case "Quiz Jurusan":
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Question()),
                          );
                          break;
                        case "?????":
                          // Menampilkan dialog peringatan
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.info,
                            title: 'Informasi',
                            desc: 'Mohon maaf, tapi admin sedang bingung mau kategori soal apa🙏🙏🙏🙏',
                            btnOkOnPress: () {
                              // Tombol OK hanya menutup dialog
                            },
                          ).show();
                          break;
                        default:
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.error,
                            title: 'Terjadi Kesalahan',
                            desc: 'Ada masalah saat memuat halaman Quiz. Kembali ke Home Screen.',
                            btnOkOnPress: () {
                              // Kembali ke halaman utama (HomeScreen)
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => HomeScreen()), // Ganti HomeScreen() sesuai dengan nama widget halaman utama
                              );
                            },
                          ).show();
                          break;
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}