import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart'; 
import 'profile_screen.dart';
import 'qr_scanner_screen.dart';
import 'leaderboard_screen.dart';
import '../event/event_list_screen.dart';
import '../event/event_detail_screen.dart';
import '../admin/attendance_screen.dart';
import '../login/login_screen.dart';
import '../../models/event.dart';
import 'feedback.dart';
import '../quiz/home.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // GlobalKey untuk menandai widget yang akan di-highlight oleh tutorial
  GlobalKey _headerKey = GlobalKey();
  GlobalKey _sliderKey = GlobalKey();
  GlobalKey _menuKey = GlobalKey();
  GlobalKey _helpKey = GlobalKey();

  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _sliderTimer;
  String username = "Loading...";
  String profileImageUrl =
      "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";
  bool isSecretary = false;
  DateTime? _lastPressedTime;
  List<Event> events = [];
  String role = "siswa";

  TutorialCoachMark? tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchUsername();
    _fetchEvents();
    _fetchNews();
    _checkAndShowTutorial();
  }

  /// Cek apakah tutorial sudah pernah ditampilkan; jika belum, tampilkan tutorial interaktif
  Future<void> _checkAndShowTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? tutorialShown = prefs.getBool('tutorialShown');
    if (tutorialShown == null || !tutorialShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorialCoachMark();
      });
      await prefs.setBool('tutorialShown', true);
    }
  }

  /// Menampilkan tutorial interaktif dengan tutorial_coach_mark
  void _showTutorialCoachMark() {
  List<TargetFocus> targets = [
    TargetFocus(
      identify: "Header",
      keyTarget: _headerKey,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Text(
            "Ini adalah header. Di sini kamu bisa melihat nama dan foto profilmu. Tap foto untuk melihat detail akun.",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    ),
    TargetFocus(
      identify: "Slider",
      keyTarget: _sliderKey,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Text(
            "Swipe slider ini untuk melihat event dan berita terbaru yang tersedia.",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    ),
    TargetFocus(
      identify: "Menu",
      keyTarget: _menuKey,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Text(
            "Ini adalah menu utama. Di sini kamu bisa mengakses QR Absence, School Events, Leaderboard, Mini Game, dan Feedback.",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    ),
    TargetFocus(
      identify: "Bantuan",
      keyTarget: _helpKey,
      shape: ShapeLightFocus.Circle,
      contents: [
        TargetContent(
          align: ContentAlign.left,
          child: Text(
            "Gunakan tombol bantuan ini kapan saja jika butuh panduan lebih lanjut.",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    ),
  ];

  TutorialCoachMark tc = TutorialCoachMark(
    targets: targets,
    colorShadow: Colors.black,
    textSkip: "LEWATI",
    paddingFocus: 10,
    onFinish: () {
      print("Tutorial selesai");
    },
    onClickTarget: (TargetFocus target) {
      print("Target clicked: ${target.identify}");
    },
  );

  tc.show(context: context);
}


  Future<void> _fetchUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usernameToFetch = prefs.getString('username');

    if (usernameToFetch == null) {
      setState(() {
        username = "No user logged in";
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }

    final url =
        Uri.parse('https://ilyasa.fazrilsh.com/api/siswa?username=$usernameToFetch');
    try {
      final response = await http.get(url);
      if (response.body.contains("<html>")) {
        setState(() {
          username = "Received HTML instead of JSON. Likely an error page.";
        });
      } else if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          username = data['name'] ?? data['username'] ?? "Unknown User";
          profileImageUrl = data['foto_profil'] ??
              "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";
          role = data['role'] ?? 'siswa';
          isSecretary = (data['is_secretary'] ?? false) is bool
              ? data['is_secretary']
              : (data['is_secretary'] == 1);
        });
      } else {
        setState(() {
          username = "Failed to fetch user. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        username = "Error fetching user: $e";
      });
    }
  }

  Future<void> _fetchEvents() async {
    final url = Uri.parse('https://ilyasa.fazrilsh.com/api/events');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          events = data.map<Event>((event) => Event.fromJson(event)).toList();
          events.sort((a, b) => b.tanggal.compareTo(a.tanggal));
          events = events.take(3).toList();
        });
        _startSlider();
      }
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  Future<void> _fetchNews() async {
    final url = Uri.parse('https://ilyasa.fazrilsh.com/api/news');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Untuk contoh, news menggunakan struktur event yang sama
          events = data.map<Event>((event) => Event.fromJson(event)).toList();
          events.sort((a, b) => b.tanggal.compareTo(a.tanggal));
          events = events.take(3).toList();
        });
      }
    } catch (e) {
      print("Error fetching news: $e");
    }
  }

  void _startSlider() {
    _sliderTimer = Timer.periodic(Duration(seconds: 6), (Timer timer) {
      if (events.isNotEmpty) {
        setState(() {
          _currentPage = (_currentPage + 1) % events.length;
        });
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget buildSkeleton({
    double width = double.infinity,
    double height = 16.0,
    BorderRadius? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(4.0),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (_lastPressedTime == null ||
        now.difference(_lastPressedTime!) > Duration(seconds: 2)) {
      _lastPressedTime = now;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.scale,
        title: "Konfirmasi Keluar",
        desc: "Tekan tombol kembali sekali lagi untuk keluar dari aplikasi.",
        btnOkText: "OK",
        btnOkColor: Colors.blue,
        btnOkOnPress: () {},
      ).show();
      return false;
    }
    return true;
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Panduan Aplikasi"),
        content: Text(
          "• Swipe ke kiri/kanan pada slider untuk melihat event terbaru.\n"
          "• Tap menu untuk mengakses fitur seperti QR Absence, Events, Leaderboard, dan lainnya.\n"
          "• Gunakan tombol profil di pojok untuk melihat detail akun kamu.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Mengerti", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan widget utama yang akan di-highlight memiliki key yang telah didefinisikan
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Home", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 4,
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          key: _helpKey,
          onPressed: _showHelpDialog,
          backgroundColor: Colors.blue,
          child: Icon(Icons.help_outline, color: Colors.white),
          tooltip: "Panduan Aplikasi",
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[100]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(key: _headerKey, child: _buildHeaderCard()),
                  SizedBox(height: 20),
                  Container(key: _sliderKey, child: _buildEventSlider()),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Swipe untuk melihat event",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(key: _menuKey, child: _buildMenuBar()),
                  SizedBox(height: 20),
                  _buildSection("News", "See More", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EventListScreen()),
                    );
                  }),
                  SizedBox(height: 20),
                  _buildSection("Upcoming Events", "See More", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EventListScreen()),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: username == "Loading..."
                  ? buildSkeleton(width: 150, height: 24, borderRadius: BorderRadius.circular(4))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome back,", style: TextStyle(fontSize: 16, color: Colors.black54)),
                        SizedBox(height: 4),
                        Text(username,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                      ],
                    ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
              },
              child: Hero(
                tag: 'profileImage',
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: profileImageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          buildSkeleton(width: 56, height: 56, borderRadius: BorderRadius.circular(28)),
                      errorWidget: (context, url, error) => Icon(Icons.person, color: Colors.black),
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

  Widget _buildEventSlider() {
    return Column(
      children: [
        Container(
          height: 220,
          child: events.isEmpty
              ? PageView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: buildSkeleton(
                        width: double.infinity,
                        height: 220,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  },
                )
              : PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.35),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: event.gambar,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => buildSkeleton(
                                  width: double.infinity,
                                  height: 220,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.transparent, Colors.black45],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Text(
                                    event.judul,
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        SizedBox(height: 10),
        events.isNotEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  events.length,
                  (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 12 : 8,
                    height: _currentPage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index ? Colors.blue : Colors.grey[400],
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget _buildMenuBar() {
    List<Widget> menuItems = [
      _buildMenuItem("QR Absence", Icons.qr_code_scanner, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => QRScannerScreen()));
      }),
      if (isSecretary)
        _buildMenuItem("Absence List", Icons.list, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceScreen()));
        }),
      _buildMenuItem("School Events", Icons.event, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => EventListScreen()));
      }),
      _buildMenuItem("Leaderboard", Icons.leaderboard, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LeaderboardScreen()));
      }),
      _buildMenuItem("Mini Game", Icons.videogame_asset, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
      }),
      _buildMenuItem("Feedback", Icons.feedback, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DeveloperFeedbackForm()));
      }),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 0.9,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: menuItems,
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Tooltip(
      message: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Icon(icon, color: Colors.blue, size: 30),
                ),
              ),
              SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String buttonText, VoidCallback onButtonTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section dengan divider agar tampilan lebih clean
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            TextButton(
              onPressed: onButtonTap,
              child: Text(buttonText, style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        Divider(color: Colors.grey[300], thickness: 1),
        Container(
          height: 150,
          child: events.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)));
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: event.gambar,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => buildSkeleton(
                                  width: double.infinity,
                                  height: 100,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                event.judul,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: buildSkeleton(
                        width: 250,
                        height: 150,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}