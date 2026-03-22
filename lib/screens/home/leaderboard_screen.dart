import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<dynamic>> leaderboardDataKelas;
  late Future<List<dynamic>> leaderboardDataGlobal;
  String? kelas;
  String? currentUserName;
  final String defaultProfileUrl =
      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      kelas = prefs.getString('kelas') ?? '.';
      currentUserName = prefs.getString('name');
    });
    if (kelas != null) {
      leaderboardDataKelas = fetchLeaderboardDataKelas(kelas!);
    }
    leaderboardDataGlobal = fetchLeaderboardDataGlobal();
  }

  Future<List<dynamic>> fetchLeaderboardDataKelas(String kelas) async {
    final response = await http.get(Uri.parse('https://ilyasa.fazrilsh.com/api/leaderboard/$kelas'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load leaderboard data for kelas');
  }

  Future<List<dynamic>> fetchLeaderboardDataGlobal() async {
    final response = await http.get(Uri.parse('https://ilyasa.fazrilsh.com/api/leaderboard'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load global leaderboard data');
  }

  Widget buildSkeletonItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Item leaderboard: nomor, avatar, nama, dan poin (dengan posisi poin fixed)
  Widget _buildLeaderboardItem(Map<String, dynamic> user, {required int index, bool isCurrentUser = false}) {
    return InkWell(
      onTap: () => _showProfileDetailDialog(user, index, isCurrentUser),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Row(
          children: [
            Text(
              "$index.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundImage: (user['foto_profil'] != null && user['foto_profil'].toString().isNotEmpty)
                  ? NetworkImage(user['foto_profil'])
                  : NetworkImage(defaultProfileUrl),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                user['name'] ?? '',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Container(
              width: 80,
              alignment: Alignment.centerRight,
              child: Text(
                "${user['points']} pts",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            if (isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(Icons.emoji_events, color: Colors.amber, size: 28),
              ),
          ],
        ),
      ),
    );
  }

  // Detail dialog untuk profil
  void _showProfileDetailDialog(Map<String, dynamic> user, int index, bool isCurrentUser) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("$index. ${user['name']}", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: (user['foto_profil'] != null && user['foto_profil'].toString().isNotEmpty)
                  ? NetworkImage(user['foto_profil'])
                  : NetworkImage(defaultProfileUrl),
            ),
            SizedBox(height: 12),
            Text("Kelas: ${user['kelas'] ?? '-'}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Points: ${user['points']}", style: TextStyle(fontSize: 16)),
            if (isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Ini adalah profil Anda", style: TextStyle(fontSize: 14, color: Colors.grey)),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Tutup", style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildCurrentUserHeader(int currentUserIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          currentUserIndex == -1
              ? "Anda belum terdaftar di leaderboard."
              : "Peringkat Anda: ${currentUserIndex + 1}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Footer: tampilkan profil pengguna sendiri dengan detail lengkap (avatar, nama, peringkat)
  Widget _buildCurrentUserFooter(List<dynamic> sortedData, int currentUserIndex) {
    if (currentUserIndex == -1) return SizedBox.shrink();
    final user = sortedData[currentUserIndex];
    return InkWell(
      onTap: () => _showProfileDetailDialog(user, currentUserIndex + 1, true),
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue, width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: (user['foto_profil'] != null && user['foto_profil'].toString().isNotEmpty)
                  ? NetworkImage(user['foto_profil'])
                  : NetworkImage(defaultProfileUrl),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? "",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text("Peringkat: ${currentUserIndex + 1}", style: TextStyle(fontSize: 16, color: Colors.black87)),
                ],
              ),
            ),
            Icon(Icons.emoji_events, color: Colors.amber, size: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(List<dynamic> data) {
    List<dynamic> sortedData = List.from(data);
    sortedData.sort((a, b) => b['points'].compareTo(a['points']));
    List<dynamic> top50Data = sortedData.take(50).toList();
    int currentUserIndex = -1;
    if (currentUserName != null) {
      currentUserIndex = sortedData.indexWhere((user) => user['name'] == currentUserName);
    }
    return Column(
      children: [
        _buildCurrentUserHeader(currentUserIndex),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: top50Data.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey.shade400, thickness: 1),
            itemBuilder: (context, index) {
              final user = top50Data[index];
              final bool isCurrentUser =
                  (currentUserName != null && user['name'] == currentUserName);
              return _buildLeaderboardItem(user, index: index + 1, isCurrentUser: isCurrentUser);
            },
          ),
        ),
        _buildCurrentUserFooter(sortedData, currentUserIndex),
      ],
    );
  }

  Widget _buildPointsLeaderboard(List<dynamic> data) {
    List<dynamic> sortedData = List.from(data);
    sortedData.sort((a, b) => b['points'].compareTo(a['points']));
    List<dynamic> top50Data = sortedData.take(50).toList();
    int currentUserIndex = -1;
    if (currentUserName != null) {
      currentUserIndex = sortedData.indexWhere((user) => user['name'] == currentUserName);
    }
    return Column(
      children: [
        _buildCurrentUserHeader(currentUserIndex),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: top50Data.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey.shade400, thickness: 1),
            itemBuilder: (context, index) {
              final user = top50Data[index];
              final bool isCurrentUser =
                  (currentUserName != null && user['name'] == currentUserName);
              return _buildLeaderboardItem(user, index: index + 1, isCurrentUser: isCurrentUser);
            },
          ),
        ),
        _buildCurrentUserFooter(sortedData, currentUserIndex),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Leaderboard", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'Leaderboard Kelas', icon: Icon(Icons.group, color: Colors.black)),
              Tab(text: 'Leaderboard Nesta', icon: Icon(Icons.people, color: Colors.black)),
            ],
          ),
        ),
        body: (kelas == null)
            ? Center(child: CircularProgressIndicator(color: Colors.blue))
            : TabBarView(
                children: [
                  FutureBuilder<List<dynamic>>(
                    future: leaderboardDataKelas,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                          itemCount: 6,
                          itemBuilder: (context, index) => buildSkeletonItem(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No Data Available', style: TextStyle(color: Colors.black)));
                      }
                      return _buildLeaderboardList(snapshot.data!);
                    },
                  ),
                  FutureBuilder<List<dynamic>>(
                    future: leaderboardDataGlobal,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                          itemCount: 6,
                          itemBuilder: (context, index) => buildSkeletonItem(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No Data Available', style: TextStyle(color: Colors.black)));
                      }
                      return _buildPointsLeaderboard(snapshot.data!);
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
