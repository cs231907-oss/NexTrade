import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradingapp/buy_stock.dart';
import 'package:tradingapp/stock_chart.dart';
import 'package:tradingapp/view_prediction.dart';

class StockListPage extends StatefulWidget {
  const StockListPage({super.key, required this.title});
  final String title;

  @override
  State<StockListPage> createState() => _StockListPageState();
}

class _StockListPageState extends State<StockListPage> {
  List<bool> isFavorite = [];
  List<String> name_ = <String>[];
  List<String> a_ = <String>[];
  List<String> price_ = <String>[];
  List<String> prevclose_ = <String>[];
  bool _isLoading = true;
  String _searchQuery = '';
  List<String> _filteredNames = [];

  @override
  void initState() {
    super.initState();
    _fetchStockData();
  }

  Future<void> _fetchStockData() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? urls = sh.getString('url');
      String? uid = sh.getString('uid');
      if (urls == null) {
        throw Exception("Base URL is null in SharedPreferences");
      }
      String url = '$urls/allstock/';

      var response = await http.post(
        Uri.parse(url),
        body: {
          'uid':uid
        },
      );

      String bodyRaw = response.body;
      String cleaned = bodyRaw
          .replaceAll('NaN', 'null')
          .replaceAll('\uFEFF', '')
          .trim();

      dynamic decoded = json.decode(cleaned);

      if (decoded is Map<String, dynamic>) {
        String status = decoded['status']?.toString() ?? '';
        if (status.toLowerCase() != 'ok') {
          Fluttertoast.showToast(msg: 'Status not OK: $status');
        }


        var arr = decoded['data'];
        if (arr is List) {
          List<String> names = [];
          List<String> as = [];
          List<String> prices = [];
          List<String> prevclosed = [];
          for (var item in arr) {
            if (item is Map<String, dynamic>) {
              String nm = item['name']?.toString() ?? '';
              String a = item['a']?.toString() ?? '';
              String price = item['price']?.toString() ?? '';
              String prevclose = item['prev_close']?.toString() ?? '';
              //to activate the favourite for those are true
              String favorite=item['is_favorite'].toString();

              if(favorite == "yes")
                {
                  isFavorite.add(true);
                }
              else{
                isFavorite.add(false);
              }

              names.add(nm);
              as.add(a);
              prices.add(price);
              prevclosed.add(prevclose);

            }
            // isFavorite = List.filled(names.length, false);

          }

          setState(() {
            name_ = names;
            a_ = as;
            price_=prices;
            prevclose_=prevclosed;
            isFavorite=isFavorite;
            _filteredNames = List.from(names);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: "Error loading stocks");
    }
  }

  void _filterStocks(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredNames = List.from(name_);
      } else {
        _filteredNames = name_
            .where((name) => name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
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
              child: TextField(
                onChanged: _filterStocks,
                decoration: InputDecoration(
                  hintText: 'Search stocks...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.close_rounded, size: 20),
                    onPressed: () => _filterStocks(''),
                  )
                      : null,
                ),
              ),
            ),
          ),
          ElevatedButton(onPressed: () {

            _fetchStockData();

          }, child: Text("Refresh")),

          // Results count
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '${_filteredNames.length} results found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Stock List
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredNames.isEmpty
                ? _buildEmptyState()
                : _buildStockList(),
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
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5669F6)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading stocks...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
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
          Icon(
            Icons.bar_chart_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No stocks found' : 'No stocks available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Check back later for updates'
                : 'Try a different search term',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 20),
          if (_searchQuery.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => _filterStocks(''),
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
    );
  }

  Widget _buildStockList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(16),
      itemCount: _filteredNames.length,
      itemBuilder: (context, index) {
        final originalIndex = name_.indexOf(_filteredNames[index]);
        return _buildStockCard(originalIndex);
      },
    );
  }

  Widget _buildStockCard(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                            name_[index],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Stock Price: "+price_[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                           "Previous Day Price: "+ prevclose_[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),

                          double.parse(prevclose_[index]) < double.parse(price_[index])? Text("You can sell this",style: TextStyle(color: Colors.red),) : Text("You can buy this",style: TextStyle(color: Colors.green),),

                          Text(
                            'Stock Symbol',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Text(isFavorite[index].toString()),
                    // Favorite Button
                    GestureDetector(
                      onTap:() {

                        if(isFavorite[index] == true)
                          {
                            Fluttertoast.showToast(msg: "Already added in favourite");
                          }
                          else {
                          _toggleFavorite(index);
                        }
                      },
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        child: Container(
                          key: ValueKey(isFavorite[index]),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isFavorite[index] == "yes"
                                ? Colors.red.withOpacity(0.9)
                                : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite[index]
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite[index] ? Colors.red : Colors.grey[600],
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Quick Actions Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(
                      Icons.analytics_outlined,
                      'Details',
                      Color(0xFF5669F6),
                          () => _navigateToChart(index),
                    ),
                    _buildActionButton(
                      Icons.trending_up_rounded,
                      'Predict',
                      Colors.orange,
                          () => _navigateToPrediction(index),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2),
        child: Material(
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
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Future<void> _toggleFavorite(int index) async {
    bool previousState = isFavorite[index];
    setState(() {
      isFavorite[index] = !isFavorite[index];
    });

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('uid');

    if (url == null || lid == null) {
      Fluttertoast.showToast(msg: "Login required");
      setState(() {
        isFavorite[index] = previousState;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$url/favstock/'),
        body: {'lid': lid, 'name': name_[index]},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] != 'ok') {
          setState(() {
            isFavorite[index] = previousState;
          });
          Fluttertoast.showToast(msg: "Failed to update favorites");
        } else {
          Fluttertoast.showToast(
            msg: isFavorite[index]
                ? "Added to favorites ❤️"
                : "Removed from favorites 💔",
          );
        }
      } else {
        setState(() {
          isFavorite[index] = previousState;
        });
        Fluttertoast.showToast(msg: "Network Error");
      }
    } catch (e) {
      setState(() {
        isFavorite[index] = previousState;
      });
      Fluttertoast.showToast(msg: "Connection error");
    }
  }

  Future<void> _navigateToChart(int index) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    sh.setString("name", name_[index]);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => View_Stock_Chart(title: '')),
    );
  }

  Future<void> _navigateToBuyStock(int index) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    sh.setString("name", name_[index]);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Buystock()),
    );
  }

  Future<void> _navigateToPrediction(int index) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    sh.setString("name", name_[index]);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => stockPrediction()),
    );
  }
}