import 'package:flutter/material.dart';
import '../../constants/constant.dart';

class RekapPresensiScreen extends StatelessWidget {
  final Map<String, Map<String, List<String>>> presensi = {
    "Pemasaran 10.1": {
      "Hadir": ["Nau", "Asep"],
      "Tidak Hadir": ["Dummy"],
    },
    "TJKT 11.2": {
      "Hadir": ["asep", "udin"],
      "Tidak Hadir": ["asep"],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Presensi'),
        backgroundColor: primaryAccentColor,
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: presensi.keys.length,
          itemBuilder: (context, index) {
            final kelas = presensi.keys.elementAt(index);
            final hadir = presensi[kelas]?["Hadir"] ?? [];
            final tidakHadir = presensi[kelas]?["Tidak Hadir"] ?? [];
            hadir.sort(); 
            tidakHadir.sort(); 

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 5,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  kelas,
                  style: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: primaryAccentColor),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttendanceDetailPage(kelas: kelas, hadir: hadir, tidakHadir: tidakHadir),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class AttendanceDetailPage extends StatelessWidget {
  final String kelas;
  final List<String> hadir;
  final List<String> tidakHadir;

  const AttendanceDetailPage({required this.kelas, required this.hadir, required this.tidakHadir});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Presensi $kelas'),
        backgroundColor: primaryAccentColor,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hadir:",
              style: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ...hadir.map((siswa) => Text(siswa, style: TextStyle(color: greyTextColor))),
            Divider(color: greyTextColor.withOpacity(0.5)),
            Text(
              "Tidak Hadir:",
              style: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ...tidakHadir.map((siswa) => Text(siswa, style: TextStyle(color: greyTextColor))),
          ],
        ),
      ),
    );
  }
}
