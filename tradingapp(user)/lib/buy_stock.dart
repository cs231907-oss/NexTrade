import 'dart:async';
import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tradingapp/viewbuystock.dart';

void main() {
  runApp(const buy_stock());
}

class buy_stock extends StatelessWidget {
  const buy_stock({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Buystock(),
    );
  }
}

class Buystock extends StatefulWidget {
  const Buystock({super.key});

  @override
  State<Buystock> createState() => _BuystockState();
}

class _BuystockState extends State<Buystock> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _acccontroller = TextEditingController();
  final TextEditingController _pkeycontroller = TextEditingController();
  List<String> date_ = [];
  List<double> high_ = [];
  bool _isLoading = false;
  bool _isGraphLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchHighGraph();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      Duration(seconds: 120),
          (timer) {
        fetchHighGraph();
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchHighGraph() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? baseUrl = sh.getString('url');
      String name = sh.getString('name') ?? "";

      if (baseUrl == null || name.isEmpty) {
        return;
      }

      var response = await http.post(
        Uri.parse('$baseUrl/buy_high_graph/'),
        body: {'name': name},
      );

      var jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 'ok') {
        var arr = jsonData["data"];

        setState(() {
          date_ = arr.map<String>((e) => e['date'].toString()).toList();
          high_ = arr
              .map<double>((e) => double.tryParse(e['high'].toString()) ?? 0)
              .toList();
          _isGraphLoading = false;
        });
      } else {
        setState(() {
          _isGraphLoading = false;
        });
        Fluttertoast.showToast(msg: "Unable to load market data");
      }
    } catch (e) {
      setState(() {
        _isGraphLoading = false;
      });
    }
  }

  List<charts.Series<TimeSeriesStock, DateTime>> _createSeries() {
    List<TimeSeriesStock> data = [];

    for (int i = 0; i < date_.length; i++) {
      data.add(
        TimeSeriesStock(
          DateTime.tryParse(date_[i]) ?? DateTime.now(),
          high_[i],
        ),
      );
    }

    return [
      charts.Series<TimeSeriesStock, DateTime>(
        id: 'High',
        domainFn: (TimeSeriesStock stock, _) => stock.time,
        measureFn: (TimeSeriesStock stock, _) => stock.value,
        data: data,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      )
    ];
  }

  Future<void> _sendData() async {
    if (_isLoading) return;

    String amnt = _controller.text.trim();
    String account = _acccontroller.text.trim();
    String prvkey = _pkeycontroller.text.trim();

    if (amnt.isEmpty || account.isEmpty || prvkey.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String fid = sh.getString('fid').toString();
    String uid = sh.getString('uid').toString();

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final uri = Uri.parse('$url/buy_stock/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['uid'] = fid;
    request.fields['lid'] = uid;
    request.fields['qty'] = amnt;
    request.fields['acc'] = account;
    request.fields['pkey'] = prvkey;

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "✅ Stock purchased successfully!");
        _controller.clear();
        _acccontroller.clear();
        _pkeycontroller.clear();
        fetchHighGraph();
      } else {
        Fluttertoast.showToast(msg: data['message'] ?? "Purchase failed.");
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
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
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
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
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

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5669F6).withOpacity(0.08),
            const Color(0xFF5CF7FF).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Market High Price History",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: fetchHighGraph,
                child: Container(
                  width: 40,
                  height: 40,
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
                  child: const Icon(
                    Icons.refresh_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _isGraphLoading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading market data...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : date_.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bar_chart_outlined,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No market data available",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(8.0),
              child: charts.TimeSeriesChart(
                _createSeries(),
                animate: true,
                defaultRenderer: charts.LineRendererConfig(
                  includePoints: true,
                ),
                behaviors: [
                  charts.SeriesLegend(
                    position: charts.BehaviorPosition.top,
                    desiredMaxRows: 1,
                  ),
                  charts.ChartTitle(
                    'Date',
                    behaviorPosition: charts.BehaviorPosition.bottom,
                  ),
                  charts.ChartTitle(
                    'Price',
                    behaviorPosition: charts.BehaviorPosition.start,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF5669F6),
                      Color(0xFF5CF7FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Purchase Stocks",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildInputField(
            label: "Total stock",
            icon: Icons.currency_rupee_rounded,
            controller: _controller,
            keyboardType: TextInputType.number,
            hintText: "Enter volume...",
          ),

          _buildInputField(
            label: "Account Address",
            icon: Icons.account_balance_rounded,
            controller: _acccontroller,
            hintText: "Enter your account address...",
          ),

          _buildInputField(
            label: "Private Key",
            icon: Icons.key_rounded,
            controller: _pkeycontroller,
            isPassword: true,
            hintText: "Enter your private key...",
          ),

          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Ensure all details are correct before purchasing",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                        Icons.shopping_cart_checkout_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Confirm Purchase",
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
        ],
      ),
    );
  }

  Widget _buildAutoRefreshInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.autorenew_rounded,
              color: const Color(0xFF5669F6),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Auto-Refresh Enabled",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Market data refreshes automatically every 2 minutes",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom Header
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
                            "Buy Stocks",
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
                          Icons.trending_up_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    "Analyze market trends and make informed purchases",
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
              child: Column(
                children: [
                  _buildChartSection(),
                  _buildPurchaseForm(),
                  _buildAutoRefreshInfo(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeSeriesStock {
  final DateTime time;
  final double value;
  TimeSeriesStock(this.time, this.value);
}