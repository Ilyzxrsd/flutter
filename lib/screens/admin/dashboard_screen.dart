import 'package:flutter/material.dart';
import 'attendance_screen.dart';
import 'news_event_screen.dart';
import '../login/login_screen.dart'; // Tambahkan import untuk LoginScreen
import 'package:shared_preferences/shared_preferences.dart';


class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text("Admin Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder(
          future: _checkLoginStatus(),
          builder: (context, snapshot) {
            // Menunggu pengecekan status login
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // Jika status login belum ada, arahkan ke LoginScreen
            if (snapshot.hasError || !snapshot.hasData) {
              return _redirectToLogin(context);
            }

            // Jika sudah login, tampilkan Dashboard
            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: <Widget>[
                _buildDashboardCard("Absensi Siswa", Icons.check, context, AttendanceScreen()),
                _buildDashboardCard("Berita & Event", Icons.event, context, NewsEventScreen()),
              ],
            );
          },
        ),
      ),
    );
  }

  // Memeriksa status login di SharedPreferences
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    return username != null && username.isNotEmpty;
  }

  // Redirect ke halaman login jika tidak login
  Widget _redirectToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: FutureBuilder(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text("Gagal memuat data"));
          }

          final userData = snapshot.data as Map<String, String>;

          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(userData['name'] ?? "Admin"),
                accountEmail: Text("@${userData['username']}"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
              ),
              ListTile(
                title: Text("Dashboard"),
                leading: Icon(Icons.dashboard),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Absensi Siswa"),
                leading: Icon(Icons.check),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AttendanceScreen()),
                  );
                },
              ),
              ListTile(
                title: Text("Berita & Event"),
                leading: Icon(Icons.event),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewsEventScreen()),
                  );
                },
              ),
              ListTile(
                title: Text("Keluar"),
                leading: Icon(Icons.logout),
                onTap: () async {
                  // Hapus data di SharedPreferences
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // Hapus semua data yang tersimpan

                  // Arahkan ke LoginScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false, // Hapus semua route sebelumnya
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, String>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? "Admin";
    final username = prefs.getString('username') ?? "admin";
    return {'name': name, 'username': username};
  }

  Widget _buildDashboardCard(String title, IconData icon, BuildContext context, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Card(
        elevation: 6,
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.blue[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
