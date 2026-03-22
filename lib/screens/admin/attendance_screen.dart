import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String selectedKelas = '';
  String selectedJurusan = '';

  late Future<List<Map<String, dynamic>>> absensiData;
  late Future<List<Map<String, dynamic>>> izinData;

  // Fungsi untuk fetch data Absensi berdasarkan kelas dan jurusan
  Future<List<Map<String, dynamic>>> fetchAbsensiData() async {
    final response = await http.get(Uri.parse(
        'https://ilyasa.fazrilsh.com/api/absensi?kelas=$selectedKelas&jurusan=$selectedJurusan'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load absensi data');
    }
  }

  // Fungsi untuk fetch data Izin berdasarkan kelas dan jurusan
  Future<List<Map<String, dynamic>>> fetchIzinData() async {
    final response = await http.get(Uri.parse(
        'https://ilyasa.fazrilsh.com/api/izin?kelas=$selectedKelas&jurusan=$selectedJurusan'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load izin data');
    }
  }

  @override
  void initState() {
    super.initState();
    absensiData = fetchAbsensiData();
    izinData = fetchIzinData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rekap Absensi dan Izin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown untuk Kelas
            Text("Pilih Kelas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey)),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: DropdownButton<String>(
                value: selectedKelas.isEmpty ? null : selectedKelas,
                isExpanded: true,
                hint: Text("Pilih Kelas"),
                onChanged: (value) {
                  setState(() {
                    selectedKelas = value ?? '';
                    absensiData = fetchAbsensiData();
                    izinData = fetchIzinData();
                  });
                },
                items: [
                  'X TJKT 1', 'X TJKT 2', 'XI TKJ 1', 'XI TKJ 2', 'XII TKJ 1', 'XII TKJ 2', 'X PM 1', 'X PM 2',
                  'X PM 3', 'XI BR 1', 'XI BR 2', 'XI BR 3', 'XII BDP 1', 'XII BDP 2',
                  'XII BDP 3', 'X AKL 1', 'X AKL 2', 'X AKL 3', 'XI AKL 1', 'XI AKL 2',
                  'XI AKL 3', 'XII AKL 1', 'XII AKL 2','XII AKL 3', 'X MPLB 1', 'X MPLB 2',
                  'X MPLB 3', 'XI MPLB 1', 'XI MPLB 2', 'XI MPLB 3', 'XII MPLB 1', 'XII MPLB 2', 'XII MPLB 3',
                  'X DKV 1', 'X DKV 2', 'XI DKV 1', 'XI DKV 2', 'XII DKV 1', 'XII DKV 2', 'X TKL', 'XI TKL', 'XII TKL'
                ].map((kelas) => DropdownMenuItem<String>(value: kelas, child: Text(kelas))).toList(),
              ),
            ),

            SizedBox(height: 16),

            // Dropdown untuk Jurusan
            Text("Pilih Jurusan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey)),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: DropdownButton<String>(
                value: selectedJurusan.isEmpty ? null : selectedJurusan,
                isExpanded: true,
                hint: Text("Pilih Jurusan"),
                onChanged: (value) {
                  setState(() {
                    selectedJurusan = value ?? '';
                    absensiData = fetchAbsensiData();
                    izinData = fetchIzinData();
                  });
                },
                items: [
                  'tjkt', 'pm', 'akl', 'mplb', 'dkv', 'tkl'
                ].map((jurusan) => DropdownMenuItem<String>(
                      value: jurusan,
                      child: Text(jurusan.toUpperCase()), // Menampilkan huruf besar
                    ))
                    .toList(),
              ),
            ),

            SizedBox(height: 16),

            // Tabel Absensi dan Izin
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Colors.blueAccent,
                      unselectedLabelColor: Colors.blueGrey,
                      tabs: [
                        Tab(text: 'Absensi'),
                        Tab(text: 'Izin'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Tabel Absensi
                          FutureBuilder<List<Map<String, dynamic>>>( 
                            future: absensiData,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else if (snapshot.hasData) {
                                var data = snapshot.data!;
                                return DataTable(
                                  columns: [
                                    DataColumn(label: Text('Nama Siswa')),
                                    DataColumn(label: Text('Kelas')),
                                    DataColumn(label: Text('Jurusan')),
                                    DataColumn(label: Text('Tanggal Absen')),
                                    DataColumn(label: Text('Status Absen')),
                                  ],
                                  rows: data.map((row) {
                                    return DataRow(cells: [
                                      DataCell(Text(row['name'] ?? '')),
                                      DataCell(Text(row['kelas'] ?? '')),
                                      DataCell(Text((row['jurusan'] ?? '').toUpperCase())), // Menampilkan huruf besar
                                      DataCell(Text(row['tanggal_absen'] ?? '')),
                                      DataCell(Text(row['status_absen'] ?? '')),
                                    ]);
                                  }).toList(),
                                );
                              } else {
                                return Center(child: Text('No Data Available'));
                              }
                            },
                          ),
                          // Tabel Izin
                          FutureBuilder<List<Map<String, dynamic>>>( 
                            future: izinData,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else if (snapshot.hasData) {
                                var data = snapshot.data!;
                                return DataTable(
                                  columns: [
                                    DataColumn(label: Text('Nama Siswa')),
                                    DataColumn(label: Text('Kelas')),
                                    DataColumn(label: Text('Jurusan')),
                                    DataColumn(label: Text('Tanggal Izin')),
                                    DataColumn(label: Text('Alasan')),
                                  ],
                                  rows: data.map((row) {
                                    return DataRow(cells: [
                                      DataCell(Text(row['name'] ?? '')),
                                      DataCell(Text(row['kelas'] ?? '')),
                                      DataCell(Text((row['jurusan'] ?? '').toUpperCase())), // Menampilkan huruf besar
                                      DataCell(Text(row['tanggal'] ?? '')),
                                      DataCell(Text(row['alasan'] ?? '')),
                                    ]);
                                  }).toList(),
                                );
                              } else {
                                return Center(child: Text('No Data Available'));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
