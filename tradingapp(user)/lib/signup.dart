import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tradingapp/ulogin.dart';

void main() {
  runApp(SignupPage());
}

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignupPageContent(title: ''),
    );
  }
}

class SignupPageContent extends StatefulWidget {
  const SignupPageContent({super.key, required this.title});

  final String title;

  @override
  State<SignupPageContent> createState() => _SignupPageContentState();
}

class _SignupPageContentState extends State<SignupPageContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nametextController = TextEditingController();
  final TextEditingController _emailtextController = TextEditingController();
  final TextEditingController _phonenotextController = TextEditingController();
  final TextEditingController _upintextController = TextEditingController();
  final TextEditingController _passwordtextController = TextEditingController();
  final TextEditingController _confirmPasswordtextController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _pinFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  // Image selection
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
  String _passwordMatchMessage = '';
  Color _passwordMatchColor = Colors.grey;
  bool _passwordsMatch=false;

  bool _isPasswordVisible = false;

  // For dropdown state and district data
  String? _selectedState;
  String? _selectedDistrict;

  final Map<String, List<String>> stateAndDistricts = {
    'Select Your State': ['Select Your District'],
    'Kerala': [
      'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha', 'Kottayam',
      'Idukki', 'Ernakulam', 'Thrissur', 'Palakkad', 'Malappuram',
      'Kozhikode', 'Wayanad', 'Kannur', 'Kasaragod'
    ],
    'Tamil Nadu': [
      'Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem',
      'Tirunelveli', 'Vellore', 'Erode', 'Thoothukudi', 'Dindigul',
      'Thanjavur', 'Ranipet', 'Kanchipuram', 'Kanyakumari', 'Karur',
      'Krishnagiri', 'Namakkal', 'Perambalur', 'Pudukkottai', 'Ramanathapuram',
      'Sivaganga', 'Theni', 'Tirupathur', 'Tiruppur', 'Tiruvallur',
      'Tiruvannamalai', 'Viluppuram', 'Virudhunagar'
    ],
    'Karnataka': [
      'Bengaluru Urban', 'Bengaluru Rural', 'Mysuru', 'Hubballi', 'Belagavi',
      'Mangaluru', 'Dharwad', 'Ballari', 'Vijayapura', 'Shivamogga',
      'Tumakuru', 'Kalaburagi', 'Udupi', 'Dakshina Kannada', 'Raichur',
      'Bidar', 'Hassan', 'Mandya', 'Chitradurga', 'Kolar',
      'Gadag', 'Bagalkot', 'Koppal', 'Uttara Kannada', 'Ramanagara'
    ],
    'Maharashtra': [
      'Mumbai', 'Pune', 'Nagpur', 'Thane', 'Nashik',
      'Aurangabad', 'Solapur', 'Kolhapur', 'Amravati', 'Nanded',
      'Sangli', 'Jalgaon', 'Akola', 'Latur', 'Dhule',
      'Ahmednagar', 'Chandrapur', 'Parbhani', 'Jalna', 'Buldhana'
    ],
    'Delhi': [
      'Central Delhi', 'East Delhi', 'New Delhi', 'North Delhi',
      'North East Delhi', 'North West Delhi', 'Shahdara',
      'South Delhi', 'South East Delhi', 'South West Delhi',
      'West Delhi'
    ],
  };

  List<String> getStateList() {
    return stateAndDistricts.keys.toList();
  }

  List<String> getDistrictList(String? state) {
    return stateAndDistricts[state] ?? [];
  }

  void _onStateChanged(String? newState) {
    setState(() {
      _selectedState = newState;
      _selectedDistrict = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedState = 'Select Your State';
  }

  Future<void> _sendData() async {
    if (_passwordtextController.text != _confirmPasswordtextController.text) {
      Fluttertoast.showToast(msg: "Passwords don't match");
      return;
    }

    String uname = _nametextController.text;
    String uemail = _emailtextController.text;
    String uphone = _phonenotextController.text;
    String upin = _upintextController.text;
    String upassword = _passwordtextController.text;
    String ucpassword = _confirmPasswordtextController.text;
    String ustate = _selectedState ?? '';
    String udistrict = _selectedDistrict ?? '';

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/usignup/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['uname'] = uname;
    request.fields['uemail'] = uemail;
    request.fields['uphoneno'] = uphone;
    request.fields['upassword'] = upassword;
    request.fields['ucpassword'] = ucpassword;
    request.fields['ustate'] = ustate;
    request.fields['udistrict'] = udistrict;
    request.fields['upin'] = upin;

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Registration successful!");
        // Navigate to login page
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Ulgoginpage())
        );
      } else {
        Fluttertoast.showToast(msg: "Registration failed: ${data['error'] ?? 'Unknown error'}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _pinFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _nametextController.dispose();
    _emailtextController.dispose();
    _phonenotextController.dispose();
    _upintextController.dispose();
    _passwordtextController.dispose();
    _confirmPasswordtextController.dispose();
    super.dispose();
  }

  void _validatePasswords(){
    final password=_passwordtextController.text;
    final confirmPassword=_confirmPasswordtextController.text;

    setState(() {
      if(password.isEmpty || confirmPassword.isEmpty){
        _passwordMatchMessage='';
        _passwordMatchColor=Colors.grey;
        _passwordsMatch=false;
      }else if(password==confirmPassword){
        _passwordMatchMessage='Password Match ✓';
        _passwordMatchColor=Colors.green;
        _passwordsMatch=true;
      } else{
        _passwordMatchMessage='Password do not match ✗';
        _passwordMatchColor=Colors.red;
        _passwordsMatch=false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 1,
          elevation: 1,
          backgroundColor: const Color(0xFF5669F6),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF5669F6),
                Color(0xFF5CF7FF),
              ],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 1, top: 5),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    height: 30,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
                      iconSize: 24,
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Ulgoginpage())
                        );
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 1),
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Text(
                              'Create Account',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Join And Start Trading Today',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            _selectedImage != null
                                ? Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300, width: 2),
                              ),
                              child: ClipOval(
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: 90,
                                  height: 90,
                                ),
                              ),
                            )
                                : Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.grey.shade400,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 5),
                            ElevatedButton(
                              onPressed: _chooseImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Choose Image"),
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _nametextController,
                              focusNode: _nameFocus,
                              decoration: const InputDecoration(
                                labelText: 'Enter Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _emailtextController,
                              focusNode: _emailFocus,
                              decoration: const InputDecoration(
                                labelText: 'Enter Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _phonenotextController,
                              focusNode: _phoneFocus,
                              decoration: const InputDecoration(
                                labelText: 'Enter Phone Number',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone_android_outlined),
                              ),
                              keyboardType: TextInputType.phone,
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_pinFocus),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Phone number is required';
                                }
                                if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                  return 'Enter a valid 10-digit phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                // State Dropdown
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'State',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.location_city_outlined),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                    ),
                                    value: _selectedState,
                                    hint: const Text(
                                      'Select State',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    items: getStateList().map((String state) {
                                      return DropdownMenuItem<String>(
                                        value: state,
                                        child: Text(
                                          state,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: _onStateChanged,
                                    validator: (value) {
                                      if (value == null || value == 'Select Your State') {
                                        return 'Please select a State';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10), // Reduced spacing
                                // District Dropdown
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'District',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.apartment),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                    ),
                                    value: _selectedDistrict,
                                    hint: Text(
                                      _selectedState == 'Select Your State' || _selectedState == null
                                          ? 'Select state'
                                          : 'Select District',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    items: getDistrictList(_selectedState).map((String district) {
                                      return DropdownMenuItem<String>(
                                        value: district,
                                        child: Text(
                                          district,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (_selectedState == 'Select Your State' || _selectedState == null)
                                        ? null
                                        : (String? newValue) {
                                      setState(() {
                                        _selectedDistrict = newValue;
                                      });
                                    },
                                    validator: (value) {
                                      if (_selectedState != 'Select Your State' && (value == null || value == 'Select Your District')) {
                                        return 'Please select a District';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _upintextController,
                              focusNode: _pinFocus,
                              decoration: const InputDecoration(
                                labelText: 'Enter PIN Code',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                              keyboardType: TextInputType.number,
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'PIN code is required';
                                }
                                if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                                  return 'Enter a valid 6-digit PIN code';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              obscureText: !_isPasswordVisible,
                              controller: _passwordtextController,
                              focusNode: _passwordFocus,
                              decoration: InputDecoration(
                                labelText: 'Enter Password',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              onChanged: (value) => _validatePasswords(), // Real-time validation
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocus),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              obscureText: true,
                              controller: _confirmPasswordtextController,
                              focusNode: _confirmPasswordFocus,
                              decoration: const InputDecoration(
                                labelText: 'Confirm Password',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock_reset_outlined),
                              ),
                              onChanged: (value) => _validatePasswords(), // Real-time validation
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (value) {
                                if (_formKey.currentState!.validate() && _passwordsMatch) {
                                  _sendData();
                                }
                              },
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: _passwordMatchMessage.isEmpty ? 0 : 20,
                              child: Text(
                                _passwordMatchMessage,
                                style: TextStyle(
                                  color: _passwordMatchColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate() && _passwordsMatch) {
                                  _sendData();
                                } else {
                                  if (!_passwordsMatch) {
                                    Fluttertoast.showToast(msg: "Passwords do not match");
                                  } else {
                                    Fluttertoast.showToast(msg: "Please fix errors in the form");
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: _passwordsMatch ? Colors.blue : Colors.grey, // Visual feedback
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Sign Up"),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already Have An Account? ',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const Ulgoginpage())
                                    );
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}