import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const id = 'home_screen.dart';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'HomeScreen',
        style: TextStyle(
          fontSize: 30,
        ),
      ),
    );
  }
}
