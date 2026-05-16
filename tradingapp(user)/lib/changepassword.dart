import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tradingapp/home.dart';

void main() {
  runApp(const ChangePswd());
}

class ChangePswd extends StatelessWidget {
  const ChangePswd({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: changepswd(title: 'Change Password'),
    );
  }
}

class changepswd extends StatefulWidget {
  const changepswd({super.key, required this.title});

  final String title;

  @override
  State<changepswd> createState() => _changepswdState();
}

class _changepswdState extends State<changepswd> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentpswdtextController = TextEditingController();
  final TextEditingController _newpswdtextController = TextEditingController();
  final TextEditingController _confirmpswdtextController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isNPasswordVisible = false;
  bool _isButtonEnabled = false;
  String _passwordMatchMessage = '';
  Color _passwordMatchColor = Colors.grey;
  String _passwordStrengthMessage = '';
  Color _passwordStrengthColor = Colors.grey;
  List<bool> _passwordRequirements = [false, false, false, false]; // 8 chars, 1 uppercase, 3 numbers, not same as current

  @override
  void initState() {
    super.initState();
    _newpswdtextController.addListener(_validateNewPassword);
    _newpswdtextController.addListener(_validatePasswords);
    _confirmpswdtextController.addListener(_validatePasswords);
    _currentpswdtextController.addListener(_validateCurrentPassword);
  }

  @override
  void dispose() {
    _newpswdtextController.removeListener(_validateNewPassword);
    _newpswdtextController.removeListener(_validatePasswords);
    _confirmpswdtextController.removeListener(_validatePasswords);
    _currentpswdtextController.removeListener(_validateCurrentPassword);
    _currentpswdtextController.dispose();
    _newpswdtextController.dispose();
    _confirmpswdtextController.dispose();
    super.dispose();
  }

  void _validateNewPassword() {
    final newPassword = _newpswdtextController.text;
    final currentPassword = _currentpswdtextController.text;

    // Check password requirements
    bool has8Chars = newPassword.length >= 8;
    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(newPassword);
    bool has3Numbers = (RegExp(r'[0-9]').allMatches(newPassword).length >= 3);
    bool notSameAsCurrent = newPassword.isNotEmpty &&
        currentPassword.isNotEmpty &&
        newPassword != currentPassword;

    setState(() {
      _passwordRequirements[0] = has8Chars;
      _passwordRequirements[1] = hasUppercase;
      _passwordRequirements[2] = has3Numbers;
      _passwordRequirements[3] = notSameAsCurrent;

      // Update strength message
      if (newPassword.isEmpty) {
        _passwordStrengthMessage = '';
        _passwordStrengthColor = Colors.grey;
      } else {
        int metRequirements = _passwordRequirements.where((req) => req).length;
        if (metRequirements == 4) {
          _passwordStrengthMessage = 'Strong password';
          _passwordStrengthColor = Colors.green;
        } else if (metRequirements >= 2) {
          _passwordStrengthMessage = 'Medium strength';
          _passwordStrengthColor = Colors.orange;
        } else {
          _passwordStrengthMessage = 'Weak password';
          _passwordStrengthColor = Colors.red;
        }
      }

      _validatePasswords();
    });
  }

  void _validatePasswords() {
    final newPassword = _newpswdtextController.text;
    final confirmPassword = _confirmpswdtextController.text;

    // Check if passwords match and all requirements are met
    bool passwordsMatch = newPassword.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        newPassword == confirmPassword;
    bool allRequirementsMet = _passwordRequirements.every((req) => req);

    setState(() {
      if (newPassword.isEmpty || confirmPassword.isEmpty) {
        _passwordMatchMessage = '';
        _passwordMatchColor = Colors.grey;
        _isButtonEnabled = false;
      } else if (passwordsMatch && allRequirementsMet) {
        _passwordMatchMessage = '✓ Passwords match and meet all requirements';
        _passwordMatchColor = Colors.green;
        _isButtonEnabled = true;
      } else if (passwordsMatch && !allRequirementsMet) {
        _passwordMatchMessage = '✓ Passwords match but requirements not met';
        _passwordMatchColor = Colors.orange;
        _isButtonEnabled = false;
      } else {
        _passwordMatchMessage = '✗ Passwords do not match';
        _passwordMatchColor = Colors.red;
        _isButtonEnabled = false;
      }

      // Final check to enable button
      _isButtonEnabled = passwordsMatch &&
          allRequirementsMet &&
          _currentpswdtextController.text.isNotEmpty;
    });
  }

  void _validateCurrentPassword() {
    final currentPassword = _currentpswdtextController.text;
    final newPassword = _newpswdtextController.text;

    setState(() {
      if (currentPassword.isNotEmpty && newPassword.isNotEmpty && currentPassword == newPassword) {
        _passwordRequirements[3] = false;
        _validateNewPassword();
      } else {
        _passwordRequirements[3] = true;
        _validateNewPassword();
      }
    });
  }

  Future<void> _sendData() async {
    String cpswd = _currentpswdtextController.text;
    String npswd = _newpswdtextController.text;
    String cmpswd = _confirmpswdtextController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? uid = sh.getString('uid');

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/user_changepassword/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['cpswd'] = cpswd;
    request.fields['npswd'] = npswd;
    request.fields['cmpswd'] = cmpswd;
    request.fields['uid'] = uid!;

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "✅ Password changed successfully!");
        _currentpswdtextController.clear();
        _newpswdtextController.clear();
        _confirmpswdtextController.clear();
        setState(() {
          _isButtonEnabled = false;
          _passwordMatchMessage = '';
          _passwordStrengthMessage = '';
          _passwordRequirements = [false, false, false, false];
        });
      } else {
        Fluttertoast.showToast(msg: "Password change failed. Please check your current password.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Connection error. Please try again.");
    }
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isMet ? Colors.green : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(title: '')),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Custom Header
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF5669F6),
                    const Color(0xFF5CF7FF),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5669F6).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => HomePage(title: '')),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      "Secure your account with a strong password",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Password Form
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Current Password Field
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Current Password",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.grey.shade50,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                obscureText: !_isPasswordVisible,
                                controller: _currentpswdtextController,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter current password...",
                                  hintStyle: TextStyle(color: Colors.grey.shade500),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.only(left: 12, right: 12),
                                    child: Icon(
                                      Icons.lock_outline_rounded,
                                      color: const Color(0xFF5669F6),
                                    ),
                                  ),
                                  suffixIcon: _currentpswdtextController.text.isNotEmpty
                                      ? IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                      color: Colors.grey.shade500,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  )
                                      : null,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Current password is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // New Password Field
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "New Password",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.grey.shade50,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                obscureText: !_isNPasswordVisible,
                                controller: _newpswdtextController,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Create new password...",
                                  hintStyle: TextStyle(color: Colors.grey.shade500),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.only(left: 12, right: 12),
                                    child: Icon(
                                      Icons.lock_reset_rounded,
                                      color: const Color(0xFF5669F6),
                                    ),
                                  ),
                                  suffixIcon: _newpswdtextController.text.isNotEmpty
                                      ? IconButton(
                                    icon: Icon(
                                      _isNPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                      color: Colors.grey.shade500,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isNPasswordVisible = !_isNPasswordVisible;
                                      });
                                    },
                                  )
                                      : null,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'New password is required';
                                  }
                                  if (value == _currentpswdtextController.text) {
                                    return 'New password cannot be the same as current';
                                  }
                                  if (value.length < 8) {
                                    return 'Must be at least 8 characters';
                                  }
                                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                    return 'Must contain at least one uppercase letter';
                                  }
                                  if (RegExp(r'[0-9]').allMatches(value).length < 3) {
                                    return 'Must contain at least 3 numbers';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Password Requirements
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF5669F6).withOpacity(0.08),
                              const Color(0xFF5CF7FF).withOpacity(0.04),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Password Requirements:",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildPasswordRequirement("At least 8 characters long", _passwordRequirements[0]),
                            _buildPasswordRequirement("At least one uppercase letter (A-Z)", _passwordRequirements[1]),
                            _buildPasswordRequirement("At least 3 numbers (0-9)", _passwordRequirements[2]),
                            _buildPasswordRequirement("Different from current password", _passwordRequirements[3]),

                            if (_passwordStrengthMessage.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                _passwordStrengthMessage,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _passwordStrengthColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Confirm Password Field
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Confirm New Password",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.grey.shade50,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                obscureText: true,
                                controller: _confirmpswdtextController,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Re-enter new password...",
                                  hintStyle: TextStyle(color: Colors.grey.shade500),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.only(left: 12, right: 12),
                                    child: Icon(
                                      Icons.lock_clock_rounded,
                                      color: const Color(0xFF5669F6),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _newpswdtextController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Password Match Message
                      if (_passwordMatchMessage.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _passwordMatchColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _passwordMatchColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _passwordMatchColor == Colors.green ? Icons.check_circle_rounded :
                                _passwordMatchColor == Colors.orange ? Icons.warning_amber_rounded :
                                Icons.error_outline_rounded,
                                color: _passwordMatchColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _passwordMatchMessage,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _passwordMatchColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Submit Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: _isButtonEnabled
                                ? [
                              const Color(0xFF5669F6),
                              const Color(0xFF5CF7FF),
                            ]
                                : [
                              Colors.grey.shade400,
                              Colors.grey.shade300,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _isButtonEnabled
                                  ? const Color(0xFF5669F6).withOpacity(0.4)
                                  : Colors.grey.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _isButtonEnabled
                                ? () {
                              if (_formKey.currentState!.validate()) {
                                _sendData();
                              }
                            }
                                : null,
                            child: Center(
                              child: Text(
                                "Change Password",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
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
}