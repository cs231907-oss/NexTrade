//normal basic graph
// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tradingapp/home.dart';
// import 'package:tradingapp/viewstock.dart';
//
// void main() {
//   runApp(const Viewhigh());
// }
//
// class Viewhigh extends StatelessWidget {
//   const Viewhigh({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'View Stock Details',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color.fromARGB(207, 97, 161, 156),
//         ),
//         useMaterial3: true,
//       ),
//       home: const View_Stock_Chart(title: 'Stock Details'),
//     );
//   }
// }
//
// class View_Stock_Chart extends StatefulWidget {
//   const View_Stock_Chart({super.key, required this.title});
//   final String title;
//
//   @override
//   State<View_Stock_Chart> createState() => _View_Stock_ChartState();
// }
//
// class _View_Stock_ChartState extends State<View_Stock_Chart>
//     with SingleTickerProviderStateMixin {
//   List<String> date_ = [];
//   List<double> open_ = [];
//   List<double> high_ = [];
//   List<double> low_ = [];
//   List<double> close_ = [];
//   List<double> volume_ = [];
//
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 5, vsync: this);
//     _fetchStockDetails();
//   }
//
//   Future<void> _fetchStockDetails() async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String urls = sh.getString('url') ?? '';
//       String nm = sh.getString('name') ?? '';
//       String url = '$urls/stock_details/';
//
//       var data = await http.post(Uri.parse(url), body: {'name': nm});
//       var jsondata = json.decode(data.body);
//
//       if (jsondata['status'] == 'ok') {
//         var arr = jsondata["data"];
//
//         setState(() {
//           date_ = arr.map<String>((e) => e['date'].toString()).toList();
//
//           open_ = arr
//               .map<double>((e) => double.tryParse(e['open'].toString()) ?? 0)
//               .toList();
//           high_ = arr
//               .map<double>((e) => double.tryParse(e['high'].toString()) ?? 0)
//               .toList();
//           low_ = arr
//               .map<double>((e) => double.tryParse(e['low'].toString()) ?? 0)
//               .toList();
//           close_ = arr
//               .map<double>((e) => double.tryParse(e['close'].toString()) ?? 0)
//               .toList();
//           volume_ = arr
//               .map<double>((e) => double.tryParse(e['volume'].toString()) ?? 0)
//               .toList();
//         });
//       } else {
//         Fluttertoast.showToast(msg: "Failed to fetch data");
//       }
//     } catch (e) {
//       print("Error: $e");
//       Fluttertoast.showToast(msg: "Error fetching stock details");
//     }
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//
//   List<charts.Series<TimeSeriesStock, DateTime>> _createSeries(
//       List<double> values) {
//     final aboveAvg = <TimeSeriesStock>[];
//     final belowAvg = <TimeSeriesStock>[];
//
//     double avg =
//     values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : 0;
//
//     for (int i = 0; i < date_.length; i++) {
//       final dt = DateTime.tryParse(date_[i]) ?? DateTime.now();
//       final v = values[i];
//
//       if (v >= avg) {
//         aboveAvg.add(TimeSeriesStock(dt, v));
//         belowAvg.add(TimeSeriesStock(dt, null));
//       } else {
//         belowAvg.add(TimeSeriesStock(dt, v));
//         aboveAvg.add(TimeSeriesStock(dt, null));
//       }
//     }
//
//     return [
//       charts.Series<TimeSeriesStock, DateTime>(
//         id: 'Above Avg',
//         domainFn: (TimeSeriesStock stock, _) => stock.time,
//         measureFn: (TimeSeriesStock stock, _) => stock.value,
//         data: aboveAvg,
//         colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
//       ),
//       charts.Series<TimeSeriesStock, DateTime>(
//         id: 'Below Avg',
//         domainFn: (TimeSeriesStock stock, _) => stock.time,
//         measureFn: (TimeSeriesStock stock, _) => stock.value,
//         data: belowAvg,
//         colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//       ),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (_) => StockListPage(title: '',)));
//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: const Color.fromARGB(255, 232, 177, 61),
//           title: Text(widget.title),
//           bottom: TabBar(
//             controller: _tabController,
//             isScrollable: true,
//             tabs: const [
//               Tab(text: 'Open'),
//               Tab(text: 'High'),
//               Tab(text: 'Low'),
//               Tab(text: 'Close'),
//               Tab(text: 'Volume'),
//             ],
//           ),
//         ),
//         backgroundColor: Colors.white,
//
//
//         body: date_.isEmpty
//             ? const Center(child: CircularProgressIndicator())
//             : TabBarView(
//           controller: _tabController,
//           children: [
//             InteractiveViewer(
//               minScale: 0.5,
//               maxScale: 5.0,
//               boundaryMargin: const EdgeInsets.all(20),
//               child:
//               charts.TimeSeriesChart(_createSeries(open_), animate: true),
//             ),
//             InteractiveViewer(
//               minScale: 0.5,
//               maxScale: 5.0,
//               boundaryMargin: const EdgeInsets.all(20),
//               child:
//               charts.TimeSeriesChart(_createSeries(high_), animate: true),
//             ),
//             InteractiveViewer(
//               minScale: 0.5,
//               maxScale: 5.0,
//               boundaryMargin: const EdgeInsets.all(20),
//               child:
//               charts.TimeSeriesChart(_createSeries(low_), animate: true),
//             ),
//             InteractiveViewer(
//               minScale: 0.5,
//               maxScale: 5.0,
//               boundaryMargin: const EdgeInsets.all(20),
//               child:
//               charts.TimeSeriesChart(_createSeries(close_), animate: true),
//             ),
//             InteractiveViewer(
//               minScale: 0.5,
//               maxScale: 5.0,
//               boundaryMargin: const EdgeInsets.all(20),
//               child:
//               charts.TimeSeriesChart(_createSeries(volume_), animate: true),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // MODEL
// class TimeSeriesStock {
//   final DateTime time;
//   final double? value;
//   TimeSeriesStock(this.time, this.value);
// }



