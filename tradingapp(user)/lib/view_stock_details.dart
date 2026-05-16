import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradingapp/home.dart';


void main() {
  runApp(const Viewhigh());
}

class Viewhigh extends StatelessWidget {
  const Viewhigh({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'View Stock Details',
      theme: ThemeData(
        colorScheme:
        ColorScheme.fromSeed(seedColor: Color.fromARGB(207, 97, 161, 156),),
        useMaterial3: true,
      ),
      home: const ViewStockDetails(title: ''),
    );
  }
}

class ViewStockDetails extends StatefulWidget {
  const ViewStockDetails({super.key, required this.title});

  final String title;

  @override
  State<ViewStockDetails> createState() => _ViewStockDetailsState();
}

class _ViewStockDetailsState extends State<ViewStockDetails> {
  _ViewStockDetailsState() {
    Viewhigh();
  }

  List<String> date_ = <String>[];
  List<String> open_ = <String>[];
  List<String> high_ = <String>[];
  List<String> low_ = <String>[];
  List<String> close_ = <String>[];
  List<String> volume_ = <String>[];

  Future<void> Viewhigh() async {
    List<String> date = <String>[];
    List<String> open = <String>[];
    List<String> high = <String>[];
    List<String> low = <String>[];
    List<String> close = <String>[];
    List<String> volume = <String>[];

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      String nm = sh.getString('name').toString();
      String url = '$urls/stock_details/';

      var data = await http.post(Uri.parse(url), body: {'name':nm});
      var jsondata = json.decode(data.body);
      String statuss = jsondata['status'];

      var arr = jsondata["data"];

      print(arr.length);

      for (int i = 0; i < arr.length; i++) {
        date.add(arr[i]['date'].toString());
        open.add(arr[i]['open'].toString());
        high.add(arr[i]['high'].toString());
        low.add(arr[i]['low'].toString());
        close.add(arr[i]['close'].toString());
        volume.add(arr[i]['volume'].toString());
      }

      setState(() {
        date_ = date;
        open_ = open;
        high_ = high;
        low_ = low;
        close_ = close;
        volume_ = volume;
      });

      print(statuss);
    } catch (e) {
      print("Error ------------------- " + e.toString());
      //there is error during converting file image to base64 encoding.
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(title: 'NexTrade',)),
        );
        return true;
      },
      child: Scaffold(
        body:
        ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: date_.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 8,
              margin: EdgeInsets.all(10),
              child: ListTile(
                onLongPress: () {
                  print("Long press " + index.toString());
                },
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(children: [Text("Date: ${date_[index]}")]),

                    Row(children:[Text("Open: ${open_[index]}")] ),

                    Row(children:[Text("High: ${high_[index]}")] ),

                  Row(children: [Text("Low: ${low_[index]}")]),

                     Row(children:[Text("Close: ${close_[index]}")] ),

                   Row(children:[Text("Volume: ${volume_[index]}")] ),


                    // ListTile(
                    //   contentPadding: EdgeInsets.all(10),
                    //   title: Text("high: ${high_[index]}"),
                    // ),
                  ],
                ),
              ),
            );
          },
        ),
        // ListView.builder(
        //   physics: BouncingScrollPhysics(),
        //   // padding: EdgeInsets.all(5.0),
        //   // shrinkWrap: true,
        //   itemCount: id_.length,
        //   itemBuilder: (BuildContext context, int index) {
        //     return ListTile(
        //       onLongPress: () {
        //         print("long press" + index.toString());
        //       },
        //       title: Padding(
        //           padding: const EdgeInsets.all(7),
        //           child: Column(
        //             children: [
        //               Card(
        //                 child: Row(children: [
        //                   Column(
        //                     children: [
        //                       SizedBox(height: 3,),
        //                       Padding(
        //                         padding: EdgeInsets.all(10),
        //                         child: Row(
        //                           children: [
        //                             Text("Date :"),
        //                             SizedBox(height: 3,width: 30,),
        //                             Text(date_[index]),
        //                           ],
        //                         ),
        //                       ),
        //                       Padding(padding: EdgeInsets.all(10),child: Row(children: [
        //                         SizedBox(height: 15,
        //                           width: 70,
        //                           child:
        //                           Text("high :"),
        //                         ),
        //
        //                         Row(
        //                           mainAxisAlignment: MainAxisAlignment.center,
        //                           children: [
        //                             // SizedBox.fromSize(6),
        //                             Text(high_[index]),
        //                           ],
        //                         ),
        //                       ],),),
        //                       // Padding(
        //                       //     padding: EdgeInsets.all(5),
        //                       //     child: Row(
        //                       //       children: [
        //                       //         Text("high :"),
        //                       //         SizedBox(height: 3,width: 30,),
        //                       //         Text(high_[index]),
        //                       //       ],
        //                       //     )),
        //                       // lowBarIndicator(
        //                       //   itemBuilder: (context, index) => Icon(
        //                       //     Icons.star,
        //                       //     color: Colors.amber,
        //                       //   ),
        //                       //   itemCount: 5,
        //                       //   itemSize: 35,
        //                       //   low: double.parse(lows[index]),
        //                       // ),
        //                       Padding(
        //                           padding: EdgeInsets.all(5),
        //                           child: Row(
        //                             children: [
        //                               Text("low :"),
        //                               SizedBox(height: 3,width: 30,),
        //                               lowBarIndicator(
        //                                 itemBuilder: (context, index) => Icon(
        //                                   Icons.star,
        //                                   color: Colors.amber,
        //                                 ),
        //                                 itemCount: 5,
        //                                 itemSize: 35,
        //                                 low: double.parse(low_[index]),
        //                               ),
        //                               // Text(low_[index]),
        //                             ],
        //                           )),
        //                       // Padding(
        //                       //     padding: EdgeInsets.all(5),
        //                       //     child: Row(
        //                       //       children: [
        //                       //         Text("close :"),
        //                       //         Text(close_[index]),
        //                       //       ],
        //                       //     )),
        //                     ],
        //                   ),
        //                 ]),
        //                 elevation: 8,
        //                 margin: EdgeInsets.all(3),
        //               ),
        //             ],
        //           )),
        //     );
        //   },
        // ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => Myhigh(title: 'high')));
        //   },
        //   child: Icon(Icons.arrow_circle_right_outlined),
        // ),
      ),
    );
  }
}
