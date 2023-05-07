// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:findmybag/screens/chat_bot_screen.dart';
import 'package:findmybag/screens/map_screen.dart';
import 'package:findmybag/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  static const id = 'main_screen.dart';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List screens = [
    // HomeScreen(),
    MapScreen(),
    ChatBotScreen(),
    ProfileScreen(),
  ];
  int currentIndex = 0;
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        unselectedFontSize: 0,
        selectedFontSize: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        onTap: onTap,
        currentIndex: currentIndex,
        selectedItemColor: Colors.black54,
        unselectedItemColor: Colors.grey.withOpacity(0.5),
        showUnselectedLabels: false,
        showSelectedLabels: false,
        elevation: 0,
        items: [
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.message_outlined), label: 'Chat Bot'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined), label: 'Profile'),
        ],
      ),
    );
  }
}
