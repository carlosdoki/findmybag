import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  const AppText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
    );
  }
}
