import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradingapp/changepassword.dart';
import 'package:tradingapp/sendcompliant.dart';
import 'package:tradingapp/sendfeedback.dart';
import 'package:tradingapp/ulogin.dart';
import 'package:tradingapp/view_news.dart';
import 'package:tradingapp/view_notifications.dart';
import 'package:tradingapp/view_reply.dart';
import 'package:tradingapp/view_video.dart';
import 'package:tradingapp/viewbuystock.dart';
import 'package:tradingapp/viewfavourite.dart';
import 'package:tradingapp/viewprofile.dart';
import 'package:tradingapp/viewstock.dart';
import 'package:tradingapp/wallet.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApphome());
}

class MyApphome extends StatelessWidget {
  const MyApphome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexTrade',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'NexTrade'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _userPhoto = '';
  String _userName = '';
  DateTime? lastBackPressed;

  static const List<Widget> _pages = <Widget>[
    StockListPage(title: ''),
    // StockFavListPage(title: ''),
    StockListPage(title: ''),
    VideoListScreen(title: ''),
    Walletview(title: ''),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final imgUrl = prefs.getString('img_url') ?? '';


    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String uid = sh.getString('uid').toString();
    String img_url = sh.getString('img_url').toString();

    final urls = Uri.parse('$url/user_viewprofile/');
    try {
      final response = await http.post(urls, body: {
        'uid': uid
      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {

          String photo = img_url + jsonDecode(response.body)['photo'].toString();

          _userName = 'User';
          setState(() {

            _userPhoto = photo;
          });

        } else {
          Fluttertoast.showToast(msg: 'Not Found');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }




  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed:() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserLogin(title: '')),
              );
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Ulgoginpage()),
                    (route) => false,
              );
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();

        if (lastBackPressed == null ||
            now.difference(lastBackPressed!) > Duration(seconds: 2)) {
          lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Double tap back to exit",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 40, left: 16, right: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
          );
          return false;
        }

        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 70,
          title: const Text(
            'NexTrade',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
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
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          actions: [
            // Profile picture
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewProfile(title: 'Profile')),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white.withOpacity(0.2),
                ),
                child: ClipOval(
                  child: _userPhoto.isNotEmpty
                      ? Image.network(
                    _userPhoto,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 24,
                      );
                    },
                  )
                      : const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            // Logout button instead of search
            IconButton(
              icon: const Icon(Icons.logout_outlined, color: Colors.white, size: 28,shadows: [Shadow(color: Color(0xFF5669F6),blurRadius: 0.9)],),
              onPressed: () => _logout(context),
              tooltip: 'Logout',
            ),
          ],
        ),

        body: Column(
          children: [
            if (_selectedIndex == 0) //qab to show only in home
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF5669F6),
                          const Color(0xFF5CF7FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _quickActionButton(
                            icon: Icons.account_balance_wallet_outlined,
                            label: "Portfolio",
                            color: Colors.white,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => StockFavListPage(title: '')),
                              );
                            },
                          ),
                          _quickActionButton(
                            icon: Icons.newspaper_outlined,
                            label: "News",
                            color: Colors.white,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => NewsListScreen(title: '')),
                              );
                            },
                          ),
                          _quickActionButton(
                            icon: Icons.notification_important_outlined,
                            label: "Notification",
                            color: Colors.white,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Vnotifications()),
                            ),
                          ),
                          _quickActionButton(
                            icon: Icons.person_outline,
                            label: "Profile",
                            color: Colors.white,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Profile()),
                            ),
                          ),
                          _quickActionButton(
                            icon: Icons.lock_reset_outlined,
                            label: "Change Pass..",
                            color: Colors.white,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ChangePswd()),
                            ),
                          ),
                          _quickActionButton(
                            icon: Icons.feedback_outlined,
                            label: "Feedback",
                            color: Colors.white,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SFeedback(title: '',)),
                            ),
                          ),
                          _quickActionButton(
                            icon: Icons.report_gmailerrorred,
                            label: "Complaint",
                            color: Colors.white,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Scomplaint()),
                            ),
                          ),
                          _quickActionButton(
                            icon: Icons.reply_outlined,
                            label: "Reply",
                            color: Colors.white,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => viewreply(title: '')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // Main Content Area
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ],
        ),

        bottomNavigationBar: NavigationBar(
          height: 65,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 4,
          indicatorColor: const Color(0xFF5669F6).withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 26),
              selectedIcon: Icon(Icons.home_rounded, size: 26, color: Color(0xFF5669F6)),
              label: 'Home',
            ),
            // NavigationDestination(
            //   icon: Icon(Icons.account_balance_wallet_outlined, size: 26),
            //   selectedIcon: Icon(Icons.account_balance_wallet_rounded, size: 26, color: Color(0xFF5669F6)),
            //   label: 'Portfolio',
            // ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, size: 26),
              selectedIcon: Icon(Icons.bar_chart_rounded, size: 26, color: Color(0xFF5669F6)),
              label: 'Stocks',
            ),
            NavigationDestination(
              icon: Icon(Icons.video_collection_outlined, size: 26),
              selectedIcon: Icon(Icons.video_collection_rounded, size: 26, color: Color(0xFF5669F6)),
              label: 'Lessons',
            ),
            NavigationDestination(
              icon: Icon(Icons.wallet_outlined, size: 26),
              selectedIcon: Icon(Icons.wallet_rounded, size: 26, color: Color(0xFF5669F6)),
              label: 'Wallet',
            ),
          ],
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}