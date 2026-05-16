// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// void main() {
//   runApp(const Viewsell());
// }
//
// class Viewsell extends StatelessWidget {
//   const Viewsell({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: StockSellListPage(title: 'Sold Stocks'),
//     );
//   }
// }
//
// class StockSellListPage extends StatefulWidget {
//   const StockSellListPage({Key? key, required String title}) : super(key: key);
//
//   @override
//   State<StockSellListPage> createState() => _StockSellListPageState();
// }
//
// class _StockSellListPageState extends State<StockSellListPage> {
//   List<Map<String, dynamic>> stockList = [];
//   List<Map<String, dynamic>> filteredStocks = [];
//   bool isLoading = true;
//   TextEditingController searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchSoldStocks();
//   }
//
//   Future<void> fetchSoldStocks() async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String baseUrl = sh.getString('url') ?? '';
//       String lid = sh.getString('uid') ?? '';
//       String sid = sh.getString('s_id')?.toString() ?? '';
//
//       print('User ID: $lid');
//       print('Stock ID: $sid');
//
//       String apiUrl = '$baseUrl/view_sell_stock/';
//
//       var response = await http.post(Uri.parse(apiUrl), body: {
//         'uid': lid,
//         'sid': sid,
//       });
//
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == 'ok') {
//         List<Map<String, dynamic>> tempList = [];
//         for (var item in jsonData['data']) {
//           tempList.add({
//             'id': item['id'].toString(),
//             'Name': item['Name'].toString(),
//             'Stock': item['Stock'].toString(),
//             'Daily P&l': item['daily_pnl'].toString(),
//             'Actual P&L': item['actual_pnl'].toString(),
//             'Total Amount': item['total_amount'].toString(),
//             'Sell Price': item['sell_price'].toString(),
//           });
//         }
//
//         print('Parsed stocks: $tempList');
//
//         setState(() {
//           stockList = tempList;
//           filteredStocks = tempList;
//           isLoading = false;
//         });
//       } else {
//         print('Status not ok: ${jsonData['status']}');
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Error fetching sold stocks: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   void filterStocks(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         filteredStocks = List.from(stockList);
//       } else {
//         filteredStocks = stockList
//             .where((stock) =>
//             stock['Name'].toString().toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//     });
//   }
//
//   Widget _buildStockCard(Map<String, dynamic> stock, int index) {
//     double loss = double.tryParse(stock['Loss'] ?? '0') ?? 0;
//     double profit = double.tryParse(stock['Profit'] ?? '0') ?? 0;
//     bool hasProfit = profit > 0;
//     bool hasLoss = loss > 0;
//
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             hasProfit ? Colors.green.withOpacity(0.08) :
//             hasLoss ? Colors.red.withOpacity(0.08) :
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
//         border: Border.all(
//           color: hasProfit ? Colors.green.withOpacity(0.2) :
//           hasLoss ? Colors.red.withOpacity(0.2) :
//           Colors.grey.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Stock Icon with status
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: hasProfit
//                         ? [Colors.green, Colors.lightGreen]
//                         : hasLoss
//                         ? [Colors.red, Colors.orange]
//                         : [
//                       const Color(0xFF5669F6),
//                       const Color(0xFF5CF7FF),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   hasProfit ? Icons.trending_up_rounded :
//                   hasLoss ? Icons.trending_down_rounded :
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
//                       stock['Name'] ?? 'Unknown Stock',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Quantity: ${stock['Stock']} shares',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade700,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Sell Price: ${stock['Sell Price']}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     Text(
//                       'Daily P&l: ${stock['Daily P&l']}',
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
//                   ],
//                 ),
//               ),
//
//               // Status Indicator
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: hasProfit
//                           ? Colors.green.withOpacity(0.1)
//                           : hasLoss
//                           ? Colors.red.withOpacity(0.1)
//                           : Colors.grey.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       hasProfit ? 'PROFIT' : hasLoss ? 'LOSS' : 'SOLD',
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                         color: hasProfit
//                             ? Colors.green
//                             : hasLoss
//                             ? Colors.red
//                             : Colors.grey,
//                         letterSpacing: 1,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Sold',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
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
//             "Loading Sold Stocks...",
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
//             "No Sold Stocks Found",
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
//               "You haven't sold any stocks yet",
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
//               Navigator.pop(context);
//             },
//             icon: const Icon(Icons.shopping_bag_rounded),
//             label: const Text('Go to Buy Stocks'),
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
//                             "Sold Stocks",
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
//                           Icons.sell_rounded,
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
//                     "View your sold stocks performance",
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
//           // Search Bar (only show if there are stocks)
//           if (!isLoading && stockList.isNotEmpty)
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(14),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                   border: Border.all(
//                     color: Colors.grey.shade200,
//                     width: 1,
//                   ),
//                 ),
//                 child: TextField(
//                   controller: searchController,
//                   decoration: InputDecoration(
//                     hintText: 'Search sold stocks...',
//                     hintStyle: TextStyle(color: Colors.grey.shade500),
//                     prefixIcon: Icon(
//                       Icons.search_rounded,
//                       color: Colors.grey.shade500,
//                     ),
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(vertical: 16),
//                     suffixIcon: searchController.text.isNotEmpty
//                         ? IconButton(
//                       icon: Icon(
//                         Icons.clear_rounded,
//                         color: Colors.grey.shade500,
//                       ),
//                       onPressed: () {
//                         searchController.clear();
//                         filterStocks('');
//                       },
//                     )
//                         : null,
//                   ),
//                   onChanged: filterStocks,
//                 ),
//               ),
//             ),
//
//           // Stock Counter
//           if (!isLoading && filteredStocks.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Sold Stocks",
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
//                       "${filteredStocks.length} stocks",
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
//                 : filteredStocks.isEmpty
//                 ? _buildEmptyState()
//                 : RefreshIndicator(
//               onRefresh: fetchSoldStocks,
//               color: const Color(0xFF5669F6),
//               backgroundColor: Colors.white,
//               strokeWidth: 3.0,
//               displacement: 40.0,
//               child: ListView.builder(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.only(bottom: 20),
//                 itemCount: filteredStocks.length,
//                 itemBuilder: (context, index) {
//                   return _buildStockCard(filteredStocks[index], index);
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

void main() {
  runApp(const Viewsell());
}

class Viewsell extends StatelessWidget {
  const Viewsell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StockSellListPage(title: 'Sold Stocks'),
    );
  }
}

class StockSellListPage extends StatefulWidget {
  const StockSellListPage({Key? key, required String title}) : super(key: key);

  @override
  State<StockSellListPage> createState() => _StockSellListPageState();
}

class _StockSellListPageState extends State<StockSellListPage> {
  List<Map<String, dynamic>> stockList = [];
  List<Map<String, dynamic>> filteredStocks = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSoldStocks();
  }

  Future<void> fetchSoldStocks() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String baseUrl = sh.getString('url') ?? '';
      String lid = sh.getString('uid') ?? '';
      String sid = sh.getString('s_id')?.toString() ?? '';

      print('User ID: $lid');
      print('Stock ID: $sid');

      String apiUrl = '$baseUrl/view_sell_stock/';

      var response = await http.post(Uri.parse(apiUrl), body: {
        'uid': lid,
        'sid': sid,
      });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id': item['id'].toString(),
            'Name': item['Name'].toString(),
            'Stock': item['Stock'].toString(),
            'Daily P&l': item['daily_pnl'].toString(),
            'Actual P&L': item['actual_pnl'].toString(),
            'Total Amount': item['total_amount'].toString(),
            'Sell Price': item['sell_price'].toString(),
          });
        }

        print('Parsed stocks: $tempList');

        setState(() {
          stockList = tempList;
          filteredStocks = tempList;
          isLoading = false;
        });
      } else {
        print('Status not ok: ${jsonData['status']}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching sold stocks: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterStocks(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStocks = List.from(stockList);
      } else {
        filteredStocks = stockList
            .where((stock) =>
            stock['Name'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Widget _buildStockCard(Map<String, dynamic> stock, int index) {
    double dailyPnl = double.tryParse(stock['Daily P&l'] ?? '0') ?? 0;
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
              // Stock Icon with status
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
                      stock['Name'] ?? 'Unknown Stock',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantity: ${stock['Stock']} shares',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sell Price: ${stock['Sell Price']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Daily P&l: ${stock['Daily P&l']}',
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
                  ],
                ),
              ),

              // Status Indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: actualIsProfit
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      actualIsProfit ? 'PROFIT' : 'LOSS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: actualIsProfit ? Colors.green : Colors.red,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sold',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
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
            "Loading Sold Stocks...",
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
            "No Sold Stocks Found",
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
              "You haven't sold any stocks yet",
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
              Navigator.pop(context);
            },
            icon: const Icon(Icons.shopping_bag_rounded),
            label: const Text('Go to Buy Stocks'),
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
                            "Sold Stocks",
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
                          Icons.sell_rounded,
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
                    "View your sold stocks performance",
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

          // Search Bar (only show if there are stocks)
          if (!isLoading && stockList.isNotEmpty)
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
                    hintText: 'Search sold stocks...',
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
                        filterStocks('');
                      },
                    )
                        : null,
                  ),
                  onChanged: filterStocks,
                ),
              ),
            ),

          // Stock Counter
          if (!isLoading && filteredStocks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sold Stocks",
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
                      "${filteredStocks.length} stocks",
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
                : filteredStocks.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: fetchSoldStocks,
              color: const Color(0xFF5669F6),
              backgroundColor: Colors.white,
              strokeWidth: 3.0,
              displacement: 40.0,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: filteredStocks.length,
                itemBuilder: (context, index) {
                  return _buildStockCard(filteredStocks[index], index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}