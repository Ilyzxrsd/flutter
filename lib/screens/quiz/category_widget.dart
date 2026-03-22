import 'package:flutter/material.dart';
import 'category_model.dart';

class CategoryWidget extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryWidget({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 5.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                category.imagePath,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10.0),
              Text(
                category.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
