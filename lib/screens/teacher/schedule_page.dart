import 'package:flutter/material.dart';
import '../../constants/constant.dart';

class SchedulePage extends StatelessWidget {
  final Map<String, List<Map<String, String>>> jadwalPerHari = {
    "Senin": [
      {"mataPelajaran": "Matematika", "waktu": "08:00 - 09:30"},
      {"mataPelajaran": "Bahasa Indonesia", "waktu": "10:00 - 11:30"},
    ],
    "Selasa": [
      {"mataPelajaran": "Produktif", "waktu": "08:00 - 09:30"},
    ],
    "Rabu": [
      {"mataPelajaran": "Produktif", "waktu": "10:00 - 11:30"},
    ],
    "Kamis": [],
    "Jumat": [
      {"mataPelajaran": "Produktif", "waktu": "08:00 - 09:30"},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Mengajar'),
        backgroundColor: primaryAccentColor,
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: jadwalPerHari.keys.length,
          itemBuilder: (context, index) {
            final hari = jadwalPerHari.keys.elementAt(index);
            final jadwal = jadwalPerHari[hari]!;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text(
                  hari,
                  style: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold),
                ),
                children: jadwal.isEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Tidak ada jadwal',
                            style: TextStyle(color: greyTextColor),
                          ),
                        )
                      ]
                    : jadwal.map((item) {
                        return ListTile(
                          title: Text(item["mataPelajaran"]!, style: TextStyle(color: textPrimaryColor)),
                          subtitle: Text(item["waktu"]!, style: TextStyle(color: greyTextColor)),
                        );
                      }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
