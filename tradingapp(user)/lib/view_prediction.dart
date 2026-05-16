import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tradingapp/home.dart';

void main() {
  runApp(const stockPrediction());
}

class stockPrediction extends StatelessWidget {
  const stockPrediction({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF5669F6),
          primary: Color(0xFF5669F6),
          secondary: Color(0xFF5CF7FF),
        ),
        useMaterial3: true,
      ),
      home: const view_prediction(title: 'Stock Prediction'),
    );
  }
}

class view_prediction extends StatefulWidget {
  const view_prediction({super.key, required this.title});
  final String title;

  @override
  State<view_prediction> createState() => _view_predictionState();
}

class _view_predictionState extends State<view_prediction> {
  var _formKey = GlobalKey<FormState>();
  String rf_ = "";
  String lf_ = "";
  String avg_ = "";
  bool _isLoading = true;
  String? _stockName;

  @override
  void initState() {
    super.initState();
    _getStockName();
    senddata();
  }

  Future<void> _getStockName() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? name = sh.getString("name");
    setState(() {
      _stockName = name;
    });
  }

  void senddata() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString("url").toString();
      String nm = sh.getString("name").toString();

      final urls = Uri.parse('$url/priceprediction/');
      final response = await http.post(urls, body: {'name': nm});

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];

        if (status == "ok") {
          String rf = jsonDecode(response.body)['rf'].toString();
          String lf = jsonDecode(response.body)['lr'].toString();
          String avg = jsonDecode(response.body)['avg'].toString();

          setState(() {
            rf_ = rf;
            lf_ = lf;
            avg_ = avg;
            _isLoading = false;
          });
        } else {
          Fluttertoast.showToast(msg: "Prediction data not found");
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Network error");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Connection error");
      setState(() {
        _isLoading = false;
      });
    }
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage(title: '')),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Stock Prediction",
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
                    "AI-powered predictions for informed investment decisions",
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF5669F6).withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Header Section
                      Container(
                        margin: EdgeInsets.only(bottom: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Stock Analysis',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            if (_stockName != null)
                              Text(
                                'Analysis for $_stockName',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            SizedBox(height: 4),
                            Text(
                              'Powered by machine learning algorithms',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Loading State
                      if (_isLoading)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 100),
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5669F6)),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Analyzing stock data...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                      // Prediction Results
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Prediction Accuracy Card
                            Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF5669F6).withOpacity(0.1),
                                      Color(0xFF5CF7FF).withOpacity(0.05),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.analytics_rounded,
                                            color: Color(0xFF5669F6),
                                            size: 24,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Prediction Summary',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      _buildPredictionRow(
                                        'Random Forest ',
                                        '$rf_%',
                                        Icons.forest_rounded,
                                        Colors.green,
                                      ),
                                      _buildPredictionRow(
                                        'Logistic Regression ',
                                        '$lf_%',
                                        Icons.trending_up_rounded,
                                        Colors.blue,
                                      ),
                                      _buildPredictionRow(
                                        'Next Day Prediction',
                                        '\$$avg_',
                                        Icons.show_chart_rounded,
                                        Colors.orange,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Model Explanations
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Model Explanations',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    _buildModelExplanation(
                                      'Random Forest',
                                      'Ensemble learning method that operates by constructing multiple decision trees.',
                                      Colors.green,
                                    ),
                                    SizedBox(height: 12),
                                    _buildModelExplanation(
                                      'Logistic Regression',
                                      'Statistical model that uses a logistic function to model binary probability.',
                                      Colors.blue,
                                    ),
                                    SizedBox(height: 12),
                                    _buildModelExplanation(
                                      'Next Day Price',
                                      'Weighted average prediction based on both models for tomorrow\'s expected price.',
                                      Colors.orange,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Disclaimer
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange[100]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange[700],
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Predictions are based on historical data and may not reflect future performance.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 32),
                          ],
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

  Widget _buildPredictionRow(String title, String value, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Model prediction accuracy',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelExplanation(String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}