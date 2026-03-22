class Attendance {
  final String tanggalAbsen;
  final String name;
  final String statusAbsen;
  final String kelas; // Menambahkan kelas pada model

  Attendance({
    required this.tanggalAbsen,
    required this.name,
    required this.statusAbsen,
    required this.kelas, // Menambahkan kelas pada konstruktor
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      tanggalAbsen: json['tanggal_absen'],
      name: json['name'],
      statusAbsen: json['status_absen'],
      kelas: json['kelas'], // Parsing kelas
    );
  }
}
