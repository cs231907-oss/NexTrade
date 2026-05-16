import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tradingapp/view_sellstock.dart';
import 'package:tradingapp/viewbuystock.dart';
import 'package:tradingapp/buy_stock.dart';
import 'package:tradingapp/viewsellstock.dart';

void main() {
  runApp(const Viewfav());
}

class Viewfav extends StatelessWidget {
  const Viewfav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StockFavListPage(title: 'Favorites'),
    );
  }
}

class StockFavListPage extends StatefulWidget {
  const StockFavListPage({Key? key, required String title}) : super(key: key);

  @override
  State<StockFavListPage> createState() => _StockFavListPageState();
}

class _StockFavListPageState extends State<StockFavListPage> {
  List<Map<String, dynamic>> favList = [];
  List<Map<String, dynamic>> filteredFav = [];
  List<bool> isFavorite = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFav();
  }

  Future<void> fetchFav() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String baseUrl = sh.getString('url') ?? '';
      String lid = sh.getString('uid') ?? '';
      String apiUrl = '$baseUrl/viewfav_stocks/';

      var response = await http.post(Uri.parse(apiUrl), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'name': item['name'].toString(),
            'id': item['id'].toString(),
            'is_favorite': item['is_favorite'].toString(),
            'price': item['price'].toString(),
            'prev_close': item['prev_close'].toString()
          });
        }

        setState(() {
          favList = tempList;
          filteredFav = tempList;
          isFavorite = List.filled(tempList.length, true);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'No favorite stocks found');
      }
    } catch (e) {
      print("Error fetching fav: $e");
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Error loading favorites');
    }
  }

  void filterFav(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFav = List.from(favList);
      } else {
        filteredFav = favList
            .where((item) => item['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> removeFavorite(int index) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String baseUrl = sh.getString('url') ?? '';
      String apiUrl = '$baseUrl/remove_fav_stock/';

      var response = await http.post(Uri.parse(apiUrl), body: {
        'id': filteredFav[index]['id'].toString(),
      });

      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'ok') {
        Fluttertoast.showToast(msg: 'Removed from favorites 💔');
        fetchFav();
      } else {
        Fluttertoast.showToast(msg: 'Failed to remove');
      }
    } catch (e) {
      print("Error removing favorite: $e");
      Fluttertoast.showToast(msg: 'Network error');
    }
  }

  void _clearSearch() {
    searchController.clear();
    filterFav('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'Favorite Stocks',
      //     style: TextStyle(
      //       fontSize: 20,
      //       fontWeight: FontWeight.w600,
      //       color: Colors.white,
      //     ),
      //   ),
      //   centerTitle: true,
      //   flexibleSpace: Container(
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //         colors: [
      //           const Color(0xFF5669F6),
      //           const Color(0xFF00F0FF),
      //         ],
      //       ),
      //       borderRadius: const BorderRadius.only(
      //         bottomLeft: Radius.circular(20),
      //         bottomRight: Radius.circular(20),
      //       ),
      //     ),
      //   ),
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_ios_new_rounded,color: Colors.white,size: 22),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.refresh_rounded,color: Colors.white,size: 24,shadows: [Shadow(color: Colors.black,blurRadius: 0.5)],),
      //       onPressed: fetchFav,
      //       tooltip: 'Refresh',
      //     ),
      //   ],
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00CBFF).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
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
                              "Portfolio",
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
                      "View your favourite stocks, make your transactions and manage",
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search favorite stocks...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        onChanged: filterFav,
                      ),
                    ),
                    if (searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.close_rounded, size: 18),
                        onPressed: _clearSearch,
                      ),
                  ],
                ),
              ),
            ),

            // Results Count
            if (searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      '${filteredFav.length} ${filteredFav.length == 1 ? 'result' : 'results'} found',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // Loading State
            if (isLoading) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5669F6)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading favorites...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
            // Empty State
            else if (filteredFav.isEmpty) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        searchController.text.isEmpty
                            ? 'No favorite stocks yet'
                            : 'No matches found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        searchController.text.isEmpty
                            ? 'Add stocks to your favorites to see them here'
                            : 'Try a different search term',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      if (searchController.text.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: _clearSearch,
                          icon: Icon(Icons.close_rounded, size: 16),
                          label: Text('Clear search'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5669F6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ]
            // List of Favorites
            else ...[
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    itemCount: filteredFav.length,
                    itemBuilder: (context, index) {
                      final fav = filteredFav[index];
                      final originalIndex = favList.indexWhere((item) => item['id'] == fav['id']);

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stock Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fav['name'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Stock Price: ${fav['price']}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Previous day price: ${fav['prev_close']}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          double.parse(fav['prev_close']) < double.parse(fav['price'])? Text("You can sell this",style: TextStyle(color: Colors.red),) : Text("You can buy this",style: TextStyle(color: Colors.green),),
                                          Text(
                                            'Stock ID: ${fav['id']}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Favorite Button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.favorite_rounded,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: (){}
                                            // _showRemoveConfirmation(context, index),
                                        // tooltip: 'Remove from favorites',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildActionButton(
                                        Icons.remove_red_eye_rounded,
                                        'View Buys',
                                        Color(0xFF5669F6),
                                            () => _navigateToBuyList(fav),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: _buildActionButton(
                                        Icons.remove_red_eye_rounded,
                                        'View Sold',
                                        Color(0xFF5669F6),
                                            () async{
                                          SharedPreferences sh=await SharedPreferences.getInstance();
                                          sh.setString('fid', fav['id'].toString());
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>VStockSellListPage(title: '')));
                                            },
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: _buildActionButton(
                                        Icons.add_circle_outline_rounded,
                                        'Add More',
                                        Colors.green,
                                            () => _navigateToBuyStock(fav),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color.withOpacity(0.08),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: color),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToBuyList(Map<String, dynamic> fav) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    sh.setString('fid', fav['id'].toString());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StockBuyListPage(title: '')),
    );
  }

  Future<void> _navigateToBuyStock(Map<String, dynamic> fav) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    sh.setString("fid", fav['id']);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Buystock()),
    );
  }

  void _showRemoveConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 12),
              Text(
                'Remove Favorite',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove "${filteredFav[index]['name']}" from your favorites?',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                removeFavorite(index);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}