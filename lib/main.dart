import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import all your page files
import 'pages/intro_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/map_page.dart';
import 'pages/ar_page.dart';
import 'pages/achievements_page.dart';
import 'pages/settings_page.dart';

// The main function is now async to allow checking for saved data before running the app
void main() async {
  // Ensure Flutter's widget binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Get instance of SharedPreferences to check for a saved user name
  final prefs = await SharedPreferences.getInstance();
  final String? userName = prefs.getString('userName');

  // Run the app, passing a flag to indicate if the user is already logged in
  runApp(MyApp(isLoggedIn: userName != null));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

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

  // Light Theme Color Palette: "Sunny Forest Clearing"
  final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5DC), // Soft Beige
    primaryColor: const Color(0xFF228B22), // Forest Green
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF228B22), // Forest Green
      secondary: Color(0xFF90EE90), // Light Green
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF8B4513)), // Earthy Brown
        bodyMedium: TextStyle(color: Color(0xFF8B4513)), // Earthy Brown
        titleLarge: TextStyle(color: Color(0xFF8B4513)), // Earthy Brown
        titleMedium: TextStyle(color: Color(0xFF8B4513)), // Earthy Brown
        titleSmall: TextStyle(color: Color(0xFFA9A9A9)), // Muted Gray
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFA9A9A9)), // Muted Gray
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F5DC), // Soft Beige
      foregroundColor: Color(0xFF8B4513), // Earthy Brown
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF228B22), // Forest Green
        foregroundColor: Colors.white,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF90EE90), // Light Green
    ),
  );

  // Dark Theme Color Palette: "Deep Forest at Night"
  final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF2D1B06), // Dark Charcoal
    primaryColor: const Color(0xFF90EE90), // Light Green
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF90EE90), // Light Green
      secondary: Color(0xFF8B4513), // Earthy Brown
      onPrimary: Colors.black,
      onSecondary: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFF5F5DC)), // Soft Beige
        bodyMedium: TextStyle(color: Color(0xFFF5F5DC)), // Soft Beige
        titleLarge: TextStyle(color: Color(0xFFF5F5DC)), // Soft Beige
        titleMedium: TextStyle(color: Color(0xFFF5F5DC)), // Soft Beige
        titleSmall: TextStyle(color: Color(0xFFA9A9A9)), // Muted Gray
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFA9A9A9)), // Muted Gray
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2D1B06), // Dark Charcoal
      foregroundColor: Color(0xFFF5F5DC), // Soft Beige
    ),
    cardColor: const Color(0xFF8B4513), // Earthy Brown for Card Backgrounds
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF90EE90), // Light Green
        foregroundColor: Colors.black,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF90EE90), // Light Green
    ),
  );


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataForest',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,

      // The initial route is now dynamic: '/home' if logged in, otherwise '/'
      initialRoute: widget.isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => IntroPage(),
        '/login': (context) => LoginPage(),
        // Pass the theme-changing function to the HomeWrapper
        '/home': (context) => HomeWrapper(changeTheme: _changeTheme),
      },
    );
  }
}

// HomeWrapper is updated to load the user's name and pass it to child pages
class HomeWrapper extends StatefulWidget {
  final Function(ThemeMode) changeTheme;
  const HomeWrapper({Key? key, required this.changeTheme}) : super(key: key);

  @override
  _HomeWrapperState createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;
  int _previousIndex = 0;
  String _userName = ''; // Starts empty, will be loaded from storage
  List<Widget> _pages = []; // Starts as an empty list

  final List<String> _pageTitles = [
    'TERRALYTICS', 'Environmental Map', 'AR Experience', 'Achievements', 'Settings'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserNameAndInitPages();
  }

  // This function loads the saved name and then builds the list of pages
  Future<void> _loadUserNameAndInitPages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load the name, providing a default value if none is found
      _userName = prefs.getString('userName') ?? 'Eco-Warrior';

      // IMPORTANT: Initialize the pages list *after* the name is loaded
      _pages = [
        HomePage(userName: _userName), // Pass the loaded name here
        MapPage(),
        ARPage(),
        AchievementsPage(userName: _userName), // Pass the loaded name here
        SettingsPage(changeTheme: widget.changeTheme),
      ];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  void _showSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Quick Navigation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildSearchOption(context, Icons.home, 'Home', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            }),
            _buildSearchOption(context, Icons.map, 'Environmental Map', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 1);
            }),
            _buildSearchOption(context, Icons.camera_alt, 'AR Experience', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 2);
            }),
            _buildSearchOption(context, Icons.emoji_events, 'Achievements', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            }),
            _buildSearchOption(context, Icons.settings, 'Settings', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 4);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchOption(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Official Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildNotificationItem('🌿 Forest Conservation Meeting', 'Join us this Saturday for community conservation efforts.'),
                  _buildNotificationItem('📊 New Environmental Data', 'Updated pollution metrics available in your area.'),
                  _buildNotificationItem('🎯 Volunteer Opportunity', 'Help clean up coastal areas this weekend.'),
                  _buildNotificationItem('📢 NGO Announcement', 'New conservation initiatives launching next month.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading circle while the user's name and pages are being prepared
    if (_pages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Once pages are ready, build the main UI
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(_pageTitles[_currentIndex], key: ValueKey(_currentIndex)),
        ),
        elevation: 0,
        // Search and notification icons now appear on ALL pages, not just home
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchModal(context),
            tooltip: 'Search Pages',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => _showNotifications(context),
            tooltip: 'NGO Notifications',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
        transitionBuilder: (Widget child, Animation<double> animation) {
          final slideAnimation = Tween<Offset>(
            begin: _currentIndex > _previousIndex ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
          return SlideTransition(position: slideAnimation, child: child);
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: GNav(
              backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
              color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
              activeColor: Theme.of(context).primaryColor,
              tabBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              gap: 6,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              duration: const Duration(milliseconds: 400),
              tabs: const [
                GButton(icon: Icons.home_outlined, text: 'Home'),
                GButton(icon: Icons.map_outlined, text: 'Map'),
                GButton(icon: Icons.camera_alt_outlined, text: 'AR'),
                GButton(icon: Icons.emoji_events_outlined, text: 'Achieve'),
                GButton(icon: Icons.settings_outlined, text: 'Settings'),
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