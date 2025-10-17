// lib/pages/login_page.dart

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The main Scaffold is now wrapped in a Stack to layer the background image
    return Stack(
      children: [
        // Layer 1: Background Image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/backgrounds/login_page.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Layer 2: Dark semi-transparent overlay for readability
        Container(
          color: Colors.black.withOpacity(0.5),
        ),
        // Layer 3: The Scaffold and its content
        Scaffold(
          // --- CHANGE 1: Made Scaffold background transparent ---
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Top Section with transparent curve
                SizedBox(
                  // Set height to be a bit less to create space from top
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Stack(
                    children: [
                      // Back Button
                      Positioned(
                        top: 40,
                        left: 20,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      // --- CHANGE 2: The curved container is now transparent ---
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          decoration: const BoxDecoration(
                            // This transparent color just provides the shape
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- CHANGE 3: Text colors changed to white for contrast ---
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Changed
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Login to your account',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[300], // Changed
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Login Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildInputField(
                              controller: _fullNameController,
                              label: 'Full Name',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              controller: _emailController,
                              label: 'user@mail.com',
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              controller: _passwordController,
                              label: '........',
                              icon: Icons.lock_outline,
                              obscureText: !_isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey[400], // Changed
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Remember Me & Forgot Password
                      Row(
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFF2E7D32),
                                  checkColor: Colors.white,
                                  side: BorderSide(color: Colors.white), // Changed
                                ),
                                Flexible(
                                  child: Text(
                                    'Remember Me',
                                    style: TextStyle(color: Colors.grey[300]), // Changed
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.white, // Changed
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Don't have an account? Sign up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.grey[300]), // Changed
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                color: Colors.white, // Changed
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- CHANGE 4: Input field styling updated for transparent background ---
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Semi-transparent background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(color: Colors.white), // Input text color
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[300]), // Label text color
          prefixIcon: Icon(icon, color: Colors.grey[300]), // Icon color
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        ),
      ),
    );
  }
}