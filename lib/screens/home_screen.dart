import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF3F3F3F),
      child: const Center(
        child: Text(
          'Главная страница',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}