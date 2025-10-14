import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class GNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: GNav(
          // Customization
          backgroundColor: Colors.white,
          color: Colors.grey[600],
          activeColor: Colors.green,
          tabBackgroundColor: Colors.green.withOpacity(0.1),
          gap: 8,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: Duration(milliseconds: 400),
          tabMargin: EdgeInsets.only(bottom: 5),

          // Tabs
          tabs: [
            GButton(
              icon: Icons.home,
              text: 'Home',
              iconSize: 24,
            ),
            GButton(
              icon: Icons.map,
              text: 'Map',
              iconSize: 24,
            ),
            GButton(
              icon: Icons.camera_alt,
              text: 'AR',
              iconSize: 24,
            ),
            GButton(
              icon: Icons.emoji_events,
              text: 'Achieve',
              iconSize: 24,
            ),
            GButton(
              icon: Icons.settings,
              text: 'Settings',
              iconSize: 24,
            ),
          ],

          // Current selection
          selectedIndex: currentIndex,
          onTabChange: onTap,
        ),
      ),
    );
  }
}