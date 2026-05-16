// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:tradingapp/Sell_stock.dart';
// import 'buy_stock.dart';
//
// void main() {
//   runApp(const Viewbuy());
// }
//
// class Viewbuy extends StatelessWidget {
//   const Viewbuy({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: StockBuyListPage(title: 'Stocks'),
//     );
//   }
// }
//
// class StockBuyListPage extends StatefulWidget {
//   const StockBuyListPage({Key? key, required String title}) : super(key: key);
//
//   @override
//   State<StockBuyListPage> createState() => _StockBuyListPageState();
// }
//
// class _StockBuyListPageState extends State<StockBuyListPage> {
//   List<Map<String, dynamic>> newsList = [];
//   List<Map<String, dynamic>> filteredNews = [];
//   List<bool> isFavorite = [];
//   bool isLoading = true;
//   TextEditingController searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchNews();
//   }
//
//   Future<void> fetchNews() async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String baseUrl = sh.getString('url') ?? '';
//       String lid = sh.getString('uid') ?? '';
//       String uid = sh.getString('fid').toString();
//       String apiUrl = '$baseUrl/view_buy_stock/';
//
//       var response = await http.post(Uri.parse(apiUrl), body: {
//         'lid': lid,
//         'uid': uid
//       });
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == 'ok') {
//         List<Map<String, dynamic>> tempList = [];
//         for (var item in jsonData['data']) {
//           tempList.add({
//             'id': item['id'].toString(),
//             'Name': item['Name'].toString(),
//             'Stock': item['Stock'].toString(),
//             'Daily P&L': item['daily_pnl'].toString(),
//             'Purchase Price': item['purchase_price'].toString(),
//             'Actual P&L': item['actual_pnl'].toString(),
//             'Total Amount': item['total_amount'].toString(),
//             'Current Price': item['current_price'].toString(),
//             'Current Value': item['current_value'].toString(),
//           });
//         }
//
//         setState(() {
//           newsList = tempList;
//           filteredNews = tempList;
//           isFavorite = List.filled(tempList.length, true);
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Error fetching news: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   void filterNews(String query) {
//     setState(() {
//       filteredNews = newsList;
//     });
//   }
//
//   Widget _buildStockCard(Map<String, dynamic> stock, int index) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             const Color(0xFF5669F6).withOpacity(0.08),
//             const Color(0xFF5CF7FF).withOpacity(0.04),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 15,
//             spreadRadius: 1,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Stock Icon
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       const Color(0xFF5669F6),
//                       const Color(0xFF5CF7FF),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.bar_chart_rounded,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 16),
//
//               // Stock Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       stock['Name'],
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Stock volume: ${stock['Stock']}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     Text(
//                       'Purchase Price: ${stock['Purchase Price']}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     Text(
//                       'Current Price: ${stock['Current Price']}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     Text(
//                       'Daily P&L: ${stock['Daily P&L']}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     Text(
//                       'Actual P&L: ${stock['Actual P&L']}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     Text(
//                       'Total Amount: ${stock['Total Amount']}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     Text(
//                       'Current Value: ${stock['Current Value']}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Sell Button
//               Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.centerLeft,
//                     end: Alignment.centerRight,
//                     colors: [
//                       const Color(0xFF5669F6),
//                       const Color(0xFF5CF7FF),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF5669F6).withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(10),
//                     onTap: () async {
//                       SharedPreferences sh = await SharedPreferences.getInstance();
//                       sh.setString('bid', stock['id'].toString());
//                       sh.setString('s_id', stock['Name'].toString());
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => Sellstock(title: '',)),
//                       );
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             Icons.sell_rounded,
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                           const SizedBox(width: 6),
//                           const Text(
//                             "Sell",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoadingScreen() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   const Color(0xFF5669F6),
//                   const Color(0xFF5CF7FF),
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
//             "Loading Your Stocks...",
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.black54,
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
//           Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.grey.shade100,
//             ),
//             child: const Icon(
//               Icons.inventory_2_outlined,
//               size: 60,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             "No Stocks Found",
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
//               "You haven't bought any stocks yet",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // Custom Header
//           Container(
//             padding: const EdgeInsets.only(top: 50, bottom: 20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   const Color(0xFF5669F6),
//                   const Color(0xFF5CF7FF),
//                 ],
//               ),
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(24),
//                 bottomRight: Radius.circular(24),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF5669F6).withOpacity(0.3),
//                   blurRadius: 15,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: IconButton(
//                           icon: const Icon(
//                             Icons.arrow_back_ios_new_rounded,
//                             size: 20,
//                             color: Colors.white,
//                           ),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ),
//                       Expanded(
//                         child: Center(
//                           child: Text(
//                             "My Stocks",
//                             style: TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Icon(
//                           Icons.account_balance_wallet_rounded,
//                           size: 22,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32),
//                   child: Text(
//                     "View and manage your purchased stocks",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.white.withOpacity(0.9),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Search Bar
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(14),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//                 border: Border.all(
//                   color: Colors.grey.shade200,
//                   width: 1,
//                 ),
//               ),
//               child: TextField(
//                 controller: searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search your stocks...',
//                   hintStyle: TextStyle(color: Colors.grey.shade500),
//                   prefixIcon: Icon(
//                     Icons.search_rounded,
//                     color: Colors.grey.shade500,
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 16),
//                   suffixIcon: searchController.text.isNotEmpty
//                       ? IconButton(
//                     icon: Icon(
//                       Icons.clear_rounded,
//                       color: Colors.grey.shade500,
//                     ),
//                     onPressed: () {
//                       searchController.clear();
//                       filterNews('');
//                     },
//                   )
//                       : null,
//                 ),
//                 onChanged: filterNews,
//               ),
//             ),
//           ),
//
//           // Stock Counter
//           if (!isLoading && filteredNews.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Your Portfolio",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade700,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.centerLeft,
//                         end: Alignment.centerRight,
//                         colors: [
//                           const Color(0xFF5669F6).withOpacity(0.1),
//                           const Color(0xFF5CF7FF).withOpacity(0.1),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       "${filteredNews.length} stocks",
//                       style: TextStyle(
//                         color: const Color(0xFF5669F6),
//                         fontWeight: FontWeight.w600,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//           // Stock List
//           Expanded(
//             child: isLoading
//                 ? _buildLoadingScreen()
//                 : filteredNews.isEmpty
//                 ? _buildEmptyState()
//                 : RefreshIndicator(
//               onRefresh: fetchNews,
//               color: const Color(0xFF5669F6),
//               backgroundColor: Colors.white,
//               strokeWidth: 3.0,
//               displacement: 40.0,
//               child: ListView.builder(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.only(bottom: 20),
//                 itemCount: filteredNews.length,
//                 itemBuilder: (context, index) {
//                   return _buildStockCard(filteredNews[index], index);
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tradingapp/Sell_stock.dart';
import 'buy_stock.dart';

void main() {
  runApp(const Viewbuy());
}

class Viewbuy extends StatelessWidget {
  const Viewbuy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StockBuyListPage(title: 'Stocks'),
    );
  }
}

