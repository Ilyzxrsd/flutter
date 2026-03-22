import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;

  QuestionCard({
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            _buildOption(context, optionA),
            _buildOption(context, optionB),
            _buildOption(context, optionC),
            _buildOption(context, optionD),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String optionText) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          // Aksi ketika opsi dipilih
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Color(0xFF1A73E8), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(optionText),
      ),
    );
  }
}
