import 'package:flutter/material.dart';
import '../../constants/constant.dart';

class MaterialScreen extends StatefulWidget {
  @override
  _MaterialScreenState createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  List<Map<String, String>> materi = [
    {"judul": "Matematika Dasar", "isi": "Pembahasan tentang aljabar dasar."},
    {"judul": "Fisika Lanjutan", "isi": "Materi tentang dinamika gerak."},
    {"judul": "Bahasa Indonesia", "isi": "Menulis teks eksposisi dengan baik."},
  ];

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();

  void _showDialog({Map<String, String>? currentMaterial, int? index}) {
    if (currentMaterial != null) {
      _judulController.text = currentMaterial["judul"]!;
      _isiController.text = currentMaterial["isi"]!;
    } else {
      _judulController.clear();
      _isiController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(currentMaterial == null ? 'Tambah Materi' : 'Edit Materi'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _judulController,
                  decoration: const InputDecoration(labelText: 'Judul Materi'),
                ),
                TextField(
                  controller: _isiController,
                  decoration: const InputDecoration(labelText: 'Isi Materi'),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (currentMaterial != null && index != null) {
                  _editMaterial(index);
                } else {
                  _addMaterial();
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _addMaterial() {
    setState(() {
      materi.add({"judul": _judulController.text, "isi": _isiController.text});
    });
  }

  void _editMaterial(int index) {
    setState(() {
      materi[index] = {"judul": _judulController.text, "isi": _isiController.text};
    });
  }

  void _deleteMaterial(int index) {
    setState(() {
      materi.removeAt(index);
    });
  }

  void _viewMaterial(Map<String, String> material) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(material["judul"]!),
          content: Text(material["isi"]!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Materi'),
        backgroundColor: primaryAccentColor,
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: materi.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(
                  materi[index]["judul"]!,
                  style: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  materi[index]["isi"]!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: greyTextColor),
                ),
                onTap: () => _viewMaterial(materi[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showDialog(currentMaterial: materi[index], index: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMaterial(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        backgroundColor: primaryAccentColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
