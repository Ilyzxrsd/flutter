class QuizQuestion {
  final int id;  // Menambahkan id sebagai integer
  final String pertanyaan;
  final String jawabanA;
  final String jawabanB;
  final String jawabanC;
  final String jawabanD;
  final String jawabanBenar;

  // Constructor dengan parameter yang dibutuhkan
  QuizQuestion({
    required this.id, // Pastikan id disertakan di constructor
    required this.pertanyaan,
    required this.jawabanA,
    required this.jawabanB,
    required this.jawabanC,
    required this.jawabanD,
    required this.jawabanBenar,
  });

  // Factory constructor untuk memetakan JSON dari API ke dalam objek QuizQuestion
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? 0,  // Pastikan id diambil dari JSON API
      pertanyaan: json['title'] ?? '',  // Menyesuaikan dengan properti JSON API
      jawabanA: json['jawaban_a'] ?? '', 
      jawabanB: json['jawaban_b'] ?? '',
      jawabanC: json['jawaban_c'] ?? '',
      jawabanD: json['jawaban_d'] ?? '',
      jawabanBenar: json['jawaban_benar'] ?? '', // Menggunakan kunci JSON yang benar
    );
  }

  // Method untuk mengubah objek QuizQuestion menjadi Map (untuk mengirimkan data ke API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': pertanyaan,
      'jawaban_a': jawabanA,
      'jawaban_b': jawabanB,
      'jawaban_c': jawabanC,
      'jawaban_d': jawabanD,
      'jawaban_benar': jawabanBenar,
    };
  }
}
