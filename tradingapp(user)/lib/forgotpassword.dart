import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

void main() {
  runApp(forgotpswdPage());
}

class forgotpswdPage extends StatelessWidget {
  const forgotpswdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ForgotPaswd(title: ''),
    );
  }
}

class ForgotPaswd extends StatefulWidget {
  const ForgotPaswd({super.key, required this.title});

  final String title;

  @override
  State<ForgotPaswd> createState() => _ForgotPaswdState();
}

class _ForgotPaswdState extends State<ForgotPaswd> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  DateTime? lastBackPressed;

  // Error handling variables
  String _errorMessage = '';
  bool _hasError = false;
  bool _isLoading = false;
  bool _isSuccess = false;

  void _sendResetRequest() async {
    if (_isLoading) return; // Prevent multiple clicks

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _isSuccess = false;
    });

    String email = _emailController.text.trim();

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();

    final urls = Uri.parse('$url/android_forget_password_post/');
    try {
      final response = await http.post(urls, body: {
        'email': email,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String status = data['status'];

        if (status == 'ok') {
          setState(() {
            _isSuccess = true;
            _errorMessage = 'Password reset link sent to your email!';
          });

          // Clear form on success
          _emailController.clear();
        } else {
          setState(() {
            _hasError = true;
            _errorMessage = data['message'] ?? 'Email not found!';
          });
        }
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Network Error - Please try again';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Connection failed. Check your internet.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearError() {
    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });
    }
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();

        if (lastBackPressed == null ||
            now.difference(lastBackPressed!) > Duration(seconds: 2)) {
          lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Double tap back to exit",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 40, left: 16, right: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
          );
          return true;
        }

        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Background Design Elements
            _buildBackgroundDesign(),

            // Main Content
            SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button and Header
                      _buildHeader(context),

                      const SizedBox(height: 40),

                      // Form Card
                      _buildFormCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDesign() {
    return Column(
      children: [
        // Top Gradient Section
        Container(
          height: MediaQuery.of(context).size.height * 0.35,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF5669F6),
                Color(0xFF5CF7FF),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        Expanded(child: Container(color: Colors.white)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Button
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Title Section
        Text(
          'Reset Your\nPassword',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Enter your email to receive reset instructions',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Success/Error Message
              if (_hasError || _isSuccess) _buildStatusMessage(),

              const SizedBox(height: 24),

              // Email Field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.email_outlined,
                        color: Colors.grey[600]),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    hintText: 'your@email.com',
                  ),
                  onChanged: (_) => _clearError(),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (value) {
                    if (_formKey.currentState!.validate()) {
                      _sendResetRequest();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email address is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    if (_formKey.currentState!.validate()) {
                      _sendResetRequest();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5669F6),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Color(0xFF5669F6).withOpacity(0.3),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Send Reset Link",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Additional Help Text
              Text(
                'We will send password reset instructions to your email address',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 16),

              // Back to Login
              TextButton(
                onPressed: _isLoading ? null : () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Back to Login',
                  style: TextStyle(
                    color: Color(0xFF5669F6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isSuccess ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSuccess ? Colors.green[100]! : Colors.red[100]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isSuccess ? Icons.check_circle_outline : Icons.error_outline_rounded,
            color: _isSuccess ? Colors.green : Colors.red,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(
                color: _isSuccess ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}