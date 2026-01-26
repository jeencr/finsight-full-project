import 'dart:convert';
import 'package:finsight_app/register.dart';
import 'package:finsight_app/user_home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AppLogin12());
}

class AppLogin12 extends StatelessWidget {
  const AppLogin12({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FINSIGHT Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // FINSIGHT Dark Theme
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFEB1616), // --primary: #EB1616
          secondary: const Color(0xFF191C24), // --secondary: #191C24
          surface: const Color(0xFF000000), // --dark: #000000
          background: const Color(0xFF000000),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: const Color(0xFF6C7293), // --light: #6C7293
          onSurface: const Color(0xFF6C7293),
        ),
        scaffoldBackgroundColor: const Color(0xFF000000),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF191C24),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF191C24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C7293), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEB1616), width: 2),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF6C7293),
            fontSize: 16,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF6C7293),
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEB1616),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 3,
            shadowColor: const Color(0xFFEB1616).withOpacity(0.3),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          displaySmall: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF6C7293),
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF6C7293),
            fontSize: 14,
          ),
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        useMaterial3: true,
      ),
      home: const AppLogin12Page(title: 'FINSIGHT Login'),
    );
  }
}

class AppLogin12Page extends StatefulWidget {
  const AppLogin12Page({super.key, required this.title});

  final String title;

  @override
  State<AppLogin12Page> createState() => _AppLogin12PageState();
}

class _AppLogin12PageState extends State<AppLogin12Page> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _uname = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username is required';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  Future<void> _login() async {
    if (!_formkey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final sh = await SharedPreferences.getInstance();
    String username = _uname.text.trim();
    String password = _pwd.text.trim();
    String url = sh.getString("url") ?? "";

    try {
      final res = await http.post(
        Uri.parse("$url/loginapp/"),
        body: {
          'username': username,
          'password': password,
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        String status = data['status'].toString();

        if (status == 'success') {
          // Save user ID to shared preferences
          int lid = data['lid'];
          await sh.setInt('lid', lid);
          await sh.setString('username', username);

          // Navigate to user dashboard
          _showSuccessMessage('Login successful!');
          // TODO: Navigate to user dashboard
          Navigator.push(context, MaterialPageRoute(builder: (context) => UserHome()));

        } else if (status == 'error') {
          String message = data['message'].toString();
          _showErrorMessage(message);
        }
      } else {
        _showErrorMessage('Server error: ${res.statusCode}');
      }
    } catch (e) {
      _showErrorMessage('Connection error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEB1616),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF191C24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Forgot Password',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please enter your email to reset your password.',
                style: TextStyle(color: Color(0xFF6C7293)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Color(0xFF6C7293)),
                  hintText: 'your-email@example.com',
                  hintStyle: const TextStyle(color: Color(0xFF6C7293)),
                  filled: true,
                  fillColor: const Color(0xFF000000),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6C7293)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEB1616)),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF6C7293)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final email = _emailController.text;
                if (email.isNotEmpty && email.contains('@')) {
                  // TODO: Implement API call to send password reset email
                  _showSuccessMessage('Password reset link sent to $email');
                  Navigator.of(context).pop();
                } else {
                  _showErrorMessage('Please enter a valid email address.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEB1616),
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToRegister() {
    // TODO: Navigate to registration page
    Navigator.push(context, MaterialPageRoute(builder: (context) =>  FinsightRegisterPage(title: '')));
  }

  void _navigateToHome() {
    // TODO: Navigate back to home/IP setup page
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000),
              Color(0xFF191C24),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _navigateToHome,
                    ),
                  ),

                  // Logo/Header Section
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF191C24),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEB1616).withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.analytics_outlined,
                          size: 80,
                          color: Color(0xFFEB1616),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'FINSIGHT',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to your account',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6C7293),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Login Card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191C24),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF6C7293).withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          // Username Field
                          TextFormField(
                            controller: _uname,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              labelStyle: TextStyle(color: Color(0xFF6C7293)),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Color(0xFF6C7293),
                              ),
                              filled: true,
                              fillColor: Color(0xFF000000),
                            ),
                            validator: _validateUsername,
                          ),

                          const SizedBox(height: 20),

                          // Password Field
                          TextFormField(
                            controller: _pwd,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Color(0xFF6C7293)),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Color(0xFF6C7293),
                              ),
                              filled: true,
                              fillColor: Color(0xFF000000),
                            ),
                            validator: _validatePassword,
                          ),

                          const SizedBox(height: 24),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: _isLoading
                                ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFEB1616),
                              ),
                            )
                                : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEB1616),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                              ),
                              child: const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _navigateToRegister,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFF6C7293),
                                  width: 1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'CREATE NEW ACCOUNT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Forgot Password
                          TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFF6C7293),
                                fontSize: 14,
                              ),
                            ),
                          ),

                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: const Color(0xFF6C7293)
                                        .withOpacity(0.3),
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: const Color(0xFF6C7293),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: const Color(0xFF6C7293)
                                        .withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Demo Credentials
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000000),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF6C7293).withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Demo Credentials',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Use demo account to explore features',
                                  style: TextStyle(
                                    color: const Color(0xFF6C7293),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Username: demo_user',
                                            style: TextStyle(
                                              color: const Color(0xFF6C7293),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Password: demo123',
                                            style: TextStyle(
                                              color: const Color(0xFF6C7293),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _uname.text = 'demo_user';
                                        _pwd.text = 'demo123';
                                        _login();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xFF191C24),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                      ),
                                      child: const Text(
                                        'Try Demo',
                                        style: TextStyle(fontSize: 12),
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

                  const SizedBox(height: 32),

                  // Footer
                  Column(
                    children: [
                      Text(
                        'FINSIGHT © 2025',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF6C7293).withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Financial Intelligence Platform',
                        style: TextStyle(
                          fontSize: 10,
                          color: const Color(0xFF6C7293).withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _uname.dispose();
    _pwd.dispose();
    _emailController.dispose();
    super.dispose();
  }
}