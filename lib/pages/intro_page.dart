// lib/pages/intro_page.dart

import 'package:flutter/material.dart';
import 'login_page.dart'; // Import the LoginPage for the custom route
import 'package:google_fonts/google_fonts.dart'; // Make sure this import is present

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/backgrounds/intro_page.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Darker Overlay for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  // Main Title with Google Font
                  Text(
                    'Todays\ninsights for\ntomorrows wild',
                    style: GoogleFonts.lora( // Using Lora font
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        const Shadow(
                          blurRadius: 10.0,
                          color: Colors.black54,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(_createLoginRoute());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                        side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
                      ),
                      child: Text(
                        'Sign in',
                        style: GoogleFonts.lato( // Using Lato font
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Create an account Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(_createLoginRoute());
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withOpacity(0.8),
                      ),
                      child: Text(
                        'Create an account',
                        style: GoogleFonts.lato( // Using Lato font
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Animation method (unchanged)
  Route _createLoginRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutQuint;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final slideAnimation = animation.drive(tween);

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }
}