class StockBuyListPage extends StatefulWidget {
  const StockBuyListPage({Key? key, required String title}) : super(key: key);

  @override
  State<StockBuyListPage> createState() => _StockBuyListPageState();
}

class _StockBuyListPageState extends State<StockBuyListPage> {
  List<Map<String, dynamic>> newsList = [];
  List<Map<String, dynamic>> filteredNews = [];
  List<bool> isFavorite = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String baseUrl = sh.getString('url') ?? '';
      String lid = sh.getString('uid') ?? '';
      String uid = sh.getString('fid').toString();
      String apiUrl = '$baseUrl/view_buy_stock/';

      var response = await http.post(Uri.parse(apiUrl), body: {
        'lid': lid,
        'uid': uid
      });
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id': item['id'].toString(),
            'Name': item['Name'].toString(),
            'Stock': item['Stock'].toString(),
            'Daily P&L': item['daily_pnl'].toString(),
            'Purchase Price': item['purchase_price'].toString(),
            'Actual P&L': item['actual_pnl'].toString(),
            'Total Amount': item['total_amount'].toString(),
            'Current Price': item['current_price'].toString(),
            'Current Value': item['current_value'].toString(),
          });
        }

        setState(() {
          newsList = tempList;
          filteredNews = tempList;
          isFavorite = List.filled(tempList.length, true);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching news: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterNews(String query) {
    setState(() {
      filteredNews = newsList;
    });
  }

  Widget _buildStockCard(Map<String, dynamic> stock, int index) {
    double dailyPnl = double.tryParse(stock['Daily P&L'] ?? '0') ?? 0;
    double actualPnl = double.tryParse(stock['Actual P&L'] ?? '0') ?? 0;

    // Determine colors based on P&L values
    bool dailyIsProfit = dailyPnl >= 0;
    bool actualIsProfit = actualPnl >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            actualIsProfit ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
            const Color(0xFF5CF7FF).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: actualIsProfit ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Stock Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: actualIsProfit
                        ? [Colors.green, Colors.lightGreen]
                        : [Colors.red, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  actualIsProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Stock Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock['Name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stock volume: ${stock['Stock']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Purchase Price: ${stock['Purchase Price']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Current Price: ${stock['Current Price']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Daily P&L: ${stock['Daily P&L']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: dailyIsProfit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Actual P&L: ${stock['Actual P&L']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: actualIsProfit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Total Amount: ${stock['Total Amount']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Current Value: ${stock['Current Value']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Sell Button
              Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF5669F6),
                      const Color(0xFF5CF7FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
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
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      SharedPreferences sh = await SharedPreferences.getInstance();
                      sh.setString('bid', stock['id'].toString());
                      sh.setString('s_id', stock['Name'].toString());
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Sellstock(title: '',)),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sell_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Sell",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
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
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF5669F6),
                  const Color(0xFF5CF7FF),
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
            "Loading Your Stocks...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
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
              color: Colors.grey.shade100,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Stocks Found",
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
              "You haven't bought any stocks yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
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
                            "My Stocks",
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
                          Icons.account_balance_wallet_rounded,
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
                    "View and manage your purchased stocks",
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

          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search your stocks...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: Colors.grey.shade500,
                    ),
                    onPressed: () {
                      searchController.clear();
                      filterNews('');
                    },
                  )
                      : null,
                ),
                onChanged: filterNews,
              ),
            ),
          ),

          // Stock Counter
          if (!isLoading && filteredNews.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Portfolio",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xFF5669F6).withOpacity(0.1),
                          const Color(0xFF5CF7FF).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${filteredNews.length} stocks",
                      style: TextStyle(
                        color: const Color(0xFF5669F6),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Stock List
          Expanded(
            child: isLoading
                ? _buildLoadingScreen()
                : filteredNews.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: fetchNews,
              color: const Color(0xFF5669F6),
              backgroundColor: Colors.white,
              strokeWidth: 3.0,
              displacement: 40.0,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: filteredNews.length,
                itemBuilder: (context, index) {
                  return _buildStockCard(filteredNews[index], index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}