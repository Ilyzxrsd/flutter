import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'result_page.dart'; // Impor halaman hasil

class Question extends StatefulWidget {
  const Question({super.key});
  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  int currentQuestion = 0;
  bool isAnswered = false;
  // Simpan jawaban tiap soal
  Map<int, String> userAnswers = {};
  // Catat soal yang sudah dipakai clue: true jika clue digunakan
  Map<int, bool> usedClue = {};
  int correctAnswers = 0;
  List<Map<String, dynamic>> questions = [];
  String jurusan = "";
  String jurusanFull = "";

  // Map kode jurusan ke nama lengkap
  final Map<String, String> jurusanMap = {
    'tjkt': 'Teknik Jaringan Komputer Telekomunikasi',
    'akl': 'Akuntansi',
    'pm': 'Pemasaran',
    'dkv': 'Desain Komunikasi Visual',
    'titl': 'Teknik Instalasi Tenaga Listrik',
    'mplb': 'Manajemen Perkantoran Layanana Bisnis',
  };

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  // Fungsi mengambil soal dari API
  Future<void> _fetchQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    jurusan = prefs.getString('jurusan') ?? '';
    jurusanFull = jurusanMap[jurusan] ?? jurusan;

    final response = await http.get(Uri.parse('https://ilyasa.fazrilsh.com/api/soal/$jurusan'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('data')) {
        List<dynamic> data = jsonResponse['data'];
        // Ambil maksimal 10 soal
        List<dynamic> limitedData = data.length > 10 ? data.sublist(0, 10) : data;
        setState(() {
          questions = List<Map<String, dynamic>>.from(limitedData.map((item) {
            return {
              "id": item["id"],
              "question": item["pertanyaan"],
              "options": [
                item["jawaban_a"],
                item["jawaban_b"],
                item["jawaban_c"],
                item["jawaban_d"],
              ],
              "answer": item["jawaban_benar"], // misal: "a", "b", "c", atau "d"
              "image": item["image"] ?? "",
              "clue": item["clue"] ?? "Tidak ada clue",
            };
          }).toList());
        });
      } else {
        print('Data tidak ditemukan dalam response');
      }
    } else {
      print('Gagal mengambil soal. Status code: ${response.statusCode}');
    }
  }

  // Fungsi untuk berpindah ke soal berikutnya atau submit jika sudah selesai
  void _nextQuestion() {
    setState(() {
      if (currentQuestion < questions.length - 1) {
        currentQuestion++;
        isAnswered = false;
      } else {
        _submitAnswers();
      }
    });
  }

  // Confirmation dialog dua tahap dengan UI yang lebih rapi
  void _confirmUseClue(BuildContext context) {
    // Jika clue sudah pernah dipakai, langsung tampilkan popup clue
    if (usedClue[currentQuestion] == true) {
      _showCluePopup(context);
      return;
    }

    // Dialog pertama: konfirmasi awal penggunaan clue
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Konfirmasi Clue",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Apakah Anda yakin ingin menggunakan clue untuk soal ini?"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Dialog kedua: peringatan pengurangan poin
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        "Peringatan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: const Text(
                        "Menggunakan clue akan mengurangi poin sebesar 3.\n\nJawaban benar tanpa clue: 10 poin\nJawaban benar dengan clue: 7 poin\n\nApakah Anda ingin menggunakan clue ini?",
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Batal", style: TextStyle(color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              usedClue[currentQuestion] = true;
                            });
                            _showCluePopup(context);
                          },
                          child: const Text("Ya, Gunakan", style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text("Ya", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery untuk responsivitas
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      // Tombol Next muncul jika soal sudah dijawab
      floatingActionButton: isAnswered
          ? FloatingActionButton(
              onPressed: _nextQuestion,
              backgroundColor: Colors.white,
              child: const Icon(Icons.arrow_forward, color: Colors.black),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header: back button, judul, dan tombol Clue di pojok kanan atas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Kuis Jurusan ${jurusan.toUpperCase()}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            "(${jurusanFull})",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    // Tombol Clue di pojok kanan atas (hanya jika soal belum dijawab)
                    if (!isAnswered)
                      IconButton(
                        icon: const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 30),
                        onPressed: () {
                          _confirmUseClue(context);
                        },
                      ),
                  ],
                ),
              ),
              // Konten soal
              Container(
                width: screenWidth,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pertanyaan
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                      child: Text(
                        questions.isNotEmpty ? questions[currentQuestion]["question"] : "Loading...",
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // Gambar soal (atau fallback container jika tidak ada)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: (questions.isNotEmpty &&
                              (questions[currentQuestion]["image"] as String).isNotEmpty)
                          ? GestureDetector(
                              onTap: () {
                                // Buka halaman zoom dengan InteractiveViewer
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(
                                      title: const Text("Zoom Image"),
                                      backgroundColor: Colors.black,
                                    ),
                                    backgroundColor: Colors.black,
                                    body: InteractiveViewer(
                                      child: Center(
                                        child: Image.network(
                                          questions[currentQuestion]["image"],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  questions[currentQuestion]["image"],
                                  height: screenHeight * 0.3,
                                  width: screenWidth,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              height: screenHeight * 0.3,
                              width: screenWidth,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "No Image",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20.0),
                    // Daftar opsi jawaban
                    if (questions.isNotEmpty)
                      ...questions[currentQuestion]["options"]
                          .asMap()
                          .entries
                          .map((entry) {
                        String optionLetter = ['a', 'b', 'c', 'd'][entry.key];
                        return _buildAnswerOption(entry.value, optionLetter);
                      }).toList(),
                    // Feedback jawaban
                    if (isAnswered) _buildResultMessage(),
                    const SizedBox(height: 30.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget opsi jawaban
  Widget _buildAnswerOption(String option, String optionLabel) {
    bool isSelected = (userAnswers[currentQuestion] == optionLabel);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: GestureDetector(
        onTap: () {
          if (!isAnswered) {
            setState(() {
              userAnswers[currentQuestion] = optionLabel;
              isAnswered = true;
              if (optionLabel == questions[currentQuestion]["answer"]) {
                correctAnswers++;
              }
              // Jawaban terkunci—siap melaju ke soal selanjutnya!
            });
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF818181), width: 1.5),
            borderRadius: BorderRadius.circular(15),
            color: isSelected ? Colors.blue[100] : Colors.white,
          ),
          child: Text(
            option,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // Widget feedback jawaban
  Widget _buildResultMessage() {
    bool isCorrect = userAnswers[currentQuestion] == questions[currentQuestion]["answer"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Text(
        isCorrect ? "Jawaban Benar!" : "Jawaban Salah!",
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: isCorrect ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  // Submit jawaban ke API dan hitung poin:
  // Jika soal dijawab benar dan clue digunakan → 7 poin, jika tidak → 10 poin.
  Future<void> _submitAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username') ?? '';
    String jurusan = prefs.getString('jurusan') ?? '';

    Map<String, String> jawabanMap = {};
    int totalPoints = 0;
    for (int i = 0; i < questions.length; i++) {
      jawabanMap[questions[i]["id"].toString()] = userAnswers[i] ?? "";
      if (userAnswers[i] == questions[i]["answer"]) {
        totalPoints += (usedClue[i] == true) ? 7 : 10;
      }
    }

    final response = await http.post(
      Uri.parse('https://ilyasa.fazrilsh.com/api/jawab/$jurusan'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'jawaban': jawabanMap,
        'points': totalPoints,
      }),
    );

    if (response.statusCode == 200) {
      _goToResultPage(totalPoints);
    } else {
      print('Failed to submit answers. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  // Arahkan ke halaman hasil
  void _goToResultPage(int points) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          points: points,
          totalQuestions: questions.length,
          correctAnswers: correctAnswers,
        ),
      ),
    );
  }

  // Popup Clue dengan informasi pengurangan poin
  void _showCluePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff004840), Color(0xff00695C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Judul dan ikon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lightbulb_outline, color: Colors.amber, size: 30),
                    SizedBox(width: 10),
                    Text(
                      "Clue",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Informasi pengurangan poin
                const Text(
                  "Menggunakan clue akan mengurangi poin sebesar 3 (jawaban benar bernilai 7 poin).",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Tampilan clue
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    questions[currentQuestion]["clue"],
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    "Tutup",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff004840),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
