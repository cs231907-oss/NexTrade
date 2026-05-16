import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tradingapp/home.dart';
import 'package:tradingapp/viewprofile.dart';

void main() {
  runApp(Editprofile());
}

class Editprofile extends StatelessWidget {
  const Editprofile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: editProfile(title: 'Edit Your Profile'),
    );
  }
}

class editProfile extends StatefulWidget {
  const editProfile({super.key, required this.title});

  final String title;

  @override
  State<editProfile> createState() => _editProfileState();
}

class _editProfileState extends State<editProfile> {
  _editProfileState() {
    getdata();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nametextController = TextEditingController();
  final TextEditingController _emailtextController = TextEditingController();
  final TextEditingController _phonenotextController = TextEditingController();
  final TextEditingController _districttextController = TextEditingController();
  final TextEditingController _statetextController = TextEditingController();
  final TextEditingController _pintextController = TextEditingController();

  File? _selectedImage;
  Future<void> _chooseImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      Fluttertoast.showToast(msg: "No image selected");
    }
  }

  String photo_ = "";
  bool _isLoading = false;

  void getdata() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String uid = sh.getString('uid').toString();
    String img_url = sh.getString('img_url').toString();

    final urls = Uri.parse('$url/user_viewprofile/');
    try {
      final response = await http.post(urls, body: {
        'uid': uid
      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          String name = jsonDecode(response.body)['name'].toString();
          String email = jsonDecode(response.body)['email'].toString();
          String phone = jsonDecode(response.body)['phone'].toString();
          String state = jsonDecode(response.body)['state'].toString();
          String district = jsonDecode(response.body)['district'].toString();
          String pin = jsonDecode(response.body)['pin'].toString();
          String photo = img_url + jsonDecode(response.body)['photo'].toString();

          setState(() {
            _nametextController.text = name;
            _emailtextController.text = email;
            _phonenotextController.text = phone;
            _statetextController.text = state;
            _districttextController.text = district;
            _pintextController.text = pin;
            photo_ = photo;
          });
        } else {
          Fluttertoast.showToast(msg: 'Not Found');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> _sendData() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: "Please fix errors in the form");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String uname = _nametextController.text;
    String uemail = _emailtextController.text;
    String uphone = _phonenotextController.text;
    String udistrict = _districttextController.text;
    String ustate = _statetextController.text;
    String upin = _pintextController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String id = sh.getString('uid').toString();

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final uri = Uri.parse('$url/user_editprofile/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['uid'] = id;
    request.fields['uname'] = uname;
    request.fields['uemail'] = uemail;
    request.fields['uphoneno'] = uphone;
    request.fields['udistrict'] = udistrict;
    request.fields['ustate'] = ustate;
    request.fields['upin'] = upin;

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "✅ Profile updated successfully!");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewProfile(title: '')),
        );
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

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String hintText = '',
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
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
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              validator: validator,
              decoration: InputDecoration(
                hintText: hintText.isEmpty ? "Enter ${label.toLowerCase()}..." : hintText,
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.only(left: 12, right: 12),
                  child: Icon(
                    icon,
                    color: const Color(0xFF5669F6),
                  ),
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: Colors.grey.shade500),
                  onPressed: () => controller.clear(),
                )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: _selectedImage != null
                    ? Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                )
                    : photo_.isNotEmpty
                    ? Image.network(
                  photo_,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF5669F6)),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF5669F6),
                            const Color(0xFF5CF7FF),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    );
                  },
                )
                    : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF5669F6),
                        const Color(0xFF5CF7FF),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              width: 36,
              height: 36,
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
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5669F6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _chooseImage,
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFF5669F6).withOpacity(0.1),
                const Color(0xFF5CF7FF).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "Tap camera icon to change photo",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ViewProfile(title: '')),
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
                                MaterialPageRoute(builder: (context) => ViewProfile(title: '')),
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
                  _buildProfileImage(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      "Update your profile information",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Edit Form
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name Field
                      _buildInputField(
                        label: "Full Name",
                        icon: Icons.person_outline_rounded,
                        controller: _nametextController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                        hintText: "Enter your name...",
                      ),

                      // Email Field
                      _buildInputField(
                        label: "Email Address",
                        icon: Icons.email_outlined,
                        controller: _emailtextController,
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
                        hintText: "Enter your email...",
                      ),

                      // Phone Field
                      _buildInputField(
                        label: "Phone Number",
                        icon: Icons.phone_android_outlined,
                        controller: _phonenotextController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                            return 'Enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                        hintText: "Enter your phone number...",
                      ),

                      // District Field
                      _buildInputField(
                        label: "District",
                        icon: Icons.location_city_outlined,
                        controller: _districttextController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'District is required';
                          }
                          return null;
                        },
                        hintText: "Enter your district...",
                      ),

                      // State Field
                      _buildInputField(
                        label: "State",
                        icon: Icons.apartment_outlined,
                        controller: _statetextController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'State is required';
                          }
                          return null;
                        },
                        hintText: "Enter your state...",
                      ),

                      // PIN Code Field
                      _buildInputField(
                        label: "PIN Code",
                        icon: Icons.location_on_outlined,
                        controller: _pintextController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'PIN code is required';
                          }
                          if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                            return 'Enter a valid 6-digit PIN code';
                          }
                          return null;
                        },
                        hintText: "Enter your PIN code...",
                      ),

                      // Info Card
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
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
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                "Update your profile information to keep it current and accurate",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Update Button
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
                            onTap: _isLoading ? null : _sendData,
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
                                    Icons.save_rounded,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Update Profile",
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