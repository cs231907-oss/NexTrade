import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tradingapp/forgotpassword.dart';
import 'package:tradingapp/home.dart';
import 'package:tradingapp/signup.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(Ulgoginpage());
}

class Ulgoginpage extends StatelessWidget {
  const Ulgoginpage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserLogin(title: ''),
    );
  }
}

class UserLogin extends StatefulWidget {
  const UserLogin({super.key, required this.title});

  final String title;

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernametextController = TextEditingController();
  final TextEditingController _passwordtextController = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  DateTime? lastBackPressed;
  bool _isPasswordVisible = false;

  // Error handling variables
  String _errorMessage = '';
  bool _hasError = false;
  bool _isLoading = false;

  void _sendData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    String uname = _usernametextController.text;
    String upassword = _passwordtextController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();

    final urls = Uri.parse('$url/ulogin/');
    try {
      final response = await http.post(urls, body: {
        'uname': uname,
        'upassword': upassword,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String status = data['status'];

        if (status == 'ok') {
          String uid = data['uid'].toString();
          SharedPreferences sh = await SharedPreferences.getInstance();
          sh.setString("uid", uid);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyApphome()),
          );
        } else {
          setState(() {
            _hasError = true;
            _errorMessage = 'Invalid User ID or Password!';
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
    _usernameFocus.dispose();
    _passwordFocus.dispose();
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
            // Enhanced Background with gradient overlay
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5669F6),
                    Color(0xFF5CF7FF),
                  ],
                ),
              ),
            ),

            // Floating abstract shapes for depth
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),

            // Content
            SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Logo and Welcome Text
                      SizedBox(height: 60),
                      _buildHeader(),
                      SizedBox(height: 40),

                      // Enhanced Login Form Card
                      _buildLoginForm(),

                      SizedBox(height: 30),

                      // Branding Footer
                      _buildFooter(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated Logo Container
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.05),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.account_circle_rounded,
              size: 60,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.2),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 25),
        // App Name with gradient text
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Colors.white, Color(0xFFC9F0FF)],
              stops: [0.3, 1.0],
            ).createShader(bounds);
          },
          child: Text(
            'NexTrade',
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Beginner's Trading Platform",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 30),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 2,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? ColorFilter.mode(Colors.white.withOpacity(0.95), BlendMode.srcOver)
              : ColorFilter.mode(Colors.white, BlendMode.srcOver),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Title
                  Row(
                    children: [
                      Icon(
                        Icons.login_rounded,
                        color: Color(0xFF5669F6),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Account Login',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Enter your credentials to continue',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 28),

                  // Error Message
                  if (_hasError) _buildErrorMessage(),

                  // Username Field
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.grey[50]!,
                          Colors.grey[100]!,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _usernametextController,
                      focusNode: _usernameFocus,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email or User ID',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        prefixIcon: Container(
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 16, right: 12),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF5669F6),
                              size: 22,
                            ),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      onChanged: (_) => _clearError(),
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_passwordFocus),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your user ID';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Password Field
                  Container(
                    margin: EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.grey[50]!,
                          Colors.grey[100]!,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      obscureText: !_isPasswordVisible,
                      controller: _passwordtextController,
                      focusNode: _passwordFocus,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        prefixIcon: Container(
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 16, right: 12),
                            child: Icon(
                              Icons.lock_outline_rounded,
                              color: Color(0xFF5669F6),
                              size: 22,
                            ),
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: Colors.grey[600],
                              size: 22,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      onChanged: (_) => _clearError(),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) {
                        if (_formKey.currentState!.validate()) {
                          _sendData();
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPaswd(title: ''),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_reset_rounded,
                            size: 16,
                            color: Color(0xFF5669F6),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5669F6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Login Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF5669F6),
                          Color(0xFF5CF7FF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF5669F6).withOpacity(0.4),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          _sendData();
                        } else {
                          setState(() {
                            _hasError = true;
                            _errorMessage = 'Please fill all required fields correctly';
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isLoading)
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Icon(Icons.arrow_forward_rounded, size: 22),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 28),

                  // Divider with "or"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "New to NexTrade? ",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color(0xFF5669F6),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Create Account',
                                style: TextStyle(
                                  color: Color(0xFF5669F6),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: Color(0xFF5669F6),
                              ),
                            ],
                          ),
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

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.red[50]!,
            Colors.red[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red[100],
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: Colors.red[700],
              size: 22,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Authentication Error',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 18, color: Colors.red[600]),
            onPressed: _clearError,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          '© 2025 NexTrade. All rights reserved',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}