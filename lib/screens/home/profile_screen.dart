import 'dart:io';
import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Loading...";
  String username = "@Loading...";
  String profileImageUrl =
      "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";
  String jurusan = "Loading...";

  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  late CalendarFormat _calendarFormat;
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _calendarFormat = CalendarFormat.month;
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  Widget buildSkeleton({required double width, required double height, BorderRadius? borderRadius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }

  Future<void> _fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usernameToFetch = prefs.getString('username');
    String? jurusanFromPrefs = prefs.getString('jurusan');

    if (usernameToFetch == null) {
      setState(() {
        name = "No user logged in";
        username = "@NotAvailable";
        jurusan = "Jurusan tidak tersedia";
      });
      return;
    }

    final url = Uri.parse('https://ilyasa.fazrilsh.com/api/siswa?username=$usernameToFetch');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          name = data['name'] ?? "Name not found";
          username = '@${data['username'] ?? "Username not found"}';
          profileImageUrl = data['foto_profil'] ?? profileImageUrl;
          jurusan = (data['jurusan'] ?? jurusanFromPrefs ?? "Jurusan tidak ditemukan").toUpperCase();
          nameController.text = name;
          usernameController.text = data['username'] ?? "";
        });
      } else {
        setState(() {
          name = "Siswa not found";
          username = "@NotAvailable";
          jurusan = "Jurusan tidak ditemukan";
        });
      }
    } catch (e) {
      setState(() {
        name = "Error fetching user";
        username = "@Error";
        jurusan = "Error fetching jurusan";
      });
    }
  }

  Future<void> _updateProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() => _imageFile = File(croppedFile.path));
      } else {
        return;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? user = prefs.getString('username');
      if (user == null) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: "Error",
          desc: "Username not found. Please login again.",
          btnOkOnPress: () {},
        ).show();
        return;
      }
      final url = Uri.parse('https://ilyasa.fazrilsh.com/api/profile/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['username'] = user
        ..files.add(await http.MultipartFile.fromPath('foto_profil', _imageFile!.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: "Success",
          desc: "Profile picture updated successfully!",
          btnOkOnPress: () {},
        ).show();
        setState(() {
          profileImageUrl = croppedFile.path;
        });
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: "Failed",
          desc: "Failed to update profile picture.",
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  Future<void> _deleteProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    if (user == null) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: "Error",
        desc: "Username not found. Please login again.",
        btnOkOnPress: () {},
      ).show();
      return;
    }
    final url = Uri.parse('https://ilyasa.fazrilsh.com/api/profile/delete');
    final response = await http.post(url, body: {'username': user});
    if (response.statusCode == 200) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: "Deleted",
        desc: "Profile deleted successfully.",
        btnOkOnPress: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        },
      ).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: "Failed",
        desc: "Failed to delete profile.",
        btnOkOnPress: () {},
      ).show();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void _showLogoutDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: "Logout",
      desc: "Are you sure you want to logout? Your data remains safe.",
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Saya"),
        backgroundColor: Colors.white10,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _updateProfilePicture,
              child: Stack(
                children: [
                  Hero(
                    tag: 'profileImage',
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile == null
                          ? NetworkImage(profileImageUrl)
                          : FileImage(_imageFile!) as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            name == "Loading..."
                ? buildSkeleton(width: 150, height: 24)
                : Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            username == "@Loading..."
                ? buildSkeleton(width: 100, height: 16)
                : Text(username, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            jurusan == "Loading..."
                ? buildSkeleton(width: 120, height: 16)
                : Text('Jurusan: $jurusan', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            Divider(),
            Align(
                alignment: Alignment.centerLeft,
                child: Text("Kalender", style: TextStyle(fontSize: 18, color: Colors.blueGrey))),
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
              ),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.redAccent),
              title: Text("Hapus Profil", style: TextStyle(color: Colors.redAccent)),
              onTap: _deleteProfile,
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.blueGrey),
              title: Text("Keluar", style: TextStyle(color: Colors.blueGrey)),
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
