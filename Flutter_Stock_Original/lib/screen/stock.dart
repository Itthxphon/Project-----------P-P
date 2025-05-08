import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:Nippostock/config/constant.dart';
import 'package:Nippostock/models/stockbalance.dart';
import 'package:Nippostock/widgets/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../models/inventory.dart';
import 'menu_drawer.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

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
  var image_pd;
  List<DropdownMenuItem<Inventory>> _dropdownMenuItems = [];
  Inventory? _selectedItem;

  bool checkSearch = false;
  List<StockBalance> _stockbalance = [];

  final _txtSearchProduct = TextEditingController();
  final List<StockBalance> _dataProduct = [];
  List<StockBalance> _documentCheckTemp = [];
  final List<Image_pd> _loadImage = [];

  bool isLoading = true;
  bool watchImage = false;

  @override
  void initState() {
    super.initState();
    getInventory();
    getStockBalance();

    var androidInitialize =
        const AndroidInitializationSettings('launcher_icon');
    //var iOSInitialize = new IOSInitializationSettings();
    var initialzationSetting =
        InitializationSettings(android: androidInitialize);

    localNotification = FlutterLocalNotificationsPlugin();
    localNotification.initialize(initialzationSetting);
  }

  Future _showNotification() async {
    var androidDetails = const AndroidNotificationDetails(
      "channelId",
      "LocalNotion",
      importance: Importance.high,
    );
    //var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails);
    await localNotification.show(
        0,
        "Alert minimum stock ",
        "Please recheck stock balance and increase value",
        generalNotificationDetails);
  }

  List<DropdownMenuItem<Inventory>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<Inventory>> items = [];
    Inventory allItem = Inventory(
      f_wareID: "all",
      f_wareName: "ทั้งหมด",
      f_wareRemark: "all",
      f_wareStatus: 1,
      f_whID: "all",
    );
    items.add(
      DropdownMenuItem(
        value: allItem,
        child: const Text("ทั้งหมด"),
      ),
    );
    for (Inventory listItem in listItems) {
      items.add(
        DropdownMenuItem(
          value: listItem,
          child: Text(listItem.f_wareName),
        ),
      );
    }
    // for (int i = 0; i <= listItems.length - 1; i++) {
    //   Inventory listItem = listItems[i];
    //   items.add(
    //     DropdownMenuItem(
    //       child: Text(listItem.f_wareName),
    //       value: listItem,
    //     ),
    //   );
    // }
    return items;
  }

  Future<void> getInventory() async {
    String url = "$server/api/inventory";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    final jsonResponce = json.decode(responce.body);
    List<Inventory> temp = (jsonResponce['data'] as List)
        .map((itemWord) => Inventory.fromJson(itemWord))
        .toList();

    if (temp.isNotEmpty) {
      _dropdownMenuItems = buildDropDownMenuItems(temp);
      if (_dropdownMenuItems.isNotEmpty) {
        _selectedItem = _dropdownMenuItems[0].value as Inventory;
      }
    }
  }

  Future<void> getStockBalance() async {
    if (mounted) {
      setState(() {
        isLoading = true; // เริ่มการโหลด
      });
    }
    try {
      String url = "$server/api/stockbalance/";
      final responce = await http
          .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
      final jsonResponce = json.decode(responce.body);
      List<StockBalance> temp = (jsonResponce['data'] as List)
          .map((item) => StockBalance.fromJson(item))
          .toList();
      // getImage();

      if (mounted) {
        if (temp.isNotEmpty) {
          setState(() {
            _stockbalance.clear();
            _stockbalance.addAll(temp);
            isLoading = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false; // การโหลดเสร็จสิ้น
        });
      }
    }
  }

  Future<void> getStockBalanceBywareID(String wareID) async {
    if (mounted) {
      setState(() {
        isLoading = true; // เริ่มการโหลด
      });
    }
    try {
      String url = "$server/api/stockbalance/'$wareID'";
      final responce = await http
          .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
      final jsonResponce = json.decode(responce.body);
      List<StockBalance> temp = (jsonResponce['data'] as List)
          .map((item) => StockBalance.fromJson(item))
          .toList();

      if (mounted) {
        setState(() {
          _stockbalance.clear();
          _stockbalance.addAll(temp);
          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        if (mounted) {}
      }
    }
  }

  Future<void> getImage(String id) async {
    try {
      String url = "$server/api/stockbalance/all_image/'$id'";
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
          List<Image_pd> temp = (jsonResponse['data'] as List)
              .map((item) => Image_pd.fromJson(item))
              .toList();
          // if(temp.isNotEmpty && temp[0].image_pd["data"] != null){
          //   setState(() {
          //     _loadImage.addAll(temp);
          //   });
          // }
          if (temp.isNotEmpty && temp[0].image_pd["data"] != null) {
            if (mounted) {
              setState(() {
                image_pd = temp[0].image_pd["data"];
              });
            }
          } else {
            if (mounted) {
              setState(() {
                image_pd = null;
              });
            }
          }
        } else {
          if (mounted) {
            setState(() {
              image_pd = null;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            image_pd = null;
          });
        }
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          image_pd = null;
        });
      }
      print('Error fetching image: $error');
    }
  }

  // selectImage(String id) async {
  //   if(_loadImage.length < 1){
  //     // await getImage();
  //   }else {
  //     int product = _loadImage.indexWhere((element) => element.f_prodID == id);
  //     if (product != -1) {
  //       setState(
  //             () {
  //           image_pd = _loadImage[product].image_pd;
  //         },
  //       );
  //     }
  //     else {
  //       setState(() {
  //         image_pd = null;
  //       });
  //     }
  //   }
  // }
  showAlert(BuildContext context, StockBalance stockBalance) {
    Uint8List _picture(index) {
      String ss = base64.encode(index.cast<int>());
      Uint8List image = base64.decode(ss);
      return image;
    }

    Alert(
      context: context,
      content: Column(
        children: <Widget>[
          Container(
              child: image_pd == null
                  ?
                  // Center(child: Text(image_pd.toString()))
                  Image.asset('images/image.png')
                  : Image.memory(_picture(image_pd))),
          Text(
            'ชื่อสินค้า : ${stockBalance.f_prodName}',
            style: const TextStyle(fontSize: 20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Min : ${NumberFormat.decimalPattern().format(stockBalance.f_min)}',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: MediaQuery.of(context).size.width / 30,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                'คงเหลือ : ${NumberFormat.decimalPattern().format(stockBalance.QTY)}',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: MediaQuery.of(context).size.width / 30,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                'Max : ${NumberFormat.decimalPattern().format(stockBalance.f_max)}',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: MediaQuery.of(context).size.width / 30,
                ),
              ),
            ],
          )
        ],
      ),
      closeIcon: const Icon(Icons.clear),
      // Image.memory(_picture(_stockbalance[index].f_picImage["data"]))
    ).show();
  }
  // Future<void> getStockBalanceBywareID(String wareID) async {
  //   String url = server + "/api/stockbalance/${wareID}";
  //   final responce = await http
  //       .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
  //   final jsonResponce = json.decode(responce.body);
  //   List<StockBalance> temp = (jsonResponce['data'] as List)
  //       .map((item) => StockBalance.fromJson(item))
  //       .toList();
  //   setState(() {
  //     // _txtProductID.clear();
  //     _stockbalance.clear();
  //     _stockbalance.addAll(temp);
  //     isLoading = false;
  //   });
  // }
  // Future<void> getStockBalanceByID(String id) async {
  //   String url = server + "/api/stockbalance/${id}";
  //   final responce = await http
  //       .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
  //   final jsonResponce = json.decode(responce.body);
  //   List<StockBalance> temp = (jsonResponce['data'] as List)
  //       .map((item) => StockBalance.fromJson(item))
  //       .toList();
  //   setState(() {
  //     // _txtProductID.clear();
  //     _stockbalance.clear();
  //     _stockbalance.addAll(temp);
  //   });
  // }

  FlutterLocalNotificationsPlugin localNotification =
      FlutterLocalNotificationsPlugin();
  _oNfilter(String value) {
    List<StockBalance> results = [];
    // print(_allProduct.length);
    if (value.isEmpty) {
      if (mounted) {
        setState(() {
          _stockbalance = _documentCheckTemp;
        });
      }
    } else {
      results = _documentCheckTemp
          .where(
            (c) =>
                c.f_prodID
                    .toLowerCase()
                    .contains(_txtSearchProduct.text.toLowerCase()) ||
                c.f_prodName
                    .toLowerCase()
                    .contains(_txtSearchProduct.text.toLowerCase()),
          )
          .toList();

      if (mounted) {
        setState(() {
          _stockbalance = results;
        });
      }
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
        drawer: Drawer(
          child: MenuDrawer(),
        ),
        appBar: AppBar(
          iconTheme: const IconThemeData(
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
              : const Text(
                  'Stock',
                  style: TextStyle(color: Colors.blue),
                ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            SizedBox(
              height: 30,
              // color: Colors.red,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Inventory>(
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context)
                        ? MediaQuery.of(context).size.width / 45
                        : 16.0,
                    fontFamily: 'Sarabun',
                    color: Colors.black,
                  ),
                  // isExpanded: true,
                  value: _selectedItem,
                  items: _dropdownMenuItems,
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        watchImage = false;
                        checkSearch = false;
                        _txtSearchProduct.clear();
                        _selectedItem = value;
                      });
                    }
                    if (_selectedItem!.f_wareID != "all") {
                      _stockbalance.clear();

                      if (mounted) {
                        setState(() {
                          watchImage = false;
                          isLoading = true;
                        });
                      }
                      getStockBalanceBywareID(_selectedItem!.f_wareID);
                    } else {
                      _stockbalance.clear();

                      if (mounted) {}
                      setState(() {
                        _selectedItem = value;
                      });
                      getStockBalance();
                    }
                  },
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                if (mounted) {
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
                }
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
                padding: const EdgeInsets.all(10
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
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      // child: ,
                      child: isLoading
                          ? const Center(
                              child:
                                  CircularProgressIndicator(), // แสดงตัวโหลดเมื่อกำลังโหลดข้อมูล
                            )
                          : _stockbalance.isEmpty &&
                                  (_selectedItem!.f_wareID == "all" ||
                                      _selectedItem!.f_wareID.isEmpty)
                              ? Center(
                                  child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "500 Server error",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          getStockBalance();
                                          // Navigator.pushReplacement(
                                          // context,
                                          // MaterialPageRoute(
                                          //   builder: (BuildContext context) => StockPage(),
                                          // ));
                                        },
                                        icon: const Icon(Icons.refresh))
                                  ],
                                ))
                              : _stockbalance.isEmpty
                                  ? const Center(
                                      child: Text("ไม่พบรายการ",
                                          style: TextStyle(fontSize: 20)))
                                  : ListView.separated(
                                      separatorBuilder:
                                          (BuildContext context, int index) =>
                                              const Divider(),
                                      itemCount: _stockbalance.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          onTap: () {},
                                          title: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.grey[50],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(1.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'รหัสสินค้า : ${_stockbalance[index].f_prodID}',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.amber[900],
                                                          fontSize: 12),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'ชื่อสินค้า : ${_stockbalance[index].f_prodName}',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 10),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Text(
                                                          'Min : ${NumberFormat.decimalPattern().format(_stockbalance[index].f_min)}',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                35,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          'คงเหลือ : ${NumberFormat.decimalPattern().format(_stockbalance[index].QTY)}',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                35,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          'Max : ${NumberFormat.decimalPattern().format(_stockbalance[index].f_max)}',
                                                          style: TextStyle(
                                                            color: Colors.blue,
                                                            fontSize: MediaQuery.of(
                                                                        context)
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
                                          leading: SizedBox(
                                            width: Responsive.isMobile(context)
                                                ? 50
                                                : 100,
                                            height: Responsive.isMobile(context)
                                                ? 50
                                                : 100,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: _stockbalance[index]
                                                          .f_picImage !=
                                                      null
                                                  ? Image.memory(
                                                      _picture(_stockbalance[
                                                              index]
                                                          .f_picImage["data"]),
                                                      fit: BoxFit.fill,
                                                    )
                                                  : Stack(children: [
                                                      Image.asset(
                                                          'images/image.png'),
                                                      watchImage
                                                          ? const Center(
                                                              child: SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                            )
                                                          : IconButton(
                                                              onPressed:
                                                                  () async {
                                                                if (mounted) {
                                                                  setState(() {
                                                                    watchImage =
                                                                        true;
                                                                  });
                                                                }
                                                                await getImage(
                                                                    _stockbalance[
                                                                            index]
                                                                        .f_prodID);
                                                                Alert(
                                                                    context:
                                                                        context,
                                                                    content:
                                                                        Column(
                                                                      children: <Widget>[
                                                                        Container(
                                                                            child: image_pd == null
                                                                                ?
                                                                                // Center(child: Text(image_pd.toString()))
                                                                                Image.asset('images/image.png')
                                                                                : Image.memory(_picture(image_pd))),
                                                                        Text(
                                                                          'ชื่อสินค้า : ${_stockbalance[index].f_prodName}',
                                                                          style:
                                                                              const TextStyle(fontSize: 20),
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceAround,
                                                                          children: [
                                                                            Text(
                                                                              'Min : ${NumberFormat.decimalPattern().format(_stockbalance[index].f_min)}',
                                                                              style: TextStyle(
                                                                                color: Colors.red,
                                                                                fontSize: MediaQuery.of(context).size.width / 30,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Text(
                                                                              'คงเหลือ : ${NumberFormat.decimalPattern().format(_stockbalance[index].QTY)}',
                                                                              textAlign: TextAlign.left,
                                                                              style: TextStyle(
                                                                                color: Colors.green,
                                                                                fontSize: MediaQuery.of(context).size.width / 30,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Text(
                                                                              'Max : ${NumberFormat.decimalPattern().format(_stockbalance[index].f_max)}',
                                                                              style: TextStyle(
                                                                                color: Colors.blue,
                                                                                fontSize: MediaQuery.of(context).size.width / 30,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                    closeIcon:
                                                                        const Icon(
                                                                      Icons
                                                                          .clear,
                                                                    ),
                                                                    buttons: [
                                                                      DialogButton(
                                                                        child:
                                                                            const Text(
                                                                          "Close",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 20),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          if (mounted) {
                                                                            setState(() {
                                                                              watchImage = false;
                                                                            });
                                                                          }
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                      ),
                                                                    ],
                                                                    onWillPopActive:
                                                                        true,
                                                                    closeFunction:
                                                                        () {
                                                                      if (mounted) {
                                                                        setState(
                                                                            () {
                                                                          watchImage =
                                                                              false;
                                                                        });
                                                                      }
                                                                      Navigator.pop(
                                                                          context);
                                                                    } // Image.memory(_picture(_stockbalance[index].f_picImage["data"]))
                                                                    ).show();
                                                                // showDialog(context: context,
                                                                //     builder: (BuildContext context){
                                                                //   return StatefulBuilder(builder: (context ,setState){
                                                                //     getImage(_stockbalance[index].f_prodID, setState);
                                                                //     return AlertDialog(
                                                                //       content: Column(
                                                                //         children: <Widget>[
                                                                //           isLoading?CircularProgressIndicator():Container( child:
                                                                //           image_pd == null ?
                                                                //           // Center(child: Text(image_pd.toString()))
                                                                //           Image.asset('images/image.png')
                                                                //               : Image.memory(_picture(image_pd))
                                                                //           ),
                                                                //           Text(
                                                                //             'ชื่อสินค้า : ${_stockbalance[index].f_prodName}',
                                                                //             style: TextStyle(fontSize: 20),
                                                                //           ),
                                                                //           Row(
                                                                //             mainAxisAlignment:
                                                                //             MainAxisAlignment.spaceAround,
                                                                //             children: [
                                                                //               Text(
                                                                //                 'Min : ${NumberFormat.decimalPattern().format(_stockbalance[index].f_min)}',
                                                                //                 style: TextStyle(
                                                                //                   color: Colors.red,
                                                                //                   fontSize: MediaQuery.of(context).size.width/30,
                                                                //                 ),
                                                                //               ),
                                                                //               SizedBox(
                                                                //                 width: 10,
                                                                //               ),
                                                                //               Text(
                                                                //                 'คงเหลือ : ${NumberFormat.decimalPattern().format(_stockbalance[index].QTY)}',
                                                                //                 textAlign: TextAlign.left,
                                                                //                 style: TextStyle(
                                                                //                   color: Colors.green,
                                                                //                   fontSize: MediaQuery.of(context).size.width/30,
                                                                //                 ),
                                                                //               ),
                                                                //               SizedBox(
                                                                //                 width: 10,
                                                                //               ),
                                                                //               Text(
                                                                //                 'Max : ${NumberFormat.decimalPattern().format(_stockbalance[index].f_max)}',
                                                                //                 style: TextStyle(
                                                                //                   color: Colors.blue,
                                                                //                   fontSize: MediaQuery.of(context).size.width/30,
                                                                //                 ),
                                                                //               ),
                                                                //             ],
                                                                //           )
                                                                //         ],
                                                                //       ),
                                                                //     );
                                                                //   });
                                                                // });

                                                                if (mounted) {}
                                                                setState(() {
                                                                  isLoading =
                                                                      false;
                                                                });

                                                                // Alert(
                                                                //   context: context,
                                                                //   content: Column(
                                                                //     children: <Widget>[
                                                                //       Container( child:
                                                                //       image_pd == null ?
                                                                //       // Center(child: Text(image_pd.toString()))
                                                                //       Image.asset('images/image.png')
                                                                //           : Image.memory(_picture(image_pd))
                                                                //       ),
                                                                //       Text(
                                                                //         'ชื่อสินค้า : ${_stockbalance[index].f_prodName}',
                                                                //         style: TextStyle(fontSize: 20),
                                                                //       ),
                                                                //       Row(
                                                                //         mainAxisAlignment:
                                                                //         MainAxisAlignment.spaceAround,
                                                                //         children: [
                                                                //           Text(
                                                                //             'Min : ${NumberFormat.decimalPattern().format(_stockbalance[index].f_min)}',
                                                                //             style: TextStyle(
                                                                //               color: Colors.red,
                                                                //               fontSize: MediaQuery.of(context).size.width/30,
                                                                //             ),
                                                                //           ),
                                                                //           SizedBox(
                                                                //             width: 10,
                                                                //           ),
                                                                //           Text(
                                                                //             'คงเหลือ : ${NumberFormat.decimalPattern().format(_stockbalance[index].QTY)}',
                                                                //             textAlign: TextAlign.left,
                                                                //             style: TextStyle(
                                                                //               color: Colors.green,
                                                                //               fontSize: MediaQuery.of(context).size.width/30,
                                                                //             ),
                                                                //           ),
                                                                //           SizedBox(
                                                                //             width: 10,
                                                                //           ),
                                                                //           Text(
                                                                //             'Max : ${NumberFormat.decimalPattern().format(_stockbalance[index].f_max)}',
                                                                //             style: TextStyle(
                                                                //               color: Colors.blue,
                                                                //               fontSize: MediaQuery.of(context).size.width/30,
                                                                //             ),
                                                                //           ),
                                                                //         ],
                                                                //       )
                                                                //     ],
                                                                //   ),
                                                                //   closeIcon: Icon(Icons.clear),
                                                                //   // Image.memory(_picture(_stockbalance[index].f_picImage["data"]))
                                                                // ).show();
                                                                // await getImage(_stockbalance[index].f_prodID);
                                                              },
                                                              icon: const Icon(Icons
                                                                  .search_outlined),
                                                            )
                                                    ]
                                                      // Image.asset('images/image.png',
                                                      //   fit : BoxFit.fill,
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
                  offset: const Offset(0, 3)),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              // Padding(
              //   padding: EdgeInsets.only(left: 20, top: 10),
              //   child:
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total ${_stockbalance.isNotEmpty ? NumberFormat.decimalPattern().format(_stockbalance.length) : ''} list.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 30,
                  )
                ],
              ),
              const SizedBox(
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
