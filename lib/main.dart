import 'package:flutter/material.dart';
import 'pages/intro_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/map_page.dart';
import 'pages/ar_page.dart';
import 'pages/achievements_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Guardian - Presidential Hackathon',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => IntroPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/map': (context) => MapPage(),
        '/ar': (context) => ARPage(),
        '/achievements': (context) => AchievementsPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}