//modle 1 graph with model
// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tradingapp/home.dart';
// import 'package:tradingapp/viewstock.dart';
//
// void main() {
//   runApp(const Viewhigh());
// }
//
// class Viewhigh extends StatelessWidget {
//   const Viewhigh({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Stock Analysis',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF5669F6),
//           primary: const Color(0xFF5669F6),
//           secondary: const Color(0xFF5CF7FF),
//         ),
//         useMaterial3: true,
//       ),
//       home: const View_Stock_Chart(title: 'Stock Analysis'),
//     );
//   }
// }
//
// class View_Stock_Chart extends StatefulWidget {
//   const View_Stock_Chart({super.key, required this.title});
//   final String title;
//
//   @override
//   State<View_Stock_Chart> createState() => _View_Stock_ChartState();
// }
//
// class _View_Stock_ChartState extends State<View_Stock_Chart>
//     with SingleTickerProviderStateMixin {
//   List<String> date_ = [];
//   List<double> open_ = [];
//   List<double> high_ = [];
//   List<double> low_ = [];
//   List<double> close_ = [];
//   List<double> volume_ = [];
//   String _stockName = '';
//   bool _isLoading = true;
//
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 5, vsync: this);
//     _getStockName();
//     _fetchStockDetails();
//   }
//
//   Future<void> _getStockName() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? name = sh.getString('name');
//     setState(() {
//       _stockName = name ?? 'Unknown Stock';
//     });
//   }
//
//   Future<void> _fetchStockDetails() async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String urls = sh.getString('url') ?? '';
//       String nm = sh.getString('name') ?? '';
//       String url = '$urls/stock_details/';
//
//       var data = await http.post(Uri.parse(url), body: {'name': nm});
//       var jsondata = json.decode(data.body);
//
//       if (jsondata['status'] == 'ok') {
//         var arr = jsondata["data"];
//
//         setState(() {
//           date_ = arr.map<String>((e) => e['date'].toString()).toList();
//           open_ = arr
//               .map<double>((e) => double.tryParse(e['open'].toString()) ?? 0)
//               .toList();
//           high_ = arr
//               .map<double>((e) => double.tryParse(e['high'].toString()) ?? 0)
//               .toList();
//           low_ = arr
//               .map<double>((e) => double.tryParse(e['low'].toString()) ?? 0)
//               .toList();
//           close_ = arr
//               .map<double>((e) => double.tryParse(e['close'].toString()) ?? 0)
//               .toList();
//           volume_ = arr
//               .map<double>((e) => double.tryParse(e['volume'].toString()) ?? 0)
//               .toList();
//           _isLoading = false;
//         });
//       } else {
//         Fluttertoast.showToast(msg: "Failed to fetch data");
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Error: $e");
//       Fluttertoast.showToast(msg: "Error fetching stock details");
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   // CandleStick series for candlestick-style charts
//   List<charts.Series<CandleStickData, DateTime>> _createCandleSeries(
//       List<double> values, String chartType) {
//     final data = <CandleStickData>[];
//
//     double avg =
//     values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : 0;
//
//     for (int i = 0; i < date_.length; i++) {
//       final dt = DateTime.tryParse(date_[i]) ?? DateTime.now();
//       final value = values[i];
//
//       // Create candlestick-style data
//       // For single value charts, we'll create a "fake" candlestick
//       // where open = value - (value * 0.1), close = value + (value * 0.1)
//       // This creates the rectangle/candlestick effect
//       final double fakeLow = value * 0.95;
//       final double fakeHigh = value * 1.05;
//
//       // Determine if above or below average
//       final bool isAboveAvg = value >= avg;
//
//       data.add(CandleStickData(
//         dt,
//         fakeLow,  // open (lower bound)
//         fakeHigh, // high
//         fakeLow,  // low (same as open for rectangle effect)
//         fakeHigh, // close (upper bound)
//         isAboveAvg,
//       ));
//     }
//
//     return [
//       charts.Series<CandleStickData, DateTime>(
//         id: chartType,
//         domainFn: (CandleStickData stock, _) => stock.time,
//         measureFn: (CandleStickData stock, _) => stock.low,
//         measureUpperBoundFn: (CandleStickData stock, _) => stock.high,
//         measureLowerBoundFn: (CandleStickData stock, _) => stock.low,
//         data: data,
//         // Color based on above/below average
//         colorFn: (CandleStickData stock, _) => stock.isAboveAvg
//             ? charts.MaterialPalette.blue.shadeDefault  // BLUE for above average
//             : charts.MaterialPalette.red.shadeDefault,   // RED for below average
//       )..setAttribute(charts.rendererIdKey, 'candlestick'),
//     ];
//   }
//
//   // Special candlestick for OHLC data
//   List<charts.Series<CandleStickData, DateTime>> _createOHLCCandleSeries() {
//     final data = <CandleStickData>[];
//
//     for (int i = 0; i < date_.length; i++) {
//       final dt = DateTime.tryParse(date_[i]) ?? DateTime.now();
//       final isBullish = close_[i] > open_[i];
//
//       data.add(CandleStickData(
//         dt,
//         open_[i],
//         high_[i],
//         low_[i],
//         close_[i],
//         isBullish, // For OHLC, use bullish/bearish instead of avg
//       ));
//     }
//
//     return [
//       charts.Series<CandleStickData, DateTime>(
//         id: 'OHLC',
//         domainFn: (CandleStickData stock, _) => stock.time,
//         measureFn: (CandleStickData stock, _) => stock.low,
//         measureUpperBoundFn: (CandleStickData stock, _) => stock.high,
//         measureLowerBoundFn: (CandleStickData stock, _) => stock.low,
//         data: data,
//         // Green for bullish, Red for bearish
//         colorFn: (CandleStickData stock, _) => stock.isAboveAvg
//             ? charts.MaterialPalette.green.shadeDefault  // Green for bullish
//             : charts.MaterialPalette.red.shadeDefault,   // Red for bearish
//       )..setAttribute(charts.rendererIdKey, 'candlestick'),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Column(
//           children: [
//             // Custom Header with Gradient
//             Container(
//               padding: const EdgeInsets.only(top: 50, bottom: 20),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     const Color(0xFF5669F6),
//                     const Color(0xFF5CF7FF),
//                   ],
//                 ),
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(24),
//                   bottomRight: Radius.circular(24),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF5669F6).withOpacity(0.3),
//                     blurRadius: 15,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: IconButton(
//                             icon: const Icon(
//                               Icons.arrow_back_ios_new_rounded,
//                               size: 20,
//                               color: Colors.white,
//                             ),
//                             onPressed: () {
//                               Navigator.push(
//                                 context, MaterialPageRoute(builder: (context) => HomePage(title: '')),
//                               );
//                             },
//                           ),
//                         ),
//                         Expanded(
//                           child: Center(
//                             child: Text(
//                               "Stock Analysis",
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w700,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Icon(
//                             Icons.analytics_rounded,
//                             size: 22,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 32),
//                     child: Column(
//                       children: [
//                         Text(
//                           _stockName,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white.withOpacity(0.95),
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           "Interactive market analysis with candlestick charts",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.white.withOpacity(0.8),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Custom Tab Bar
//             Container(
//               color: Colors.white,
//               child: Column(
//                 children: [
//                   Container(
//                     height: 50,
//                     child: TabBar(
//                       controller: _tabController,
//                       isScrollable: true,
//                       labelColor: const Color(0xFF5669F6),
//                       unselectedLabelColor: Colors.grey[600],
//                       indicatorColor: const Color(0xFF5669F6),
//                       indicatorWeight: 3,
//                       indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
//                       labelStyle: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       unselectedLabelStyle: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       tabs: const [
//                         Tab(text: 'OHLC'),
//                         Tab(text: 'High'),
//                         Tab(text: 'Low'),
//                         Tab(text: 'Close'),
//                         Tab(text: 'Volume'),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     height: 1,
//                     color: Colors.grey[200],
//                   ),
//                 ],
//               ),
//             ),
//
//             // Content Area
//             Expanded(
//               child: _isLoading
//                   ? _buildLoadingState()
//                   : date_.isEmpty
//                   ? _buildEmptyState()
//                   : Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.white,
//                       Color(0xFFF8FAFF),
//                     ],
//                   ),
//                 ),
//                 child: TabBarView(
//                   controller: _tabController,
//                   children: [
//                     _buildChartView('OHLC', open_, true),
//                     _buildChartView('High', high_, false),
//                     _buildChartView('Low', low_, false),
//                     _buildChartView('Close', close_, false),
//                     _buildChartView('Volume', volume_, false),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Color(0xFF5669F6),
//                   Color(0xFF5CF7FF),
//                 ],
//               ),
//               shape: BoxShape.circle,
//             ),
//             child: const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 strokeWidth: 3,
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             "Loading Stock Data...",
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.black54,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _stockName,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   const Color(0xFF5669F6).withOpacity(0.1),
//                   const Color(0xFF5CF7FF).withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.bar_chart_outlined,
//               size: 60,
//               color: Color(0xFF5669F6),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             "No Data Available",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 40),
//             child: Text(
//               "Historical data for this stock is currently unavailable",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (_) => StockListPage(title: '')),
//               );
//             },
//             icon: const Icon(Icons.arrow_back_rounded, size: 18),
//             label: const Text('Back to Stocks'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF5669F6),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildChartView(String title, List<double> values, bool isOHLC) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Chart Title and Info
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '$title Chart',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   isOHLC
//                       ? 'Open, High, Low, Close candlestick chart'
//                       : 'Candlestick-style $title values over time',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey[600],
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 12),
//                 // Legend - Wrapped to prevent overflow
//                 Wrap(
//                   spacing: 16,
//                   runSpacing: 8,
//                   children: isOHLC
//                       ? [
//                     _buildLegendItem(
//                       color: Colors.green,
//                       label: 'Bullish (Close > Open)',
//                     ),
//                     _buildLegendItem(
//                       color: Colors.red,
//                       label: 'Bearish (Close < Open)',
//                     ),
//                   ]
//                       : [
//                     _buildLegendItem(
//                       color: Colors.blue,
//                       label: 'Above Average',
//                     ),
//                     _buildLegendItem(
//                       color: Colors.red,
//                       label: 'Below Average',
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Interactive Chart
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: InteractiveViewer(
//                   minScale: 0.5,
//                   maxScale: 5.0,
//                   boundaryMargin: const EdgeInsets.all(20),
//                   child: charts.TimeSeriesChart(
//                     isOHLC
//                         ? _createOHLCCandleSeries()
//                         : _createCandleSeries(values, title),
//                     animate: true,
//                     behaviors: [
//                       charts.SeriesLegend(),
//                       charts.ChartTitle('Date'),
//                       charts.ChartTitle(title),
//                     ],
//                     defaultRenderer: charts.BarRendererConfig<DateTime>(
//                       groupingType: charts.BarGroupingType.grouped,
//                       // Adjust bar width for better candlestick appearance
//                       strokeWidthPx: 1.0,
//                     ),
//                     domainAxis: const charts.DateTimeAxisSpec(
//                       renderSpec: charts.SmallTickRendererSpec(
//                         labelStyle: charts.TextStyleSpec(
//                           fontSize: 11,
//                           color: charts.MaterialPalette.black,
//                         ),
//                       ),
//                     ),
//                     primaryMeasureAxis: const charts.NumericAxisSpec(
//                       renderSpec: charts.SmallTickRendererSpec(
//                         labelStyle: charts.TextStyleSpec(
//                           fontSize: 11,
//                           color: charts.MaterialPalette.black,
//                         ),
//                       ),
//                     ),
//                     customSeriesRenderers: [
//                       charts.BarRendererConfig<DateTime>(
//                         customRendererId: 'candlestick',
//                         groupingType: charts.BarGroupingType.grouped,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Chart Controls Info
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey[200]!),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.touch_app_rounded,
//                   size: 16,
//                   color: const Color(0xFF5669F6),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'Pinch to zoom • Drag to pan • Tap candlesticks for details',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLegendItem({required Color color, required String label}) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: color,
//           ),
//         ),
//         const SizedBox(width: 6),
//         Flexible(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[700],
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // CandleStick Data Model
// class CandleStickData {
//   final DateTime time;
//   final double open;
//   final double high;
//   final double low;
//   final double close;
//   final bool isAboveAvg; // For non-OHLC: above/below avg, For OHLC: bullish/bearish
//
//   CandleStickData(this.time, this.open, this.high, this.low, this.close, this.isAboveAvg);
// }



