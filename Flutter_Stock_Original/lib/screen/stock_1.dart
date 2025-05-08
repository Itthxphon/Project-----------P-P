import 'dart:convert';
import 'dart:typed_data';
import 'package:Nippostock/config/constant.dart';
import 'package:Nippostock/models/stockbalance.dart';
import 'package:Nippostock/widgets/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'menu_drawer.dart';

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  _StockPageState createState() => _StockPageState();
}

//final _txtProductID = TextEditingController();

// class TextBox extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.centerLeft,
//       color: Colors.white,
//       child: TextField(
//         controller: _txtProductID,
//         decoration:
//             InputDecoration(border: InputBorder.none, hintText: 'Search'),
//       ),
//     );
//   }
// }

class _StockPageState extends State<StockPage> {
  bool checkSearch = false;
  List<StockBalance> _stockbalance = [];

  final _txtSearchProduct = TextEditingController();
  List<StockBalance> _dataProduct = [];
  List<StockBalance> _documentCheckTemp = [];

  @override
  void initState() {
    super.initState();
    getStockBalance();

    var androidInitialize = new AndroidInitializationSettings('launcher_icon');
    //var iOSInitialize = new IOSInitializationSettings();
    var initialzationSetting =
        new InitializationSettings(android: androidInitialize);

    localNotification = new FlutterLocalNotificationsPlugin();
    localNotification.initialize(initialzationSetting);
  }

  Future _showNotification() async {
    var androidDetails = new AndroidNotificationDetails(
      "channelId",
      "LocalNotion",
      importance: Importance.high,
    );

    //var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails);

    await localNotification.show(
        0,
        "Alert minimum stock ",
        "Please recheck stock balance and increase value",
        generalNotificationDetails);
  }

  Future<void> getStockBalance() async {
    String url = server + "/api/stockbalance/";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    final jsonResponce = json.decode(responce.body);
    List<StockBalance> temp = (jsonResponce['data'] as List)
        .map((item) => StockBalance.fromJson(item))
        .toList();
    setState(() {
      _stockbalance.clear();
      _stockbalance.addAll(temp);
    });

    if (mounted) {}
  }

  Future<void> getStockBalanceByID(String id) async {
    String url = server + "/api/stockbalance/${id}";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    final jsonResponce = json.decode(responce.body);
    List<StockBalance> temp = (jsonResponce['data'] as List)
        .map((item) => StockBalance.fromJson(item))
        .toList();
    setState(() {
      // _txtProductID.clear();
      _stockbalance.clear();
      _stockbalance.addAll(temp);
    });
  }

  FlutterLocalNotificationsPlugin localNotification =
      new FlutterLocalNotificationsPlugin();

  _oNfilter(String value) {
    List<StockBalance> results = [];

    // print(_allProduct.length);

    if (value.isEmpty) {
      setState(() {
        _stockbalance = _documentCheckTemp;
      });
    } else {
      results = _stockbalance
          .where(
            (c) =>
                c.f_prodID.toLowerCase().contains(value.toLowerCase()) ||
                c.f_prodName.toLowerCase().contains(value.toLowerCase()),
          )
          .toList();

      setState(() {
        _stockbalance = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List _picture(index) {
      String ss = base64.encode(index.cast<int>());
      Uint8List image = base64.decode(ss);
      return image;
    }

    return SafeArea(
      child: Scaffold(
        drawer: new Drawer(
          child: MenuDrawer(),
        ),
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.blue,
          ),
          title: checkSearch
              ? TextField(
                  controller: _txtSearchProduct,
                  onChanged: (value) => _oNfilter(value),
                  autofocus: true,
                  style: const TextStyle(
                    // fontSize: 14,
                    color: Colors.blue,
                  ),
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'ระบุข้อความที่ต้องการค้นหา',
                      hintStyle: TextStyle(color: Colors.grey)),
                )
              : Text(
                  'Stock',
                  style: TextStyle(color: Colors.blue),
                ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (checkSearch) {
                    checkSearch = false;
                    _stockbalance = _documentCheckTemp;
                    _txtSearchProduct.clear();
                  } else {
                    checkSearch = true;
                    if (_documentCheckTemp.isEmpty) {
                      _documentCheckTemp = _stockbalance;
                    }
                  }
                });
              },
              icon: const Icon(
                Icons.search,
                size: 20,
              ),
            ),
          ],

