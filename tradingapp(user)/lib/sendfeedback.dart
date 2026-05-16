import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tradingapp/home.dart';

void main() {
  runApp(SSFeedback());
}

class SSFeedback extends StatelessWidget {
  const SSFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SFeedback(title: 'Feedback'),
    );
  }
}

class SFeedback extends StatefulWidget {
  const SFeedback({super.key, required this.title});

  final String title;

  @override
  State<SFeedback> createState() => _SFeedbackState();
}

class _SFeedbackState extends State<SFeedback> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _SFeedbacktextController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendData() async {
    if (_isLoading) return;

    String uSFeedback = _SFeedbacktextController.text.trim();

    if (uSFeedback.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your feedback");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String uid = sh.getString('uid').toString();

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final uri = Uri.parse('$url/user_sendfeedback/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['uid'] = uid;
    request.fields['feedback'] = uSFeedback;

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "✅ Feedback submitted successfully!");
        _SFeedbacktextController.clear();
      } else {
        Fluttertoast.showToast(msg: "Submission failed. Please try again.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Connection error. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                        const SizedBox(width: 40), // For alignment balance
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
                      Icons.feedback_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      "Share your thoughts and help us improve",
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

            // Feedback Form
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Feedback Header
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF5669F6).withOpacity(0.1),
                              const Color(0xFF5CF7FF).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF5669F6),
                                    Color(0xFF5CF7FF),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit_note_rounded,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                "Your feedback helps us provide better service",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Feedback Input Field
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Your Feedback",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
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
                                controller: _SFeedbacktextController,
                                maxLines: 6,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Type your feedback here...",
                                  hintStyle: TextStyle(color: Colors.grey.shade500),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(20),
                                  suffixIcon: _SFeedbacktextController.text.isNotEmpty
                                      ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: Colors.grey.shade500,
                                    ),
                                    onPressed: () => _SFeedbacktextController.clear(),
                                  )
                                      : null,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Feedback is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Character Count
                      Container(
                        margin: const EdgeInsets.only(bottom: 32),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Be specific and constructive for better understanding",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
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
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF5669F6),
                              Color(0xFF5CF7FF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5669F6).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _isLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                _sendData();
                              } else {
                                Fluttertoast.showToast(msg: "Please enter your feedback");
                              }
                            },
                            child: Center(
                              child: _isLoading
                                  ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.send_rounded,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Send Feedback",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
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