//model 2 with yfinance design graph
// import 'dart:math';
//
// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tradingapp/home.dart';
// import 'package:tradingapp/viewstock.dart';
//
// void main() {
//   runApp(const Viewhigh());
// }
//
// class Viewhigh extends StatelessWidget {
//   const Viewhigh({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Stock Analysis',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF5669F6),
//           primary: const Color(0xFF5669F6),
//           secondary: const Color(0xFF5CF7FF),
//         ),
//         useMaterial3: true,
//       ),
//       home: const View_Stock_Chart(title: 'Stock Analysis'),
//     );
//   }
// }
//
// class View_Stock_Chart extends StatefulWidget {
//   const View_Stock_Chart({super.key, required this.title});
//   final String title;
//
//   @override
//   State<View_Stock_Chart> createState() => _View_Stock_ChartState();
// }
//
// class _View_Stock_ChartState extends State<View_Stock_Chart>
//     with SingleTickerProviderStateMixin {
//   List<String> date_ = [];
//   List<double> open_ = [];
//   List<double> high_ = [];
//   List<double> low_ = [];
//   List<double> close_ = [];
//   List<double> volume_ = [];
//   String _stockName = '';
//   bool _isLoading = true;
//
//   // For showing tooltip on tap
//   ChartData? _selectedData;
//   String _selectedTab = 'Open';
//
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 5, vsync: this);
//     _tabController.addListener(() {
//       setState(() {
//         _selectedTab = _tabController.index == 0
//             ? 'Open'
//             : _tabController.index == 1
//             ? 'High'
//             : _tabController.index == 2
//             ? 'Low'
//             : _tabController.index == 3
//             ? 'Close'
//             : 'Volume';
//         _selectedData = null;
//       });
//     });
//     _getStockName();
//     _fetchStockDetails();
//   }
//
//   Future<void> _getStockName() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? name = sh.getString('name');
//     setState(() {
//       _stockName = name ?? 'Unknown Stock';
//     });
//   }
//
//   Future<void> _fetchStockDetails() async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String urls = sh.getString('url') ?? '';
//       String nm = sh.getString('name') ?? '';
//       String url = '$urls/stock_details/';
//
//       var data = await http.post(Uri.parse(url), body: {'name': nm});
//       var jsondata = json.decode(data.body);
//
//       if (jsondata['status'] == 'ok') {
//         var arr = jsondata["data"];
//
//         setState(() {
//           date_ = arr.map<String>((e) => e['date'].toString()).toList();
//           open_ = arr
//               .map<double>((e) => double.tryParse(e['open'].toString()) ?? 0)
//               .toList();
//           high_ = arr
//               .map<double>((e) => double.tryParse(e['high'].toString()) ?? 0)
//               .toList();
//           low_ = arr
//               .map<double>((e) => double.tryParse(e['low'].toString()) ?? 0)
//               .toList();
//           close_ = arr
//               .map<double>((e) => double.tryParse(e['close'].toString()) ?? 0)
//               .toList();
//           volume_ = arr
//               .map<double>((e) => double.tryParse(e['volume'].toString()) ?? 0)
//               .toList();
//           _isLoading = false;
//         });
//       } else {
//         Fluttertoast.showToast(msg: "Failed to fetch data");
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Error: $e");
//       Fluttertoast.showToast(msg: "Error fetching stock details");
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   // Yahoo Finance-style candlestick chart (OHLC data)
//   List<charts.Series<CandleStickData, DateTime>> _createOHLCCandleSeries() {
//     final data = <CandleStickData>[];
//
//     for (int i = 0; i < date_.length; i++) {
//       final dt = DateTime.tryParse(date_[i]) ?? DateTime.now();
//       final isBullish = close_[i] > open_[i];
//
//       data.add(CandleStickData(
//         dt,
//         open_[i],
//         high_[i],
//         low_[i],
//         close_[i],
//         isBullish,
//       ));
//     }
//
//     return [
//       charts.Series<CandleStickData, DateTime>(
//         id: 'OHLC',
//         domainFn: (CandleStickData stock, _) => stock.time,
//         measureFn: (CandleStickData stock, _) => stock.low,
//         measureUpperBoundFn: (CandleStickData stock, _) => stock.high,
//         measureLowerBoundFn: (CandleStickData stock, _) => stock.low,
//         data: data,
//         // Yahoo Finance style: Green for bullish, Red for bearish
//         colorFn: (CandleStickData stock, _) => stock.isBullish
//             ? charts.MaterialPalette.green.shadeDefault
//             : charts.MaterialPalette.red.shadeDefault,
//       )..setAttribute(charts.rendererIdKey, 'candlestick'),
//     ];
//   }
//
//   // Yahoo Finance-style single value charts (like Yahoo's line charts)
//   List<charts.Series<LineChartData, DateTime>> _createLineChartSeries(
//       List<double> values, String chartType) {
//     final data = <LineChartData>[];
//
//     for (int i = 0; i < date_.length; i++) {
//       final dt = DateTime.tryParse(date_[i]) ?? DateTime.now();
//       data.add(LineChartData(dt, values[i]));
//     }
//
//     return [
//       charts.Series<LineChartData, DateTime>(
//         id: chartType,
//         domainFn: (LineChartData stock, _) => stock.time,
//         measureFn: (LineChartData stock, _) => stock.value,
//         data: data,
//         colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//       ),
//     ];
//   }
//
//   // Yahoo Finance-style volume chart
//   List<charts.Series<VolumeData, DateTime>> _createVolumeSeries() {
//     final data = <VolumeData>[];
//
//     for (int i = 0; i < date_.length; i++) {
//       final dt = DateTime.tryParse(date_[i]) ?? DateTime.now();
//       final isBullish = close_[i] > open_[i];
//
//       data.add(VolumeData(dt, volume_[i], isBullish));
//     }
//
//     return [
//       charts.Series<VolumeData, DateTime>(
//         id: 'Volume',
//         domainFn: (VolumeData stock, _) => stock.time,
//         measureFn: (VolumeData stock, _) => stock.value,
//         data: data,
//         // Yahoo Finance style: Green for bullish days, Red for bearish days
//         colorFn: (VolumeData stock, _) => stock.isBullish
//             ? charts.MaterialPalette.green.shadeDefault
//             : charts.MaterialPalette.red.shadeDefault,
//       ),
//     ];
//   }
//
//   void _onSelectionChanged(charts.SelectionModel model) {
//     if (model.hasDatumSelection && model.selectedSeries.isNotEmpty) {
//       final selectedDatum = model.selectedDatum.first;
//       final series = selectedDatum.series;
//       final index = selectedDatum.index ?? 0;
//
//       if (index >= 0 && index < series.data.length) {
//         if (series.id == 'OHLC') {
//           setState(() {
//             _selectedData = ChartData(
//               time: (series.data[index] as CandleStickData).time,
//               open: (series.data[index] as CandleStickData).open,
//               high: (series.data[index] as CandleStickData).high,
//               low: (series.data[index] as CandleStickData).low,
//               close: (series.data[index] as CandleStickData).close,
//               value: (series.data[index] as CandleStickData).close,
//               chartType: 'OHLC',
//               isBullish: (series.data[index] as CandleStickData).isBullish,
//             );
//           });
//         } else if (series.id == 'Volume') {
//           setState(() {
//             _selectedData = ChartData(
//               time: (series.data[index] as VolumeData).time,
//               open: 0,
//               high: 0,
//               low: 0,
//               close: 0,
//               value: (series.data[index] as VolumeData).value,
//               chartType: 'Volume',
//               isBullish: (series.data[index] as VolumeData).isBullish,
//             );
//           });
//         } else {
//           setState(() {
//             _selectedData = ChartData(
//               time: (series.data[index] as LineChartData).time,
//               open: 0,
//               high: 0,
//               low: 0,
//               close: 0,
//               value: (series.data[index] as LineChartData).value,
//               chartType: series.id ?? 'Price',
//               isBullish: false,
//             );
//           });
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Column(
//           children: [
//             // Yahoo Finance-style Header
//             Container(
//               padding: const EdgeInsets.only(top: 50, bottom: 20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border(
//                   bottom: BorderSide(
//                     color: Colors.grey[300]!,
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[100],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: IconButton(
//                             icon: const Icon(
//                               Icons.arrow_back_ios_new_rounded,
//                               size: 18,
//                               color: Colors.black87,
//                             ),
//                             onPressed: () {
//                               Navigator.push(context,
//                                   MaterialPageRoute(builder: (context) => HomePage(title: '')));
//                             },
//                           ),
//                         ),
//                         Expanded(
//                           child: Center(
//                             child: Text(
//                               _stockName,
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ),
//                         ),
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[100],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(
//                             Icons.more_vert_rounded,
//                             size: 22,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Charts",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Data Point Display (if selected) - Yahoo Finance style
//             if (_selectedData != null) _buildYahooFinanceTooltip(),
//
//             // Yahoo Finance-style Tab Bar
//             Container(
//               color: Colors.white,
//               child: Column(
//                 children: [
//                   Container(
//                     height: 46,
//                     child: TabBar(
//                       controller: _tabController,
//                       isScrollable: true,
//                       labelColor: Colors.black87,
//                       unselectedLabelColor: Colors.grey[600],
//                       indicatorColor: Colors.black87,
//                       indicatorWeight: 2,
//                       labelStyle: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       unselectedLabelStyle: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w400,
//                       ),
//                       tabs: const [
//                         Tab(text: 'Candlestick'),
//                         Tab(text: 'Open'),
//                         Tab(text: 'High'),
//                         Tab(text: 'Low'),
//                         Tab(text: 'Volume'),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     height: 1,
//                     color: Colors.grey[200],
//                   ),
//                 ],
//               ),
//             ),
//
//             // Content Area
//             Expanded(
//               child: _isLoading
//                   ? _buildLoadingState()
//                   : date_.isEmpty
//                   ? _buildEmptyState()
//                   : Container(
//                 color: Colors.white,
//                 child: TabBarView(
//                   controller: _tabController,
//                   children: [
//                     _buildCandlestickView(),
//                     _buildLineChartView('Open', open_),
//                     _buildLineChartView('High', high_),
//                     _buildLineChartView('Low', low_),
//                     _buildVolumeView(),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildYahooFinanceTooltip() {
//     final data = _selectedData!;
//     final date = data.time;
//     final formattedDate = '${date.day}/${date.month}/${date.year}';
//     final isVolume = data.chartType == 'Volume';
//     final isCandle = data.chartType == 'OHLC';
//
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: Colors.grey[300]!,
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 formattedDate,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey,
//                 ),
//               ),
//               if (isCandle)
//                 Text(
//                   'O: \$${data.open.toStringAsFixed(2)}  H: \$${data.high.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               if (isCandle)
//                 Text(
//                   'L: \$${data.low.toStringAsFixed(2)}  C: \$${data.close.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               if (!isCandle && !isVolume)
//                 Text(
//                   '\$${data.value.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               if (isVolume)
//                 Text(
//                   '${data.value.toStringAsFixed(0)}',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//             ],
//           ),
//           if (isCandle)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: data.isBullish ? Colors.green[50] : Colors.red[50],
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 data.isBullish ? '▲ Bullish' : '▼ Bearish',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: data.isBullish ? Colors.green[700] : Colors.red[700],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             "Loading chart data...",
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _stockName,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.bar_chart_outlined,
//             size: 60,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             "No chart data available",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 40),
//             child: Text(
//               "Historical data for this stock is currently unavailable",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (_) => StockListPage(title: '')),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.black87,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//             child: const Text('Back to Stocks'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCandlestickView() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Chart Container
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey[200]!),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: charts.TimeSeriesChart(
//                   _createOHLCCandleSeries(),
//                   animate: true,
//                   behaviors: [
//                     charts.ChartTitle('Date'),
//                     charts.ChartTitle('Price'),
//                     charts.LinePointHighlighter(
//                       symbolRenderer: CustomCircleSymbolRenderer(),
//                     ),
//                     charts.SelectNearest(
//                       eventTrigger: charts.SelectionTrigger.tap,
//                     ),
//                   ],
//                   selectionModels: [
//                     charts.SelectionModelConfig(
//                       type: charts.SelectionModelType.info,
//                       changedListener: _onSelectionChanged,
//                     ),
//                   ],
//                   defaultRenderer: charts.BarRendererConfig<DateTime>(
//                     groupingType: charts.BarGroupingType.grouped,
//                     strokeWidthPx: 1.0,
//                   ),
//                   domainAxis: const charts.DateTimeAxisSpec(
//                     renderSpec: charts.SmallTickRendererSpec(
//                       labelStyle: charts.TextStyleSpec(
//                         fontSize: 11,
//                         color: charts.MaterialPalette.black,
//                       ),
//                     ),
//                   ),
//                   primaryMeasureAxis: const charts.NumericAxisSpec(
//                     renderSpec: charts.SmallTickRendererSpec(
//                       labelStyle: charts.TextStyleSpec(
//                         fontSize: 11,
//                         color: charts.MaterialPalette.black,
//                       ),
//                     ),
//                   ),
//                   customSeriesRenderers: [
//                     charts.BarRendererConfig<DateTime>(
//                       customRendererId: 'candlestick',
//                       groupingType: charts.BarGroupingType.grouped,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Legend
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 12,
//                 height: 12,
//                 color: Colors.green,
//               ),
//               const SizedBox(width: 6),
//               const Text(
//                 'Bullish',
//                 style: TextStyle(fontSize: 12),
//               ),
//               const SizedBox(width: 16),
//               Container(
//                 width: 12,
//                 height: 12,
//                 color: Colors.red,
//               ),
//               const SizedBox(width: 6),
//               const Text(
//                 'Bearish',
//                 style: TextStyle(fontSize: 12),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Tap on candlesticks for price details',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLineChartView(String title, List<double> values) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Title
//           Text(
//             '$title Price',
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           // Chart Container
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey[200]!),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: charts.TimeSeriesChart(
//                   _createLineChartSeries(values, title),
//                   animate: true,
//                   behaviors: [
//                     charts.ChartTitle('Date'),
//                     charts.ChartTitle('Price'),
//                     charts.LinePointHighlighter(
//                       symbolRenderer: CustomCircleSymbolRenderer(),
//                     ),
//                     charts.SelectNearest(
//                       eventTrigger: charts.SelectionTrigger.tap,
//                     ),
//                   ],
//                   selectionModels: [
//                     charts.SelectionModelConfig(
//                       type: charts.SelectionModelType.info,
//                       changedListener: _onSelectionChanged,
//                     ),
//                   ],
//                   defaultRenderer: charts.LineRendererConfig(
//                     includePoints: true,
//                     strokeWidthPx: 2.0,
//                   ),
//                   domainAxis: const charts.DateTimeAxisSpec(
//                     renderSpec: charts.SmallTickRendererSpec(
//                       labelStyle: charts.TextStyleSpec(
//                         fontSize: 11,
//                         color: charts.MaterialPalette.black,
//                       ),
//                     ),
//                   ),
//                   primaryMeasureAxis: const charts.NumericAxisSpec(
//                     renderSpec: charts.SmallTickRendererSpec(
//                       labelStyle: charts.TextStyleSpec(
//                         fontSize: 11,
//                         color: charts.MaterialPalette.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Tap on the line for $title price details',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildVolumeView() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Title
//           const Text(
//             'Trading Volume',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           // Chart Container
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey[200]!),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: charts.TimeSeriesChart(
//                   _createVolumeSeries(),
//                   animate: true,
//                   behaviors: [
//                     charts.ChartTitle('Date'),
//                     charts.ChartTitle('Volume'),
//                     charts.LinePointHighlighter(
//                       symbolRenderer: CustomCircleSymbolRenderer(),
//                     ),
//                     charts.SelectNearest(
//                       eventTrigger: charts.SelectionTrigger.tap,
//                     ),
//                   ],
//                   selectionModels: [
//                     charts.SelectionModelConfig(
//                       type: charts.SelectionModelType.info,
//                       changedListener: _onSelectionChanged,
//                     ),
//                   ],
//                   defaultRenderer: charts.BarRendererConfig<DateTime>(
//                     groupingType: charts.BarGroupingType.grouped,
//                   ),
//                   domainAxis: const charts.DateTimeAxisSpec(
//                     renderSpec: charts.SmallTickRendererSpec(
//                       labelStyle: charts.TextStyleSpec(
//                         fontSize: 11,
//                         color: charts.MaterialPalette.black,
//                       ),
//                     ),
//                   ),
//                   primaryMeasureAxis: const charts.NumericAxisSpec(
//                     renderSpec: charts.SmallTickRendererSpec(
//                       labelStyle: charts.TextStyleSpec(
//                         fontSize: 11,
//                         color: charts.MaterialPalette.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Legend
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 12,
//                 height: 12,
//                 color: Colors.green,
//               ),
//               const SizedBox(width: 6),
//               const Text(
//                 'Bullish Day Volume',
//                 style: TextStyle(fontSize: 12),
//               ),
//               const SizedBox(width: 16),
//               Container(
//                 width: 12,
//                 height: 12,
//                 color: Colors.red,
//               ),
//               const SizedBox(width: 6),
//               const Text(
//                 'Bearish Day Volume',
//                 style: TextStyle(fontSize: 12),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Tap on bars for volume details',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Custom symbol renderer for better touch feedback
// class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
//   @override
//   void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
//       {List<int>? dashPattern,
//         charts.Color? fillColor,
//         charts.FillPatternType? fillPattern,
//         charts.Color? strokeColor,
//         double? strokeWidthPx}) {
//     super.paint(canvas, bounds,
//         dashPattern: dashPattern,
//         fillColor: charts.Color.white,
//         strokeColor: charts.Color.black,
//         strokeWidthPx: 1);
//   }
// }
//
// // Data Models
// class CandleStickData {
//   final DateTime time;
//   final double open;
//   final double high;
//   final double low;
//   final double close;
//   final bool isBullish;
//
//   CandleStickData(
//       this.time,
//       this.open,
//       this.high,
//       this.low,
//       this.close,
//       this.isBullish,
//       );
// }
//
// class LineChartData {
//   final DateTime time;
//   final double value;
//
//   LineChartData(this.time, this.value);
// }
//
// class VolumeData {
//   final DateTime time;
//   final double value;
//   final bool isBullish;
//
//   VolumeData(this.time, this.value, this.isBullish);
// }
//
// class ChartData {
//   final DateTime time;
//   final double open;
//   final double high;
//   final double low;
//   final double close;
//   final double value;
//   final String chartType;
//   final bool isBullish;
//
//   ChartData({
//     required this.time,
//     required this.open,
//     required this.high,
//     required this.low,
//     required this.close,
//     required this.value,
//     required this.chartType,
//     required this.isBullish,
//   });
// }



import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradingapp/home.dart';
import 'package:tradingapp/viewstock.dart';

void main() {
  runApp(const Viewhigh());
}

class Viewhigh extends StatelessWidget {
  const Viewhigh({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Analysis',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5669F6),
          primary: const Color(0xFF5669F6),
          secondary: const Color(0xFF5CF7FF),
        ),
        useMaterial3: true,
      ),
      home: const View_Stock_Chart(title: 'Stock Analysis'),
    );
  }
}