          // actions: [
          //   IconButton(
          //     onPressed: () {
          //       setState(
          //         () {
          //           if (checkSearch == true) {
          //             getStockBalanceByID(
          //               _txtProductID.text.toString(),
          //             );
          //             checkSearch = false;
          //           } else {
          //             checkSearch = true;
          //           }
          //         },
          //       );
          //     },
          //     icon: Icon(
          //       Icons.search,
          //       color: Colors.blue,
          //     ),
          //   ),
          //   // IconButton(
          //   //   onPressed: () {
          //   //     Navigator.pushReplacement(
          //   //       context,
          //   //       MaterialPageRoute(
          //   //         builder: (BuildContext context) => StockPage(),
          //   //       ),
          //   //     );
          //   //   },
          //   //   icon: Icon(
          //   //     Icons.refresh,
          //   //     color: Colors.blue,
          //   //   ),
          //   // ),
          //   // IconButton(
          //   //   onPressed: () {
          //   //     _showNotification();
          //   //   },
          //   //   icon: Icon(
          //   //     Icons.notifications_active,
          //   //     color: Colors.blue,
          //   //   ),
          //   // ),
          // ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Padding(
                padding: EdgeInsets.all(10
                    // padding: EdgeInsets.only(
                    // left: 10,
                    // right: 10,
                    // top: 10,
                    // bottom: 10,
                    ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      // child: ,
                      child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(),
                        itemCount: _stockbalance.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            onTap: () {},
                            title: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[50],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'รหัสสินค้า : ${_stockbalance[index].f_prodID}',
                                        style: TextStyle(
                                            color: Colors.amber[900],
                                            fontSize: 12),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ชื่อสินค้า : ${_stockbalance[index].f_prodName}',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            'Min : ${NumberFormat.decimalPattern().format(_stockbalance[index].f_min)}',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'คงเหลือ : ${NumberFormat.decimalPattern().format(_stockbalance[index].QTY)}',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Max : ${NumberFormat.decimalPattern().format(_stockbalance[index].f_max)}',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            leading: Container(
                              width: Responsive.isMobile(context) ? 50 : 100,
                              height: Responsive.isMobile(context) ? 50 : 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: _stockbalance[index].f_picImage != null
                                    ? Image.memory(
                                        _picture(_stockbalance[index]
                                            .f_picImage["data"]),
                                        fit: BoxFit.fill,
                                      )
                                    : Image.asset(
                                        'images/image.png',
                                        fit: BoxFit.fill,
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // body: Stack(
        //   children: [
        //     Container(
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(10),
        //         color: Colors.grey[200],
        //       ),
        //       child: Padding(
        //         padding: EdgeInsets.all(
        //             10
        //           // padding: EdgeInsets.only(
        //           // left: 10,
        //           // right: 10,
        //           // top: 10,
        //           // bottom: 10,
        //         ),
        //         child: Container(
        //           decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(10),
        //             color: Colors.white,
        //           ),
        //           child: Padding(
        //             padding: const EdgeInsets.only(top: 20),
        //             child: Container(
        //               // child: ,
        //               child:
        //               ListView.separated(
        //                 separatorBuilder: (BuildContext context, int index) =>
        //                     Divider(),
        //                 itemCount: _stockbalance.length,
        //                 itemBuilder: (BuildContext context, int index) {
        //                   return ListTile(
        //                     onTap: () {},
        //                     title: Padding(
        //                       padding: const EdgeInsets.only(left: 8.0),
        //                       child: Container(
        //                         decoration: BoxDecoration(
        //                           borderRadius: BorderRadius.circular(10),
        //                           color: Colors.grey[50],
        //                         ),
        //                         child: Padding(
        //                           padding: const EdgeInsets.all(8.0),
        //                           child: Column(
        //                             crossAxisAlignment:
        //                             CrossAxisAlignment.start,
        //                             children: [
        //                               Text(
        //                                 'รหัสสินค้า : ${_stockbalance[index].f_prodID}',
        //                                 style: TextStyle(
        //                                     color: Colors.amber[900],
        //                                     fontSize: 12),
        //                               ),
        //                               SizedBox(
        //                                 height: 10,
        //                               ),
        //                               Column(
        //                                 mainAxisAlignment:
        //                                 MainAxisAlignment.start,
        //                                 crossAxisAlignment:
        //                                 CrossAxisAlignment.start,
        //                                 children: [
        //                                   Text(
        //                                     'ชื่อสินค้า : ${_stockbalance[index].f_prodName}',
        //                                     style: TextStyle(fontSize: 10),
        //                                   ),
        //                                   SizedBox(
        //                                     height: 30,
        //                                   ),
        //                                 ],
        //                               ),
        //                               Row(
        //                                 mainAxisAlignment:
        //                                 MainAxisAlignment.spaceAround,
        //                                 children: [
        //                                   Text(
        //                                     'Min : ${NumberFormat.decimalPattern().format(_stockbalance[index].f_min)}',
        //                                     style: TextStyle(
        //                                       color: Colors.red,
        //                                       fontSize: MediaQuery.of(context).size.width/35,
        //                                     ),
        //                                   ),
        //                                   SizedBox(
        //                                     width: 10,
        //                                   ),
        //                                   Text(
        //                                     'คงเหลือ : ${NumberFormat.decimalPattern().format(_stockbalance[index].QTY)}',
        //                                     textAlign: TextAlign.left,
        //                                     style: TextStyle(
        //                                       color: Colors.green,
        //                                       fontSize: MediaQuery.of(context).size.width/35,
        //                                     ),
        //                                   ),
        //                                   SizedBox(
        //                                     width: 10,
        //                                   ),
        //                                   Text(
        //                                     'Max : ${NumberFormat.decimalPattern().format(_stockbalance[index].f_max)}',
        //                                     style: TextStyle(
        //                                       color: Colors.blue,
        //                                       fontSize: MediaQuery.of(context).size.width/35,
        //                                     ),
        //                                   ),
        //                                 ],
        //                               )
        //                             ],
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                     leading: Container(
        //                       width: Responsive.isMobile(context) ? 50 : 100,
        //                       height: Responsive.isMobile(context) ? 50 : 100,
        //
        //                       child: ClipRRect(
        //
        //                         borderRadius: BorderRadius.circular(10.0),
        //                         child: _stockbalance[index].f_picImage != null ? Image.memory(
        //                           _picture(_stockbalance[index].f_picImage["data"]),fit : BoxFit.fill,
        //                         ) :
        //                         Image.asset('images/image.png',
        //                           fit : BoxFit.fill,
        //                         ),
        //                       ),
        //                     ),
        //                   );
        //                 },
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        // body: Stack(
        //   children: [
        //     Container(
        //       decoration: BoxDecoration(
        //                             borderRadius: BorderRadius.circular(10),
        //                             color: Colors.grey[200],
        //                           ),
        //       child: Padding(
        //         padding: EdgeInsets.all(
        //         10
        //         // padding: EdgeInsets.only(
        //           // left: 10,
        //           // right: 10,
        //           // top: 10,
        //           // bottom: 10,
        //         ),
        //         child: Container(
        //           decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(10),
        //             color: Colors.white,
        //           ),
        //           child: Padding(
        //             padding: const EdgeInsets.only(top: 20),
        //             child: Container(
        //               // child: ,
        //               child:
        //               ListView.separated(
        //                 separatorBuilder: (BuildContext context, int index) =>
        //                     Divider(),
        //                 itemCount: _stockbalance.length,
        //                 itemBuilder: (BuildContext context, int index) {
        //                   return ListTile(
        //                     onTap: () {},
        //                     title: Padding(
        //                       padding: const EdgeInsets.only(left: 8.0),
        //                       child: Container(
        //                         decoration: BoxDecoration(
        //                           borderRadius: BorderRadius.circular(10),
        //                           color: Colors.grey[50],
        //                         ),
        //                         child: Padding(
        //                           padding: const EdgeInsets.all(8.0),
        //                           child: Expanded(
        //                             child: Column(
        //                               crossAxisAlignment:
        //                                   CrossAxisAlignment.start,
        //                               children: [
        //                                 Text(
        //                                   'รหัสสินค้า : ${_stockbalance[index].f_prodID}',
        //                                   style: TextStyle(
        //                                       color: Colors.amber[900],
        //                                       fontSize: 12),
        //                                 ),
        //                                 SizedBox(
        //                                   height: 10,
        //                                 ),
        //                                 Column(
        //                                   mainAxisAlignment:
        //                                       MainAxisAlignment.start,
        //                                   crossAxisAlignment:
        //                                       CrossAxisAlignment.start,
        //                                   children: [
        //                                     Text(
        //                                       'ชื่อสินค้า : ${_stockbalance[index].f_prodName}',
        //                                       style: TextStyle(fontSize: 10),
        //                                     ),
        //                                     SizedBox(
        //                                       height: 30,
        //                                     ),
        //                                   ],
        //                                 ),
        //                                 Row(
        //                                   mainAxisAlignment:
        //                                       MainAxisAlignment.spaceAround,
        //                                   children: [
        //                                     Text(
        //                                       'Min : ${NumberFormat.decimalPattern().format(_stockbalance[index].f_min)}',
        //                                       style: TextStyle(
        //                                         color: Colors.red,
        //                                         fontSize: MediaQuery.of(context).size.width/35,
        //                                       ),
        //                                     ),
        //                                     SizedBox(
        //                                       width: 10,
        //                                     ),
        //                                     Text(
        //                                       'คงเหลือ : ${NumberFormat.decimalPattern().format(_stockbalance[index].QTY)}',
        //                                       textAlign: TextAlign.left,
        //                                       style: TextStyle(
        //                                         color: Colors.green,
        //                                         fontSize: MediaQuery.of(context).size.width/35,
        //                                       ),
        //                                     ),
        //                                     SizedBox(
        //                                       width: 10,
        //                                     ),
        //                                     Text(
        //                                       'Max : ${NumberFormat.decimalPattern().format(_stockbalance[index].f_max)}',
        //                                       style: TextStyle(
        //                                         color: Colors.blue,
        //                                         fontSize: MediaQuery.of(context).size.width/35,
        //                                       ),
        //                                     ),
        //                                   ],
        //                                 )
        //                               ],
        //                             ),
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                     leading: Container(
        //                      width: Responsive.isMobile(context) ? 50 : 100,
        //                      height: Responsive.isMobile(context) ? 50 : 100,
        //
        //                       child: ClipRRect(
        //
        //                         borderRadius: BorderRadius.circular(10.0),
        //                         child: _stockbalance[index].f_picImage != null ? Image.memory(
        //                           _picture(_stockbalance[index].f_picImage["data"]),fit : BoxFit.fill,
        //                           ) :
        //                           Image.asset('images/image.png',
        //                           fit : BoxFit.fill,
        //                         ),
        //                       ),
        //                     ),
        //                   );
        //                 },
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height * 0.04,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 5,
                  offset: Offset(0, 3)),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              // Padding(
              //   padding: EdgeInsets.only(left: 20, top: 10),
              //   child:
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total ${_stockbalance.length > 0 ? NumberFormat.decimalPattern().format(_stockbalance.length) : ''} list.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 30,
                  )
                ],
              ),
              SizedBox(
                height: 10,
              )
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
