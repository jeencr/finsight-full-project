import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

void main() {
  runApp(const MaterialApp(
    home: FinsightRegisterPage(title: 'FINSIGHT Registration'),
    debugShowCheckedModeBanner: false,
  ));
}

class FinsightRegisterPage extends StatefulWidget {
  const FinsightRegisterPage({super.key, required this.title});
  final String title;

  @override
  State<FinsightRegisterPage> createState() => _FinsightRegisterPageState();
}

class _FinsightRegisterPageState extends State<FinsightRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  // FINSIGHT Colors
  final Color _primaryColor = const Color(0xFFEB1616);
  final Color _secondaryColor = const Color(0xFF191C24);
  final Color _darkColor = const Color(0xFF000000);
  final Color _lightColor = const Color(0xFF6C7293);

  Future<void> _chooseImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      _showToast("No image selected", isError: true);
    }
  }

  Future<void> _sendData() async {
    if (!_formKey.currentState!.validate()) {
      _showToast("Please fix errors in the form", isError: true);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showToast("Passwords do not match", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    if (url == null) {
      _showToast("Server URL not found. Please setup server first.", isError: true);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final uri = Uri.parse('$url/registerapp/');
    var request = http.MultipartRequest('POST', uri);

    // Add all form fields matching Django model
    request.fields['username'] = _usernameController.text;
    request.fields['password'] = _passwordController.text;
    request.fields['name'] = _nameController.text;
    request.fields['email'] = _emailController.text;
    request.fields['phone'] = _phoneController.text;
    request.fields['age'] = _ageController.text;
    request.fields['place'] = _placeController.text;
    request.fields['nationality'] = _nationalityController.text;

    // Add photo if selected
    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200) {
        String status = data['status'].toString();
        String message = data['message']?.toString() ?? '';

        if (status == 'success') {

          _showToast("Registration successful! Please login.", isError: false);

          // Navigate back to login
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AppLogin12()),
            );
          }
        } else if (status == 'error') {
          _showToast(message, isError: true);
        }
      } else {
        _showToast("Server error: ${response.statusCode}", isError: true);
      }
    } catch (e) {
      _showToast("Connection error: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: isError ? _primaryColor : Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: _lightColor),
            filled: true,
            fillColor: _darkColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _lightColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            prefixIcon: prefixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AppLogin12()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: _darkColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const AppLogin12()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _secondaryColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_add_alt_1,
                          size: 60,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join FINSIGHT Financial Platform',
                        style: TextStyle(
                          fontSize: 14,
                          color: _lightColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Image Upload Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _secondaryColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _lightColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        _selectedImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: _darkColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _lightColor),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _chooseImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.camera_alt, size: 20),
                            label: const Text(
                              'UPLOAD PROFILE PHOTO',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload a clear profile picture (Optional)',
                          style: TextStyle(
                            fontSize: 12,
                            color: _lightColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Registration Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _secondaryColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _lightColor.withOpacity(0.3)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Personal Details Section
                          const Row(
                            children: [
                              Icon(Icons.person_outline, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Personal Information',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _buildInputField(
                            label: 'Full Name *',
                            controller: _nameController,
                            hintText: 'Enter your full name',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Full name is required';
                              }
                              return null;
                            },
                            prefixIcon: Icon(Icons.person, color: _lightColor),
                          ),

                          _buildInputField(
                            label: 'Email Address *',
                            controller: _emailController,
                            hintText: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                            prefixIcon: Icon(Icons.email, color: _lightColor),
                          ),

                          _buildInputField(
                            label: 'Phone Number *',
                            controller: _phoneController,
                            hintText: 'Enter your phone number',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone number is required';
                              }
                              if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                return 'Enter a valid 10-digit number';
                              }
                              return null;
                            },
                            prefixIcon: Icon(Icons.phone, color: _lightColor),
                          ),

                          _buildInputField(
                            label: 'Age *',
                            controller: _ageController,
                            hintText: 'Enter your age',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Age is required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                            prefixIcon: Icon(Icons.calendar_today, color: _lightColor),
                          ),

                          // Location Details
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Location Information',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _buildInputField(
                            label: 'Place *',
                            controller: _placeController,
                            hintText: 'Enter your city/town',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Place is required';
                              }
                              return null;
                            },
                            prefixIcon: Icon(Icons.location_city, color: _lightColor),
                          ),

                          _buildInputField(
                            label: 'Nationality *',
                            controller: _nationalityController,
                            hintText: 'Enter your nationality',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nationality is required';
                              }
                              return null;
                            },
                            prefixIcon: Icon(Icons.flag, color: _lightColor),
                          ),

                          // Account Credentials
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(Icons.lock_outline, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Account Credentials',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _buildInputField(
                            label: 'Username *',
                            controller: _usernameController,
                            hintText: 'Choose a username',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Username is required';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                            prefixIcon: Icon(Icons.person_pin, color: _lightColor),
                          ),

                          _buildInputField(
                            label: 'Password *',
                            controller: _passwordController,
                            hintText: 'Create a strong password',
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            prefixIcon: Icon(Icons.lock, color: _lightColor),
                          ),

                          _buildInputField(
                            label: 'Confirm Password *',
                            controller: _confirmPasswordController,
                            hintText: 'Re-enter your password',
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please confirm your password';
                              }
                              return null;
                            },
                            prefixIcon: Icon(Icons.lock_outline, color: _lightColor),
                          ),

                          // Terms and Conditions
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _darkColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: _lightColor, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'By registering, you agree to our Terms of Service and Privacy Policy',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _lightColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: _isLoading
                                ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFEB1616),
                              ),
                            )
                                : ElevatedButton(
                              onPressed: _sendData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'CREATE ACCOUNT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Already have account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(color: _lightColor),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const AppLogin12()),
                                  );
                                },
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
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
                        'FINSIGHT Investor Platform',
                        style: TextStyle(
                          fontSize: 12,
                          color: _lightColor.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Secure • Private • Professional',
                        style: TextStyle(
                          fontSize: 10,
                          color: _lightColor.withOpacity(0.4),
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _placeController.dispose();
    _ageController.dispose();
    _nationalityController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}