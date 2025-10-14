// lib/main.dart (No changes needed, this file is correct)

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'pages/intro_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/map_page.dart';
import 'pages/ar_page.dart';
import 'pages/achievements_page.dart';
import 'pages/settings_page.dart';

// You will also need to create the other pages (MapPage, ARPage, etc.)
// For now, you can use placeholder widgets like this:
// class MapPage extends StatelessWidget { @override Widget build(BuildContext context) => Center(child: Text('Map Page')); }
// class ARPage extends StatelessWidget { @override Widget build(BuildContext context) => Center(child: Text('AR Page')); }
// class AchievementsPage extends StatelessWidget { @override Widget build(BuildContext context) => Center(child: Text('Achievements Page')); }
// class SettingsPage extends StatelessWidget { final Function(ThemeMode) changeTheme; const SettingsPage({Key? key, required this.changeTheme}) : super(key: key); @override Widget build(BuildContext context) => Center(child: Text('Settings Page')); }
// class IntroPage extends StatelessWidget { @override Widget build(BuildContext context) => Center(child: Text('Intro Page')); }
// class LoginPage extends StatelessWidget { @override Widget build(BuildContext context) => Center(child: Text('Login Page')); }


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataForest - Presidential Hackathon',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF121212),
        cardColor: Color(0xFF1E1E1E),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => IntroPage(), // Assuming you have IntroPage
        '/login': (context) => LoginPage(), // Assuming you have LoginPage
        '/home': (context) => HomeWrapper(changeTheme: _changeTheme),
      },
    );
  }
}

class HomeWrapper extends StatefulWidget {
  final Function(ThemeMode) changeTheme;

  const HomeWrapper({Key? key, required this.changeTheme}) : super(key: key);

  @override
  _HomeWrapperState createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;
  int _previousIndex = 0;

  final List<Widget> _pages = [];

  final List<String> _pageTitles = [
    'DataForest',
    'Environmental Map',
    'AR Experience',
    'Achievements',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomePage(),
      MapPage(),
      ARPage(),
      AchievementsPage(),
      SettingsPage(changeTheme: widget.changeTheme),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Text(
            _pageTitles[_currentIndex],
            key: ValueKey(_currentIndex),
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: _currentIndex == 0 ? [
          IconButton(
            icon: Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ] : null,
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _pages[_currentIndex],
        transitionBuilder: (Widget child, Animation<double> animation) {
          final slideAnimation = Tween<Offset>(
            begin: _currentIndex > _previousIndex
                ? Offset(1.0, 0.0)
                : Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));

          return SlideTransition(
            position: slideAnimation,
            child: child,
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: GNav(
              backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
              color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
              activeColor: Colors.green,
              tabBackgroundColor: Colors.green.withOpacity(0.1),
              gap: 6,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              duration: Duration(milliseconds: 400),
              textStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                  iconSize: 20,
                ),
                GButton(
                  icon: Icons.map,
                  text: 'Map',
                  iconSize: 20,
                ),
                GButton(
                  icon: Icons.camera_alt,
                  text: 'AR',
                  iconSize: 20,
                ),
                GButton(
                  icon: Icons.emoji_events,
                  text: 'Achieve',
                  iconSize: 20,
                ),
                GButton(
                  icon: Icons.settings,
                  text: 'Settings',
                  iconSize: 20,
                ),
              ],
              selectedIndex: _currentIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}