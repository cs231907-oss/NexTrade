import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradingapp/Recharge_amount.dart';
import 'package:tradingapp/viewfavourite.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const Vwallet());
}

class Vwallet extends StatelessWidget {
  const Vwallet({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Walletview(title: 'Wallet'),
    );
  }
}

class Walletview extends StatefulWidget {
  const Walletview({super.key, required String title});

  @override
  State<Walletview> createState() => _WalletviewState();
}

class _WalletviewState extends State<Walletview> {
  final TextEditingController _controller = TextEditingController();
  String amnt_ = "";
  bool _isLoading = true;
  Timer? _refreshTimer;

  void a() {
    _refreshTimer = Timer.periodic(
      Duration(seconds: 10),
          (timer) {
        loadamnt();
      },
    );
  }

  @override
  void initState() {
    loadamnt();
    a();
    super.initState();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadamnt() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url').toString();
      String uid = sh.getString('uid').toString();

      final urls = Uri.parse('$url/Balance_coin/');
      final response = await http.post(urls, body: {'lid': uid});

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          String amnt = jsonDecode(response.body)['amount'].toString();
          setState(() {
            amnt_ = amnt;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          Fluttertoast.showToast(msg: 'Balance not found');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Connection error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            _buildBalanceCard(),

            const SizedBox(height: 32),

            // Recharge Section
            _buildRechargeSection(),

            const SizedBox(height: 24),

            // Additional Info
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5669F6),
              Color(0xFF5CF7FF),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Available Balance",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: loadamnt,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoading
                ? Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            )
                : Text(
              "₹ ${amnt_.isEmpty ? "0.00" : amnt_}",
              style: TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Auto-refreshes every 10 seconds",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRechargeSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "Recharge Wallet",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Enter Amount",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: "Enter amount...",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  prefixIcon: Icon(
                    Icons.currency_rupee_rounded,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (_controller.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please enter amount');
                    return;
                  }

                  SharedPreferences sh = await SharedPreferences.getInstance();
                  sh.setString("amnt", _controller.text.toString());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Recharge_amt(),
                    ),
                  );
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Proceed to Recharge",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.blue[700],
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quick Tips",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "• Minimum recharge amount is ₹100\n• Instant credit to your trading account\n• Secure payment processing",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}