import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradingapp/viewfavourite.dart';
import 'package:http/http.dart' as http;
import 'package:tradingapp/viewsellstock.dart';

void main() {
  runApp(const sell_stock());
}

class sell_stock extends StatelessWidget {
  const sell_stock({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Sellstock(title: '',),
    );
  }
}

class Sellstock extends StatefulWidget {
  const Sellstock({super.key, required String title});

  @override
  State<Sellstock> createState() => _SellstockState();
}

class _SellstockState extends State<Sellstock> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _acccontroller = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendData() async {
    if (_isLoading) return;

    String qty = _controller.text.trim();
    String acc = _acccontroller.text.trim();

    if (qty.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter quantity");
      return;
    }

    // Validate quantity is a positive number
    try {
      int quantity = int.parse(qty);
      if (quantity <= 0) {
        Fluttertoast.showToast(msg: "Quantity must be greater than 0");
        return;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Please enter a valid number");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String bid = sh.getString('bid').toString();
    String lid = sh.getString('uid').toString();

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final uri = Uri.parse('$url/sell_stock/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['uid'] = bid;
    request.fields['lid'] = lid;
    request.fields['quantity'] = qty;
    request.fields['acc'] = acc;

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "✅ Successfully sold stocks!");
        _controller.clear();
        // Navigate after a brief delay
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StockSellListPage(title: ''),
            ),
          );
        });
      } else {
        Fluttertoast.showToast(msg: data['message'] ?? "Sale failed. Please try again.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network error. Please check your connection.");
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
    bool isPassword = false,
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
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: "Enter ${label.toLowerCase()}...",
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
                suffixIcon: controller.text.isNotEmpty && !isPassword
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

  Widget _buildQuickQuantityButton(String quantity) {
    bool isSelected = _controller.text == quantity;
    return GestureDetector(
      onTap: () {
        _controller.text = quantity;
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF5669F6),
              Color(0xFF5CF7FF),
            ],
          )
              : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF5669F6).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ]
              : null,
        ),
        child: Text(
          quantity,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom App Bar
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20),
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
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5669F6).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
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
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Sell Stocks",
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
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    "Sell your stocks securely and track your transactions",
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

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sell Icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 24),
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
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sell_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Input Fields Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Quantity Field
                        _buildInputField(
                          label: "Quantity to Sell",
                          icon: Icons.numbers_rounded,
                          controller: _controller,
                        ),

                        // Account Address Field
                        _buildInputField(
                          label: "Account Address",
                          icon: Icons.account_balance_rounded,
                          controller: _acccontroller,
                        ),
                        // Quick Select Section
                        const SizedBox(height: 20),
                        Text(
                          "Quick Select",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildQuickQuantityButton('10'),
                            _buildQuickQuantityButton('25'),
                            _buildQuickQuantityButton('50'),
                            _buildQuickQuantityButton('100'),
                          ],
                        ),

                        // Info Text
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Enter whole numbers only (e.g., 10, 50, 100)",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Sell Button
                  const SizedBox(height: 32),
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
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.sell_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Sell Stocks",
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

                  // Warning Card
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.shade50,
                          Colors.orange.shade100.withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Important Notice",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Stock sales are final and cannot be reversed. Please verify all details before proceeding with the sale.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}