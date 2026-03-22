class Event {
  final String judul;
  final String tanggal;
  final String gambar;
  final String isi;

  Event({
    required this.judul,
    required this.tanggal,
    required this.gambar,
    required this.isi,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      judul: json['judul'] ?? '',
      tanggal: json['tanggal'] ?? '',
      gambar: json['gambar'] ?? '', // Pastikan gambar sesuai dengan data dari backend
      isi: json['isi'] ?? '',
    );
  }
}
