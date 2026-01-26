import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FINSIGHT',
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
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF6C7293), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
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
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEB1616),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
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
      home: const MyHomePage(title: 'FINSIGHT Setup'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF191C24),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20, // Reduced font size
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF000000),
                  Color(0xFF191C24),
                ],
                stops: [0.0, 1.0],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Logo/Title Section
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
                            child: Icon(
                              Icons.analytics_outlined,
                              size: isSmallScreen ? 60 : 80,
                              color: const Color(0xFFEB1616),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'FINSIGHT',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 32 : 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Financial Intelligence Platform',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: const Color(0xFF6C7293),
                            ),
                              textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 32 : 48),

                      // Setup Card
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.settings,
                                  color: const Color(0xFFEB1616),
                                  size: isSmallScreen ? 20 : 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Server Configuration',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 18 : 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Text(
                              'Enter Server IP Address',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 15 : 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Enter the IP address where your FINSIGHT server is running',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                                color: const Color(0xFF6C7293),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _textController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Server IP Address',
                                      labelStyle: TextStyle(
                                        color: const Color(0xFF6C7293),
                                        fontSize: isSmallScreen ? 15 : 16,
                                      ),
                                      hintText: '192.168.1.100',
                                      hintStyle: TextStyle(
                                        color: const Color(0xFF6C7293),
                                        fontSize: isSmallScreen ? 13 : 14,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.dns_outlined,
                                        color: Color(0xFFEB1616),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFF000000),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF6C7293),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEB1616),
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 1,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter IP address';
                                      }
                                      // Basic IP validation
                                      final ipRegex = RegExp(
                                          r'^(\d{1,3}\.){3}\d{1,3}$'
                                      );
                                      if (!ipRegex.hasMatch(value)) {
                                        return 'Please enter a valid IP address';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                  ),

                                  const SizedBox(height: 20),

                                  // Example IP Hint
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF000000),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF6C7293).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: const Color(0xFFEB1616),
                                          size: isSmallScreen ? 16 : 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Example: 192.168.1.100',
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 12 : 13,
                                              color: const Color(0xFF6C7293).withOpacity(0.8),
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
                                    child: ElevatedButton(
                                      onPressed: _sendData,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFEB1616),
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmallScreen ? 20 : 32,
                                          vertical: isSmallScreen ? 16 : 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 3,
                                        shadowColor: const Color(0xFFEB1616).withOpacity(0.4),
                                      ),
                                      child: isSmallScreen
                                          ? const Text(
                                        'CONNECT',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                          : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'CONNECT TO SERVER',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Footer
                      Column(
                        children: [
                          const Text(
                            'FINSIGHT © 2025',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6C7293),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 10,
                              color: const Color(0xFF6C7293).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _sendData() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF191C24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Container(
            padding: const EdgeInsets.all(20),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEB1616)),
                ),
                SizedBox(height: 20),
                Text(
                  'Connecting to Server...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Save IP to shared preferences
      SharedPreferences sh = await SharedPreferences.getInstance();
      await sh.setString('url', 'http://${_textController.text}:8000/myapp');
      await sh.setString('img_url', 'http://${_textController.text}:8000');

      // Hide loading indicator
      if (mounted) {
        Navigator.pop(context);
      }

      // Navigate to login page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AppLogin12(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}