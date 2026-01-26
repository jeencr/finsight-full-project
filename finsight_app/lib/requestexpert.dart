import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RequestExpertPage extends StatefulWidget {
  const RequestExpertPage({super.key});

  @override
  State<RequestExpertPage> createState() => _RequestExpertPageState();
}

class _RequestExpertPageState extends State<RequestExpertPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<dynamic> _experts = [];
  bool _isLoading = true;
  String? _selectedExpertId;
  Map<String, dynamic>? _selectedExpert;

  // FINSIGHT Colors
  final Color _primaryColor = const Color(0xFFEB1616);
  final Color _secondaryColor = const Color(0xFF191C24);
  final Color _darkColor = const Color(0xFF000000);
  final Color _lightColor = const Color(0xFF6C7293);
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadExperts();
    _loadImageUrl();
  }

  Future<void> _loadImageUrl() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    setState(() {
      _imageUrl = sh.getString('img_url');
    });
  }

  Future<void> _loadExperts() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    if (url == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse('$url/send_data_request_expert/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _experts = data['expert'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading experts: $e');
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedExpertId == null) {
      _showSnackBar('Please select an expert', isError: true);
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    int? lid = sh.getInt('lid');
    String? url = sh.getString('url');

    if (lid == null || url == null) {
      _showSnackBar('User session expired. Please login again.', isError: true);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$url/request_expert_user/'),
        body: {
          'expert_id': _selectedExpertId!,
          'lid': lid.toString(),
          'occupation': _occupationController.text,
          'income': _incomeController.text,
          'amount': _amountController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _showSnackBar('Expert request submitted successfully!', isError: false);

          // Clear form
          _amountController.clear();
          _incomeController.clear();
          _occupationController.clear();
          setState(() {
            _selectedExpertId = null;
            _selectedExpert = null;
          });

          // Navigate back after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else {
          _showSnackBar('Failed to submit request. Please try again.', isError: true);
        }
      } else {
        _showSnackBar('Server error. Please try again.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Connection error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _primaryColor : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildExpertCard(Map<String, dynamic> expert) {
    bool isSelected = _selectedExpertId == expert['id']?.toString();

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedExpertId = expert['id']?.toString();
          _selectedExpert = expert;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.1) : _secondaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryColor : _lightColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Expert Photo
              if (expert['photo'] != null && _imageUrl != null)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                      image: NetworkImage('$_imageUrl/media/${expert['photo']}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(Icons.person, color: _lightColor, size: 30),
                ),

              const SizedBox(width: 16),

              // Expert Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expert['name'] ?? 'Unknown Expert',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expert['specilization'] ?? 'No Specialization',
                      style: TextStyle(
                        color: _lightColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email, color: _lightColor, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            expert['email'] ?? 'No Email',
                            style: TextStyle(
                              color: _lightColor,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, color: _lightColor, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          expert['phone'] ?? 'No Phone',
                          style: TextStyle(
                            color: _lightColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Selection Indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    IconData? prefixIcon,
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
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: _lightColor) : null,
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
    return Scaffold(
      backgroundColor: _darkColor,
      appBar: AppBar(
        backgroundColor: _secondaryColor,
        elevation: 0,
        title: const Text(
          'Request Expert Assistance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryColor.withOpacity(0.1), _primaryColor.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.contact_support, color: _primaryColor, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Connect with Experts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select an expert and provide your details for personalized financial guidance',
                            style: TextStyle(
                              color: _lightColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Select Expert Section
              const Text(
                'Select Financial Expert',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFFEB1616)),
                )
              else if (_experts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.person_off, color: _lightColor, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'No Experts Available',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Currently no experts are available. Please check back later.',
                        style: TextStyle(
                          color: _lightColor,
                          fontSize: 13,
                        ),
                          textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _experts.map((expert) => _buildExpertCard(expert)).toList(),
                ),

              const SizedBox(height: 24),

              // Form Section
              const Text(
                'Your Financial Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInputField(
                        label: 'Investment Amount (₹) *',
                        controller: _amountController,
                        hintText: 'e.g., 50000',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter investment amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        prefixIcon: Icons.attach_money,
                      ),

                      _buildInputField(
                        label: 'Monthly Income (₹) *',
                        controller: _incomeController,
                        hintText: 'e.g., 75000',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter monthly income';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        prefixIcon: Icons.account_balance_wallet,
                      ),

                      _buildInputField(
                        label: 'Occupation *',
                        controller: _occupationController,
                        hintText: 'e.g., Software Engineer, Business Owner',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your occupation';
                          }
                          return null;
                        },
                        prefixIcon: Icons.work,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Selected Expert Preview
              if (_selectedExpert != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Expert:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (_selectedExpert!['photo'] != null && _imageUrl != null)
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage('$_imageUrl/media/${_selectedExpert!['photo']}'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(Icons.person, color: _lightColor, size: 20),
                            ),

                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedExpert!['name'] ?? 'Unknown Expert',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _selectedExpert!['specilization'] ?? 'No Specialization',
                                  style: TextStyle(
                                    color: _lightColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedExpertId = null;
                                _selectedExpert = null;
                              });
                            },
                            icon: Icon(Icons.close, color: _primaryColor, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'SUBMIT REQUEST',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _darkColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _lightColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: _lightColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Our experts will review your request and contact you within 24-48 hours.',
                        style: TextStyle(
                          color: _lightColor,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _incomeController.dispose();
    _occupationController.dispose();
    super.dispose();
  }
}