class View_Stock_Chart extends StatefulWidget {
  const View_Stock_Chart({super.key, required this.title});
  final String title;

  @override
  State<View_Stock_Chart> createState() => _View_Stock_ChartState();
}

class _View_Stock_ChartState extends State<View_Stock_Chart>
    with SingleTickerProviderStateMixin {
  List<String> date_ = [];
  List<double> open_ = [];
  List<double> high_ = [];
  List<double> low_ = [];
  List<double> close_ = [];
  List<double> volume_ = [];
  String _stockName = '';
  bool _isLoading = true;

  // For showing tooltip on tap
  CandleStickData? _selectedCandle;
  String _selectedTab = 'Open';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index == 0
            ? 'Open'
            : _tabController.index == 1
            ? 'High'
            : _tabController.index == 2
            ? 'Low'
            : _tabController.index == 3
            ? 'Close'
            : 'Volume';
        _selectedCandle = null;
      });
    });
    _getStockName();
    _fetchStockDetails();
  }

  Future<void> _getStockName() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? name = sh.getString('name');
    setState(() {
      _stockName = name ?? 'Unknown Stock';
    });
  }

  Future<void> _fetchStockDetails() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String nm = sh.getString('name') ?? '';
      String url = '$urls/stock_details/';

      var data = await http.post(Uri.parse(url), body: {'name': nm});
      var jsondata = json.decode(data.body);

      if (jsondata['status'] == 'ok') {
        var arr = jsondata["data"];

        setState(() {
          date_ = arr.map<String>((e) => e['date'].toString()).toList();
          open_ = arr
              .map<double>((e) => double.tryParse(e['open'].toString()) ?? 0)
              .toList();
          high_ = arr
              .map<double>((e) => double.tryParse(e['high'].toString()) ?? 0)
              .toList();
          low_ = arr
              .map<double>((e) => double.tryParse(e['low'].toString()) ?? 0)
              .toList();
          close_ = arr
              .map<double>((e) => double.tryParse(e['close'].toString()) ?? 0)
              .toList();
          volume_ = arr
              .map<double>((e) => double.tryParse(e['volume'].toString()) ?? 0)
              .toList();
          _isLoading = false;
        });
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch data");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      Fluttertoast.showToast(msg: "Error fetching stock details");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Create candlestick
  List<charts.Series<CandleStickData, DateTime>> _createCandleSeries(
      List<double> values, String chartType) {
    final data = <CandleStickData>[];

    // Calculate average for color coding
    double avg =
    values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : 0;

    // Create fake candlestick data (similar to trading apps)
    for (int i = 0; i < date_.length; i++) {
      final dt = DateTime.tryParse(date_[i]) ?? DateTime.now();
      final value = values[i];

      // For volume, we'll create a simple bar chart
      if (chartType == 'Volume') {
        // Simple bar for volume
        data.add(CandleStickData(
          dt,
          value, // value as "close"
          0, // not used for volume
          value, // value as "low"
          value, // value as "close"
          value,
          chartType,
          value >= avg, // above/below avg for volume
        ));
      } else {
        double candleBody = value * 0.04; // 4% of value for candle body
        double upperWick = value * 0.02; // 2% for upper wick
        double lowerWick = value * 0.02; // 2% for lower wick

        // Bullish candle: close > open
        // Bearish candle: close < open
        bool isBullish = (i % 2 == 0); // Alternate for variety

        double open = isBullish ? value - candleBody/2 : value + candleBody/2;
        double close = isBullish ? value + candleBody/2 : value - candleBody/2;
        double high = value + upperWick;
        double low = value - lowerWick;

        data.add(CandleStickData(
          dt,
          open,
          high,
          low,
          close,
          value,
          chartType,
          isBullish,
        ));
      }
    }

    return [
      charts.Series<CandleStickData, DateTime>(
        id: chartType,
        domainFn: (CandleStickData stock, _) => stock.time,
        measureFn: (CandleStickData stock, _) => stock.low,
        measureUpperBoundFn: (CandleStickData stock, _) => stock.high,
        measureLowerBoundFn: (CandleStickData stock, _) => stock.low,
        data: data,
        // Color coding: Blue for bullish, Red for bearish
        colorFn: (CandleStickData stock, _) => stock.isBullish
            ? charts.MaterialPalette.blue.shadeDefault
            : charts.MaterialPalette.red.shadeDefault,
      )..setAttribute(charts.rendererIdKey, 'candlestick'),
    ];
  }

  void _onSelectionChanged(charts.SelectionModel model) {
    if (model.hasDatumSelection && model.selectedSeries.isNotEmpty) {
      final selectedDatum = model.selectedDatum.first;
      final series = selectedDatum.series;
      final index = selectedDatum.index ?? 0; // FIX: Handle nullable index

      if (index >= 0 && index < series.data.length) {
        setState(() {
          _selectedCandle = series.data[index] as CandleStickData;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Custom Header with Gradient
                Container(
                  padding: const EdgeInsets.only(top: 50, bottom: 20), // Reduced top padding
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
                                    MaterialPageRoute(
                                        builder: (context) => HomePage(title: '')),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Stock Analysis",
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
                                Icons.analytics_rounded,
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
                        child: Column(
                          children: [
                            Text(
                              _stockName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Trading-style candlestick analysis",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Data Point Display (if selected) - Now scrollable when appears
                if (_selectedCandle != null) _buildDataPointCard(),

                // Custom Tab Bar - FIXED to be at top
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          labelColor: const Color(0xFF5669F6),
                          unselectedLabelColor: Colors.grey[600],
                          indicatorColor: const Color(0xFF5669F6),
                          indicatorWeight: 3,
                          indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: const [
                            Tab(text: 'Open'),
                            Tab(text: 'High'),
                            Tab(text: 'Low'),
                            Tab(text: 'Close'),
                            Tab(text: 'Volume'),
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        color: Colors.grey[200],
                      ),
                    ],
                  ),
                ),

                // Content Area - FIXED to have fixed height
                Container(
                  height: MediaQuery.of(context).size.height * 0.6, // Fixed height
                  child: _isLoading
                      ? _buildLoadingState()
                      : date_.isEmpty
                      ? _buildEmptyState()
                      : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Color(0xFFF8FAFF),
                        ],
                      ),
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildChartView('Open', open_),
                        _buildChartView('High', high_),
                        _buildChartView('Low', low_),
                        _buildChartView('Close', close_),
                        _buildChartView('Volume', volume_),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataPointCard() {
    final candle = _selectedCandle!;
    final date = candle.time;
    final formattedDate = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: candle.isBullish ? Colors.blue.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Candle Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCandle = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Date: $formattedDate',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type: ${candle.chartType}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5669F6),
            ),
          ),
          const SizedBox(height: 12),
          if (candle.chartType != 'Volume')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataRow('Open:', candle.open, Colors.orange),
                _buildDataRow('High:', candle.high, Colors.green),
                _buildDataRow('Low:', candle.low, Colors.red),
                _buildDataRow('Close:', candle.close, Colors.blue),
                _buildDataRow('Value:', candle.actualValue, const Color(0xFF5669F6)),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataRow('Volume:', candle.actualValue, const Color(0xFF5669F6)),
              ],
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: candle.isBullish
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  candle.isBullish
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 16,
                  color: candle.isBullish ? Colors.blue : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  candle.isBullish ? 'Bullish Candle' : 'Bearish Candle',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: candle.isBullish ? Colors.blue : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              value.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Container(
        width: 60,
        height: 60,
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
    const SizedBox(height: 20),
    const Text(
    "Loading Stock Data...",
    style: TextStyle(
    fontSize: 16,
    color: Colors.black54,
    fontWeight: FontWeight.w500,
    ),
    ),
    const SizedBox(height: 8),
    Text(
    _stockName,
    style: TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
    ),
    ),
    ],
        ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF5669F6).withOpacity(0.1),
                  const Color(0xFF5CF7FF).withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.bar_chart_outlined,
              size: 60,
              color: Color(0xFF5669F6),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Data Available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Historical data for this stock is currently unavailable",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(title: '')),
              );
            },
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back to Stocks'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5669F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartView(String title, List<double> values) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Chart Title and Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title Chart',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title == 'Volume'
                      ? 'Trading volume over time'
                      : '$title price candlestick chart',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Legend
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildLegendItem(
                      color: Colors.blue,
                      label: 'Bullish (Blue)',
                    ),
                    _buildLegendItem(
                      color: Colors.red,
                      label: 'Bearish (Red)',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Interactive Chart
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: charts.TimeSeriesChart(
                  _createCandleSeries(values, title),
                  animate: true,
                  behaviors: [
                    charts.SeriesLegend(),
                    charts.ChartTitle('Date'),
                    charts.ChartTitle(title),
                    charts.LinePointHighlighter(
                      symbolRenderer: CustomCircleSymbolRenderer(),
                    ),
                    charts.SelectNearest(
                      eventTrigger: charts.SelectionTrigger.tap,
                    ),
                  ],
                  selectionModels: [
                    charts.SelectionModelConfig(
                      type: charts.SelectionModelType.info,
                      changedListener: _onSelectionChanged,
                    ),
                  ],
                  defaultRenderer: charts.BarRendererConfig<DateTime>(
                    groupingType: charts.BarGroupingType.grouped,
                    strokeWidthPx: 1.0,
                  ),
                  domainAxis: const charts.DateTimeAxisSpec(
                    renderSpec: charts.SmallTickRendererSpec(
                      labelStyle: charts.TextStyleSpec(
                        fontSize: 11,
                        color: charts.MaterialPalette.black,
                      ),
                    ),
                  ),
                  primaryMeasureAxis: const charts.NumericAxisSpec(
                    renderSpec: charts.SmallTickRendererSpec(
                      labelStyle: charts.TextStyleSpec(
                        fontSize: 11,
                        color: charts.MaterialPalette.black,
                      ),
                    ),
                  ),
                  customSeriesRenderers: [
                    charts.BarRendererConfig<DateTime>(
                      customRendererId: 'candlestick',
                      groupingType: charts.BarGroupingType.grouped,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Chart Controls Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 16,
                  color: const Color(0xFF5669F6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap any candlestick for details • Pinch to zoom • Drag to pan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Custom symbol renderer for better touch feedback
class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int>? dashPattern,
        charts.Color? fillColor,
        charts.FillPatternType? fillPattern,
        charts.Color? strokeColor,
        double? strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: charts.Color.white,
        strokeColor: charts.Color.black,
        strokeWidthPx: 2);
  }
}

// CandleStick Data Model
class CandleStickData {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double actualValue;
  final String chartType;
  final bool isBullish;

  CandleStickData(
      this.time,
      this.open,
      this.high,
      this.low,
      this.close,
      this.actualValue,
      this.chartType,
      this.isBullish,
      );
}