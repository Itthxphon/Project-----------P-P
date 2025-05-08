import 'dart:convert';
import 'dart:io';

import 'package:Nippostock/config/constant.dart';
import 'package:Nippostock/models/inventory.dart';
import 'package:Nippostock/models/receive.dart';
import 'package:Nippostock/models/receiveDetail.dart';
import 'package:Nippostock/models/statusCheck.dart';
import 'package:Nippostock/models/supplier.dart';
import 'package:Nippostock/widgets/responsive.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Nippostock/models/product.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'menu_drawer.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReceivePage extends StatefulWidget {
  ReceivePage({Key? key}) : super(key: key);

  @override
  _ReceivePageState createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  String? _barcode;
  late bool visible;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _txtBarcode = TextEditingController();
  String scannedValue = '';

  @override
  void initState() {
    super.initState();
    getSupplier();
    getInventory();
    getReceiveID();
    getDataPref();
    _selected = statuscheck[0];
  }

  String? _setting_nd = "";
  String _scanBarcode = 'Unknown';
  // final _txtBarcode = TextEditingController();
  String _result = "";

  int Count = 0;
  int SumValue = 0;
  int SumValueHistory = 0;

  int totallist = 0;
  int totalpcs = 0;

  List<Product> _productlist = [];
  List<dynamic> _inventory = [];
  List<ReceiveDetail> _receveDetail = [];

  bool isLoading = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  //final GlobalKey<FormState> _formHistory = GlobalKey();
  dynamic inventory = 0;

  final _txtdocumentID = TextEditingController();
  final _txtdocumentDate = TextEditingController();
  final _txtdocumentRef = TextEditingController();
  final _txtdocumentRefDate = TextEditingController();
  final _txtuserReceive = TextEditingController();
  final _txtRemark = TextEditingController();

  final _txtSearchDocument = TextEditingController();
  final _txtSearchDateStart = TextEditingController();
  final _txtSearchDateEnd = TextEditingController();
  final _txtCount = TextEditingController();

  bool _showButton = true;

  List<Product> count = [];
  List<DropdownMenuItem<Inventory>> _dropdownMenuItems = [];
  Inventory? _selectedItem;
  List<DropdownMenuItem<Receive>> _dropdownMenuItemsHistory = [];
  Receive? _selectedItemHistory;

  List<DropdownMenuItem<Supplier>> _dropdownMenuItemSupplier = [];
  Supplier? _selectSupplier;

  List<DropdownMenuItem<Receive>> _dropdownMenuItemSupplierHistory = [];
  Receive? _selectSupplierHistory;

  List<Receive> _receiveHistory = [];

  // StatusCheck? _selected = StatusCheck(1, 'Normal');

  StatusCheck? _selected;

  List<StatusCheck> statuscheck = <StatusCheck>[
    const StatusCheck(1, 'Normal'),
    const StatusCheck(0, 'Cancle')
  ];

  String? _name = "";
  String? _fullname = "";
  bool _checkSearch = true;

  List<DropdownMenuItem<Inventory>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<Inventory>> items = [];
    for (int i = 0; i <= listItems.length - 1; i++) {
      Inventory listItem = listItems[i];
      items.add(
        DropdownMenuItem(
          child: Text(listItem.f_wareName),
          value: listItem,
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<Receive>> buildDropDownMenuItemsHistory(
      List listItems) {
    List<DropdownMenuItem<Receive>> items = [];
    for (int i = 0; i <= listItems.length - 1; i++) {
      Receive listItem = listItems[i];
      items.add(
        DropdownMenuItem(
          child: Text(listItem.f_wareName),
          value: listItem,
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<Supplier>> buildDropDownSupplier(List listItems) {
    List<DropdownMenuItem<Supplier>> items = [];
    for (int i = 0; i <= listItems.length - 1; i++) {
      Supplier listItem = listItems[i];
      items.add(
        DropdownMenuItem(
          child: SizedBox(
            child: Text(
              listItem.f_supName,
            ),
          ),
          value: listItem,
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<Receive>> buildDropDownSupplierHistory(List listItems) {
    List<DropdownMenuItem<Receive>> items = [];
    for (int i = 0; i <= listItems.length - 1; i++) {
      Receive listItem = listItems[i];
      items.add(
        DropdownMenuItem(
          child: SizedBox(
            child: Text(
              listItem.f_supName,
            ),
          ),
          value: listItem,
        ),
      );
    }
    return items;
  }

  Future<void> getSupplier() async {
    String url = server + "/api/supplier";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(responce.body);
    List<Supplier> temp = (jsonResponce['data'] as List)
        .map((item) => Supplier.fromJson(item))
        .toList();

    setState(() {
      _dropdownMenuItemSupplier = buildDropDownSupplier(temp);
      if (_dropdownMenuItemSupplier.length > 0) {
        _selectSupplier = _dropdownMenuItemSupplier[0].value as Supplier;
      }
    });
  }

  Future<void> getInventory() async {
    String url = server + "/api/inventory";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(responce.body);
    List<Inventory> temp = (jsonResponce['data'] as List)
        .map((itemWord) => Inventory.fromJson(itemWord))
        .toList();

    setState(() {
      _dropdownMenuItems = buildDropDownMenuItems(temp);
      if (_dropdownMenuItems.length > 0) {
        _selectedItem = _dropdownMenuItems[0].value as Inventory;
      }
    });
  }

  Future<void> insertReceiveDetail(Map<dynamic, dynamic> values) async {
    // print(values);
    String url = server + "/api/receivedetail";
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {
          'f_recvID': values['f_recvID'],
          'f_prodID': values['f_prodID'],
          'f_recvQty': values['f_recvQty'],
          'f_recvCost': values['f_costprice'],
        },
      ),
    );
  }

  _onAlertWithDrawIDDuplicate(context) {
    Alert(
      context: context,
      type: AlertType.success,
      title: "Alert !",
      desc: "เลขที่เอกสารถูกบันทึกพร้อมกัน กรุณาสร้างเอกสารใหม่",
      buttons: [
        DialogButton(
            color: kPrimaryColor,
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            width: 120,
            onPressed: () {
              if (mounted) {
                setState(() {
                  SumValue = 0;
                  _productlist.clear();

                  _txtdocumentID.clear();
                  _txtdocumentDate.clear();
                  _txtdocumentRef.clear();
                  _txtdocumentRefDate.clear();
                  _txtuserReceive.clear();
                  _txtRemark.clear();

                  getReceiveID();
                  getDataPref();
                });
              }
              Navigator.pop(context);
            })
      ],
    ).show();
  }

  _onAlertButtonPressed(context) {
    Alert(
      context: context,
      type: AlertType.success,
      title: "Alert !",
      desc: "Save success",
      buttons: [
        DialogButton(
            color: kPrimaryColor,
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            width: 120,
            onPressed: () {
              Navigator.pop(context);

              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (BuildContext context) => ReceivePage(),
              //   ),
              // );
            })
      ],
    ).show();
  }
  // _onAlertButtonPressed(context) {
  //   Alert(
  //     context: context,
  //     type: AlertType.success,
  //     title: "Alert !",
  //     desc: "Save success",
  //     buttons: [
  //       DialogButton(
  //         color: kPrimaryColor,
  //         child: Text(
  //           "OK",
  //           style: TextStyle(color: Colors.white, fontSize: 20),
  //         ),
  //         onPressed: () {
  //           setState(() {
  //             _productlist.clear();

  //             _txtdocumentID.clear();
  //             _txtdocumentDate.clear();
  //             _txtdocumentRef.clear();
  //             _txtdocumentRefDate.clear();
  //             _txtuserReceive.clear();
  //             _txtRemark.clear();
  //           });
  //           Navigator.pop(context);
  //         },
  //         width: 120,
  //       )
  //     ],
  //   ).show();
  // }

  Future<void> insertReceiveHead(Map<String, dynamic> values) async {
    print(values);
    String url = server + "/api/receive";
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {
          'f_recvID': values['f_recvID'],
          'f_recvdate': values['f_recvdate'],
          'f_recvRemark': values['f_recvRemark'],
          'f_recvStatus': values['f_recvStatus'],
          'f_recvReceiver': values['f_recvReceiver'],
          'f_recvReferance': values['f_recvReferance'],
          'f_recvReferanceDate': values['f_recvReferanceDate'],
          'f_wareID': values['f_wareID'],
          'f_supID': values['f_supID']
        },
      ),
    );

    if (response.statusCode == 200) {
      for (int i = 0; i < _productlist.length; i++) {
        // print(i);
        var product = {};
        product.clear();

        product = {
          'f_recvID': _txtdocumentID.text.toString(),
          'f_prodID': _productlist[i].f_prodID,
          'f_recvQty': _productlist[i].QTY,
          'f_recvCost': _productlist[i].f_costprice
        };

        insertReceiveDetail(product);
      }
      if (mounted) {
        setState(() {
          SumValue = 0;
          _showButton = true;
          _productlist.clear();
          _receveDetail.clear;

          _txtdocumentID.clear();
          _txtdocumentDate.clear();
          _txtdocumentRef.clear();
          _txtdocumentRefDate.clear();
          _txtuserReceive.clear();
          _txtRemark.clear();
          _inventory.clear();

          getSupplier();
          getInventory();
          getReceiveID();
          getDataPref();
          _selected = statuscheck[0];
        });
      }
      return _onAlertButtonPressed(context);
    } else {
      return _onAlertWithDrawIDDuplicate(context);
    }
  }

  Future<void> getReceiveID() async {
    // dispose();
    String url = server + "/api/receive/";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(responce.body);
    var temp = jsonResponce['data'];

    Map<String, dynamic> ID;
    String documentID = "";
    //List checkData = [];

    if (temp.isEmpty ?? true) {
      documentID = "";
    } else {
      ID = temp[0];
      documentID = ID.values.first;
    }

    String RR = "RR";
    String year = (DateTime.now().year).toString();

    int month = DateTime.now().month;
    var _formatmonth = NumberFormat('00', 'en-Us');
    String _monthString = _formatmonth.format(month);

    int number = 0;
    if (documentID == "") {
      number = 00000;
    } else {
      number = int.parse((documentID.substring(8, 13)));
    }

    number = number + 1;
    var _formatnumber = NumberFormat('00000', 'en_Us');
    String _numberString = _formatnumber.format(number);

    String _documentID = RR + year + _monthString + _numberString;

    if (mounted) {
      setState(
        () {
          _txtdocumentID.text = _documentID;

          DateTime now = DateTime.now();
          _txtdocumentDate.text =
              '${DateFormat('dd-MM-yyyy HH:mm:ss').format(now)}';
          isLoading = false;
        },
      );
    }
  }

  Future<void> getProduct(String id, String wareID) async {
    print(id);

    String encodedId = Uri.encodeComponent(id.replaceAll("'", ""));
    String warehouseId = Uri.encodeComponent(wareID.replaceAll("'", ""));
    String url = server + "/api/product/search/'$encodedId'/'$warehouseId'";
    final response = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    final jsonResponce = json.decode(response.body);
    // print(jsonResponce['data']);

    List<Product> temp = (jsonResponce['data'] as List)
        .map((itemWord) => Product.fromJson(itemWord))
        .toList();
    int product_all = temp.indexWhere((element) => element.f_Barcode == id);
    int product = _productlist.indexWhere((element) => element.f_Barcode == id);
    if (product_all != -1) {
      if (product != -1) {
        if (mounted) {
          setState(
            () {
              _productlist[product].QTY = _productlist[product].QTY + 1;

              _txtBarcode.clear();

              sumValue();
            },
          );
        }
      } else {
        if (mounted) {
          setState(
            () {
              _productlist.addAll(temp);

              _txtBarcode.clear();

              sumValue();
              totallist = _productlist.length;
            },
          );
        }
      }
    } else {
      _txtBarcode.clear();
      // scannedValue = "";
      final snackBar = const SnackBar(
        content: Text('ไม่พบรายการสินค้า'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> sumValue() async {
    SumValue = 0;
    for (int i = 0; i < _productlist.length; i++) {
      SumValue = SumValue + _productlist[i].QTY;
    }
  }

  Future<void> sumValueHistory() async {
    SumValue = 0;
    for (int i = 0; i < _receveDetail.length; i++) {
      SumValue = SumValue + _receveDetail[i].f_recvQty;
    }
  }

  Future<void> scanBarcodeNormal() async {
    if (_selectedItem!.f_wareID != Null) {
      String barcodeScanRes;
      String? wareID = _selectedItem!.f_wareID;
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

      getProduct(barcodeScanRes, wareID);
      if (!mounted) return;
    }
  }

  _showStatusMobile(int _text) {
    String _content;
    if (_text == 1) {
      _content = "Normal";
    } else {
      _content = "Cancel";
    }

    return Container(
      width: 50,
      height: 30,
      decoration: BoxDecoration(
        color: _text == 1 ? Colors.green[600] : Colors.red,
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Center(
        child: Text(
          _content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
          ),
        ),
      ),
    );
  }

  _showStatusTablet(int _text) {
    String _content;
    if (_text == 1) {
      _content = "Normal";
    } else {
      _content = "Cancel";
    }

    return Container(
      width: 100,
      height: 30,
      decoration: BoxDecoration(
        color: _text == 1 ? Colors.green[600] : Colors.red,
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Center(
        child: Text(
          _content,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> showAlertgetHistoryMobile() async {
    return showDialog(
      // useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                // padding: EdgeInsets.all(10),
                // physics: NeverScrollableScrollPhysics(),
                child: Container(
                  // height: MediaQuery.of(context).size.height /0.2,
                  margin: const EdgeInsets.all(1.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('images/POS.jpg'),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Receive History (ประวัติ รับเข้าสินค้า)',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          _Triangle(
                            color: Colors.green,
                          )
                        ],
                      ), //Head
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        // height: MediaQuery.of(context).size.height * 0.2,
                        // width: MediaQuery.of(context).size.width - 60,
                        //color: Colors.red,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  //ปุ่มเลขที่เอกสาร
                                  height: 30,
                                  width: MediaQuery.of(context).size.width / 6,
                                  color: Colors.green,
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: Center(
                                    child: Text(
                                      'เลขที่เอกสาร',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              45),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 6,
                                    height: 30,
                                    color: Colors.white,
                                    margin: const EdgeInsets.only(bottom: 5),
                                    child: TextFormField(
                                      //   textAlign: TextAlign.center,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                45,
                                        backgroundColor: Colors.white,
                                      ),
                                      controller: _txtSearchDocument,
                                      decoration: const InputDecoration(
                                        // labelText: 'ค้นหาเอกสาร',
                                        contentPadding:
                                            EdgeInsets.only(left: 10),
                                        labelStyle:
                                            TextStyle(fontSize: mediumText),
                                        border: OutlineInputBorder(),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 30,
                                    margin: const EdgeInsets.only(bottom: 5),
                                    color: Colors.white,
                                    child: TextFormField(
                                      enabled: _checkSearch,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'please insert data';
                                        }
                                        return null;
                                      },
                                      readOnly: true,
                                      onTap: () async {
                                        await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2021),
                                          lastDate: DateTime(2099),
                                        ).then(
                                          (selectedDate) {
                                            if (selectedDate != null) {
                                              _txtSearchDateStart.text =
                                                  '${DateFormat('dd-MM-yyyy').format(selectedDate)}';
                                            }
                                          },
                                        );
                                      },
                                      controller: _txtSearchDateStart,
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                40,
                                      ),
                                      decoration: InputDecoration(
                                        labelStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                40),
                                        contentPadding:
                                            const EdgeInsets.only(left: 10),
                                        labelText: 'วันที่เริ่มต้น',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(
                                            color: Colors.green,
                                            width: 2.0,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(
                                            color: Colors.green,
                                            width: 2.0,
                                          ),
                                        ),
                                        errorBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.red, width: 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    // width: MediaQuery.of(context).size.width/5,
                                    height: 30,
                                    margin: const EdgeInsets.only(bottom: 5),
                                    color: Colors.white,
                                    child: TextFormField(
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                40,
                                      ),
                                      enabled: _checkSearch,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'please insert data';
                                        }
                                        return null;
                                      },
                                      readOnly: true,
                                      onTap: () async {
                                        await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2021),
                                          lastDate: DateTime(2031),
                                        ).then(
                                          (selectedDate) {
                                            if (selectedDate != null) {
                                              _txtSearchDateEnd.text =
                                                  '${DateFormat('dd-MM-yyyy').format(selectedDate)}';
                                            }
                                          },
                                        );
                                      },
                                      controller: _txtSearchDateEnd,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.only(left: 10),
                                        labelStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                40),
                                        labelText: 'วันที่สุดท้าย',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(
                                            color: Colors.green,
                                            width: 2.0,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(
                                            color: Colors.green,
                                            width: 2.0,
                                          ),
                                        ),
                                        errorBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.red, width: 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    // width: MediaQuery.of(context).size.width/5,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      // color: _selected.id == Colors.green,
                                      border: Border.all(
                                          color: Colors.green, width: 2),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: const EdgeInsets.only(left: 10),
                                    margin: const EdgeInsets.only(bottom: 5),
                                    child: new DropdownButton<StatusCheck>(
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              40,
                                          color: Colors.black),
                                      underline: const SizedBox.shrink(),
                                      isExpanded: true,
                                      value: _selected,
                                      onChanged: (newValue) {
                                        if (mounted) {
                                          setState(
                                            () {
                                              _selected = newValue;
                                            },
                                          );
                                        }
                                      },
                                      items: statuscheck.map(
                                        (StatusCheck _check) {
                                          return new DropdownMenuItem<
                                              StatusCheck>(
                                            value: _check,
                                            child: new Text(
                                              _check.name,
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                var data = {};
                                data.clear;
                                String _dateStart = "";
                                String _dateEnd = "";

                                if (_txtSearchDateStart.text.toString() != '' &&
                                    _txtSearchDateEnd.text.toString() != '') {
                                  _dateStart = DateFormat("dd-MM-yyyy")
                                      .parse(
                                          _txtSearchDateStart.text.toString())
                                      .toString();

                                  _dateEnd = DateFormat("dd-MM-yyyy")
                                      .parse(_txtSearchDateEnd.text.toString())
                                      .toString();
                                }

                                data = {
                                  'f_recvID':
                                      _txtSearchDocument.text.toString() != ''
                                          ? _txtSearchDocument.text.toString()
                                          : '',
                                  'f_dateStart': _dateStart,
                                  'f_dateEnd': _dateEnd,
                                  'f_recvStatus': _selected!.id
                                };

                                if (data.length > 0) {
                                  getReceiveHistoryByID(data);
                                }
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                ),
                                // width: MediaQuery.of(context).size.width - 60,
                                height: 30,
                                child: Center(
                                  child: Text(
                                    'Load Data',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          width: MediaQuery.of(context).size.width - 100,
                          height: MediaQuery.of(context).size.height * 0.5,
                          color: Colors.white,
                          child: ListView.builder(
                            itemCount: _receiveHistory.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                elevation: 6,
                                margin: const EdgeInsets.all(5),
                                child: ListTile(
                                  onTap: () {
                                    getReceiveHead(
                                        _receiveHistory[index].f_recvID);

                                    Navigator.pop(context);
                                  },
                                  title: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                'เลขที่เอกสารรับเข้า : ${_receiveHistory[index].f_recvID}',
                                                style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            40),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'วันที่รับเข้า : ${_receiveHistory[index].f_recvDate == '' ? '' : DateFormat('dd-MM-yyyy').format(DateTime.parse(_receiveHistory[index].f_recvDate))}',
                                                style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            40),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'ผู้รับเข้าสินค้า : ${_receiveHistory[index].f_recvReceiver}',
                                                style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            40),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Responsive.isMobile(context)
                                            ? _showStatusMobile(
                                                _receiveHistory[index]
                                                    .f_recvStatus)
                                            : _showStatusTablet(
                                                _receiveHistory[index]
                                                    .f_recvStatus),
                                      ],
                                    ),
                                  ),
                                  // leading: Icon(
                                  //   Icons.analytics_outlined,
                                  //   size: 10,
                                  //   color: Colors.green,
                                  // ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   height: 20,
                      // ),
                      // Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [
                      //       // Container(
                      //       //   width: 60,
                      //       //   height: 10,
                      //       //   child:
                      //         SizedBox(
                      //           child: Text(
                      //             '${_receiveHistory.length} Records.',
                      //             style: TextStyle(
                      //               color: Colors.black,
                      //               fontSize: MediaQuery.of(context).size.width/40,
                      //               // fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ),
                      //        // )
                      //     ],
                      //   ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Container(
                          //   width: 60,
                          //   height: 10,
                          //   child:
                          SizedBox(
                            child: Text(
                              '${_receiveHistory.length} Records.',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width / 40,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> showAlertgetHistoryTablet() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: AssetImage('images/POS.jpg'),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Receive History (ประวัติ รับเข้าสินค้า)',
                                style: TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            _Triangle(
                              color: Colors.green,
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.10,
                      width: MediaQuery.of(context).size.width - 60,
                      //color: Colors.red,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 40,
                                width: 100,
                                color: Colors.green,
                                margin: const EdgeInsets.only(bottom: 5),
                                child: const Center(
                                  child: Text(
                                    'เลขที่เอกสาร',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: 100,
                                  height: 40,
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    //   textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      backgroundColor: Colors.white,
                                    ),
                                    controller: _txtSearchDocument,
                                    decoration: const InputDecoration(
                                      // labelText: 'ค้นหาเอกสาร',
                                      contentPadding: EdgeInsets.only(left: 10),
                                      labelStyle:
                                          TextStyle(fontSize: mediumText),
                                      border: OutlineInputBorder(),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                          width: 5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Container(
                                width: 110,
                                height: 40,
                                margin: const EdgeInsets.only(bottom: 5),
                                color: Colors.white,
                                child: TextFormField(
                                  enabled: _checkSearch,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'please insert data';
                                    }
                                    return null;
                                  },
                                  readOnly: true,
                                  onTap: () async {
                                    await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2021),
                                      lastDate: DateTime(2099),
                                    ).then(
                                      (selectedDate) {
                                        if (selectedDate != null) {
                                          _txtSearchDateStart.text =
                                              '${DateFormat('dd-MM-yyyy').format(selectedDate)}';
                                        }
                                      },
                                    );
                                  },
                                  controller: _txtSearchDateStart,
                                  decoration: InputDecoration(
                                    labelStyle:
                                        const TextStyle(fontSize: mediumText),
                                    contentPadding:
                                        const EdgeInsets.only(left: 10),
                                    labelText: 'วันที่เริ่มต้น',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Colors.green,
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Colors.green,
                                        width: 2.0,
                                      ),
                                    ),
                                    errorBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 1),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              Container(
                                width: 110,
                                height: 40,
                                margin: const EdgeInsets.only(bottom: 5),
                                color: Colors.white,
                                child: TextFormField(
                                  enabled: _checkSearch,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'please insert data';
                                    }
                                    return null;
                                  },
                                  readOnly: true,
                                  onTap: () async {
                                    await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2021),
                                      lastDate: DateTime(2031),
                                    ).then(
                                      (selectedDate) {
                                        if (selectedDate != null) {
                                          _txtSearchDateEnd.text =
                                              '${DateFormat('dd-MM-yyyy').format(selectedDate)}';
                                        }
                                      },
                                    );
                                  },
                                  controller: _txtSearchDateEnd,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.only(left: 10),
                                    labelStyle:
                                        const TextStyle(fontSize: mediumText),
                                    labelText: 'วันที่สุดท้าย',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Colors.green,
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Colors.green,
                                        width: 2.0,
                                      ),
                                    ),
                                    errorBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 1),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              Container(
                                width: 110,
                                height: 40,
                                decoration: BoxDecoration(
                                  // color: _selected.id == Colors.green,
                                  border:
                                      Border.all(color: Colors.green, width: 2),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.only(left: 10),
                                margin: const EdgeInsets.only(bottom: 5),
                                child: new DropdownButton<StatusCheck>(
                                  underline: const SizedBox.shrink(),
                                  isExpanded: true,
                                  value: _selected,
                                  onChanged: (newValue) {
                                    if (mounted) {
                                      setState(() {
                                        _selected = newValue;
                                        //print(_selected!.id);
                                      });
                                    }
                                  },
                                  items: statuscheck.map(
                                    (StatusCheck _check) {
                                      return new DropdownMenuItem<StatusCheck>(
                                        value: _check,
                                        child: new Text(
                                          _check.name,
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              var data = {};
                              data.clear;
                              String _dateStart = "";
                              String _dateEnd = "";

                              if (_txtSearchDateStart.text.toString() != '' &&
                                  _txtSearchDateEnd.text.toString() != '') {
                                _dateStart = DateFormat("dd-MM-yyyy")
                                    .parse(_txtSearchDateStart.text.toString())
                                    .toString();

                                _dateEnd = DateFormat("dd-MM-yyyy")
                                    .parse(_txtSearchDateEnd.text.toString())
                                    .toString();
                              }

                              data = {
                                'f_recvID':
                                    _txtSearchDocument.text.toString() != ''
                                        ? _txtSearchDocument.text.toString()
                                        : '',
                                'f_dateStart': _dateStart,
                                'f_dateEnd': _dateEnd,
                                'f_recvStatus': _selected!.id
                              };

                              if (data.length > 0) {
                                getReceiveHistoryByID(data);
                              }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.green,
                              ),
                              width: MediaQuery.of(context).size.width - 60,
                              height: 50,
                              child: const Center(
                                child: Text(
                                  'Load Data',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 60,
                        height: MediaQuery.of(context).size.height * 0.7,
                        color: Colors.white,
                        child: ListView.builder(
                          itemCount: _receiveHistory.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 6,
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                onTap: () {
                                  getReceiveHead(
                                      _receiveHistory[index].f_recvID);

                                  Navigator.pop(context);
                                },
                                title: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                'เลขที่เอกสารรับเข้า : ${_receiveHistory[index].f_recvID}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'วันที่รับเข้า : ${_receiveHistory[index].f_recvDate == '' ? '' : DateFormat('dd-MM-yyyy').format(DateTime.parse(_receiveHistory[index].f_recvDate))}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'ผู้รับเข้าสินค้า : ${_receiveHistory[index].f_recvReceiver}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      _showStatusTablet(
                                          _receiveHistory[index].f_recvStatus),
                                    ],
                                  ),
                                ),
                                leading: const Icon(
                                  Icons.analytics_outlined,
                                  size: 60,
                                  color: Colors.green,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 20,
                          child: Text(
                            '${_receiveHistory.length} Records.',
                            style: const TextStyle(color: Colors.black),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
//  Future<void> showAlertgetHistory() async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             child: Container(
//               width: MediaQuery.of(context).size.width - 60,
//               height: MediaQuery.of(context).size.height * 0.8,
//               color: Colors.white,
//               child: ListView.builder(
//                 itemCount: _receiveHistory.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   return Card(
//                     elevation: 6,
//                     margin: EdgeInsets.all(10),
//                     child: ListTile(
//                       onTap: () {
//                         getReceiveHead(_receiveHistory[index].f_recvID);
//                         Navigator.pop(context);
//                       },
//                       title: Padding(
//                         padding: const EdgeInsets.only(left: 8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     SizedBox(
//                                       height: 20,
//                                     ),
//                                     Text(
//                                       'เลขที่เอกสาร : ${_receiveHistory[index].f_recvID}',
//                                       style: TextStyle(fontSize: 14),
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Text(
//                                       'วันที่รับเข้า : ${_receiveHistory[index].f_recvDate == null || _receiveHistory[index].f_recvDate == '' ? '' : DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(_receiveHistory[index].f_recvDate))}',
//                                       style: TextStyle(fontSize: 14),
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Text(
//                                       'ผู้รับเข้าสินค้า : ${_receiveHistory[index].f_recvReceiver}',
//                                       style: TextStyle(fontSize: 14),
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                   ],
//                                 )
//                               ],
//                             ),
//                             _showStatus(_receiveHistory[index].f_recvStatus),
//                           ],
//                         ),
//                       ),
//                       leading: Icon(
//                         Icons.analytics_outlined,
//                         size: 60,
//                         color: Colors.green,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),

//           //todo
//           title: Container(
//             width: 100,
//             height: MediaQuery.of(context).size.height * 0.13 - 2,
//             child: Column(
//               children: [
//                 Container(
//                   width: MediaQuery.of(context).size.width - 60,
//                   height: 50,
//                   color: Colors.green,
//                   child: Center(
//                     child: Text(
//                       'Receive History',
//                       style: TextStyle(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                       height: 40,
//                       width: 100,
//                       color: Colors.green,
//                       margin: EdgeInsets.only(bottom: 5),
//                       child: Center(
//                         child: Text(
//                           'เลขที่เอกสาร',
//                           style: TextStyle(color: Colors.white, fontSize: 14),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 2,
//                     ),
//                     Container(
//                       width: 160,
//                       height: 40,
//                       color: Colors.white,
//                       margin: EdgeInsets.only(bottom: 5),
//                       child: TextFormField(
//                         controller: _txtSearchDocument,
//                         decoration: InputDecoration(
//                           // labelText: 'ค้นหาเอกสาร',
//                           labelStyle: TextStyle(fontSize: mediumText),
//                           border: OutlineInputBorder(),
//                           errorBorder: OutlineInputBorder(
//                             borderSide: BorderSide(color: Colors.red, width: 5),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 2,
//                     ),
//                     Container(
//                       height: 40,
//                       width: 100,
//                       color: Colors.green,
//                       margin: EdgeInsets.only(bottom: 5),
//                       child: Center(
//                         child: Text(
//                           'สถานะเช็คของ',
//                           style: TextStyle(color: Colors.white, fontSize: 14),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 2,
//                     ),
//                     Container(
//                       width: 160,
//                       height: 40,
//                       //color: Colors.red,
//                       margin: EdgeInsets.only(bottom: 5),
//                       child: new DropdownButton<StatusCheck>(
//                         underline: SizedBox.shrink(),
//                         // isExpanded: true,
//                         value: _selected,
//                         onChanged: (newValue) {
//                           setState(() {
//                             _selected = newValue;
//                           });
//                         },
//                         items: statuscheck.map(
//                           (StatusCheck _check) {
//                             return new DropdownMenuItem<StatusCheck>(
//                               value: _check,
//                               child: new Text(_check.name),
//                             );
//                           },
//                         ).toList(),
//                       ),
//                       // child: TextFormField(
//                       //   //controller: _txtSearchDocument,
//                       //   decoration: InputDecoration(
//                       //     labelStyle: TextStyle(fontSize: mediumText),
//                       //     border: OutlineInputBorder(),
//                       //     errorBorder: OutlineInputBorder(
//                       //       borderSide: BorderSide(color: Colors.red, width: 5),
//                       //     ),
//                       //   ),
//                       // ),
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     Container(
//                       width: 130,
//                       height: 40,
//                       margin: EdgeInsets.only(bottom: 5),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           color: Colors.green),
//                       child: Center(
//                         child: IconButton(
//                           onPressed: () {
//                             getReceiveHistoryByID(_txtSearchDocument.text);
//                           },
//                           icon: Icon(
//                             Icons.search,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       height: 40,
//                       width: 100,
//                       color: Colors.green,
//                       child: Center(
//                         child: Text(
//                           'วันที่',
//                           style: TextStyle(color: Colors.white, fontSize: 14),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 2,
//                     ),
//                     Container(
//                       width: 160,
//                       height: 40,
//                       margin: EdgeInsets.only(bottom: 5),
//                       color: Colors.white,
//                       child: TextFormField(
//                         // enabled: _showButton,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'please insert data';
//                           }
//                           return null;
//                         },
//                         readOnly: true,
//                         onTap: () async {
//                           await showDatePicker(
//                             context: context,
//                             initialDate: DateTime.now(),
//                             firstDate: DateTime(2021),
//                             lastDate: DateTime(2099),
//                           ).then(
//                             (selectedDate) {
//                               if (selectedDate != null) {
//                                 _txtSearchDateStart.text =
//                                     '${DateFormat('dd-MM-yyyy').format(selectedDate)}';
//                               }
//                             },
//                           );
//                         },
//                         controller: _txtSearchDateStart,
//                         decoration: InputDecoration(
//                           labelStyle: TextStyle(fontSize: mediumText),
//                           border: OutlineInputBorder(),
//                           errorBorder: OutlineInputBorder(
//                             borderSide: BorderSide(color: Colors.red, width: 1),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 2,
//                     ),
//                     Container(
//                       height: 40,
//                       width: 100,
//                       color: Colors.green,
//                       child: Center(
//                         child: Text(
//                           'ถึง',
//                           style: TextStyle(color: Colors.white, fontSize: 14),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 2,
//                     ),
//                     Container(
//                       width: 160,
//                       height: 40,
//                       margin: EdgeInsets.only(bottom: 5),
//                       color: Colors.white,
//                       child: TextFormField(
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'please insert data';
//                           }
//                           return null;
//                         },
//                         readOnly: true,
//                         onTap: () async {
//                           await showDatePicker(
//                             context: context,
//                             initialDate: DateTime.now(),
//                             firstDate: DateTime(2021),
//                             lastDate: DateTime(2031),
//                           ).then(
//                             (selectedDate) {
//                               if (selectedDate != null) {
//                                 _txtSearchDateEnd.text =
//                                     '${DateFormat('dd-MM-yyyy').format(selectedDate)}';
//                               }
//                             },
//                           );
//                         },
//                         controller: _txtSearchDateEnd,
//                         decoration: InputDecoration(
//                           labelStyle: TextStyle(fontSize: mediumText),
//                           border: OutlineInputBorder(),
//                           errorBorder: OutlineInputBorder(
//                             borderSide: BorderSide(color: Colors.red, width: 1),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

  Future<void> getReceiveHistoryByID(Map<dynamic, dynamic> values) async {
    String url = server + "/api/receive/history";
    final responce = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {
          'f_recvID': values['f_recvID'],
          'f_dateStart': values['f_dateStart'],
          'f_dateEnd': values['f_dateEnd'],
          'f_recvStatus': values['f_recvStatus']
        },
      ),
    );
    final jsonResponce = json.decode(responce.body);
    if (responce.statusCode == 200) {
      List<Receive> temp = (jsonResponce['data'] as List)
          .map((item) => Receive.fromJson(item))
          .toList();

      if (mounted) {
        setState(() {
          _receiveHistory.clear();
          _receiveHistory.addAll(temp);

          Navigator.pop(context);
          showAlertgetHistoryMobile();

          // Responsive.isMobile(context)
          //     ? showAlertgetHistoryMobile()
          //     : showAlertgetHistoryTablet();
        });
      }
    }
  }

  // Future<void> getReceiveHistoryByID(String id) async {
  //   String url = server + "/api/receive/'${id}'";
  //   final responce = await http
  //       .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
  //   final jsonResponce = json.decode(responce.body);

  //   List<Receive> temp = (jsonResponce['data'] as List)
  //       .map((item) => Receive.fromJson(item))
  //       .toList();

  //   setState(() {
  //     _receiveHistory.clear();
  //     _receiveHistory.addAll(temp);
  //     Navigator.pop(context);
  //     showAlertgetHistory();
  //   });
  // }

  Future<void> getReceiveHistory() async {
    String url = server + "/api/receive/history/";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    final jsonResponce = json.decode(responce.body);
    List<Receive> temp = (jsonResponce['data'] as List)
        .map((itemWord) => Receive.fromJson(itemWord))
        .toList();

    if (mounted) {
      setState(() {
        _txtSearchDateStart.clear();
        _txtSearchDateEnd.clear();

        DateTime _dateStart;
        DateTime _dateEnd;
        _dateStart = DateTime.now().subtract(const Duration(days: 45));
        _dateEnd = DateTime.now();

        _txtSearchDateStart.text =
            '${DateFormat('dd-MM-yyyy').format(_dateStart)}';
        _txtSearchDateEnd.text = '${DateFormat('dd-MM-yyyy').format(_dateEnd)}';

        _receiveHistory.clear();
        _receiveHistory.addAll(temp);
        _selected = statuscheck[0];

        showAlertgetHistoryMobile();
        // Responsive.isMobile(context)
        //     ? showAlertgetHistoryMobile()
        //     : showAlertgetHistoryTablet();
      });
    }
  }

  Future<void> getReceiveHead(String id) async {
    String url = server + "/api/receive/'${id}'";
    final response = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(response.body);

    List<Receive> temp = (jsonResponce['data'] as List)
        .map((itemWord) => Receive.fromJson(itemWord))
        .toList();

    if (mounted) {
      setState(
        () {
          if (temp.length > 0) {
            _showButton = false;
            _txtdocumentID.text =
                temp[0].f_recvID == null ? '' : temp[0].f_recvID;

            _txtdocumentDate.text = temp[0].f_recvDate.toString() == null
                ? ''
                : DateFormat('dd-MM-yyyy HH:mm:ss').format(
                    DateTime.parse(temp[0].f_recvDate),
                  );

            _txtdocumentRef.text =
                temp[0].f_recvReferance == null ? '' : temp[0].f_recvReferance;

            _txtdocumentRefDate.text =
                temp[0].f_recvReferanceDate.toString() == '' ||
                        temp[0].f_recvReferanceDate.isEmpty
                    ? "-"
                    : DateFormat('dd-MM-yyyy').format(
                        DateTime.parse(temp[0].f_recvReferanceDate),
                      );

            _txtuserReceive.text =
                temp[0].f_recvReceiver == null ? '' : temp[0].f_recvReceiver;

            _txtRemark.text =
                temp[0].f_recvRemark == null ? '' : temp[0].f_recvRemark;

            _dropdownMenuItemsHistory = buildDropDownMenuItemsHistory(temp);
            _selectedItemHistory =
                _dropdownMenuItemsHistory[0].value as Receive;

            _dropdownMenuItemSupplierHistory =
                buildDropDownSupplierHistory(temp);
            _selectSupplierHistory =
                _dropdownMenuItemSupplierHistory[0].value as Receive;

            getReceiveDetail(id);
            // Navigator.pop(context);
          }
        },
      );
    }
  }

  Future<void> getReceiveDetail(String id) async {
    String url = server + "/api/receivedetail/'${id}'";
    final response = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(response.body);

    List<ReceiveDetail> temp = (jsonResponce['data'] as List)
        .map((itemWord) => ReceiveDetail.fromJson(itemWord))
        .toList();

    _receveDetail.clear();

    if (mounted) {
      setState(() {
        _productlist.clear();
        _receveDetail.addAll(temp);
        sumValueHistory();
        totallist = _receveDetail.length;
      });
    }
  }

  getDataPref() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? name = prefs.getString("userName");
    String? fullname = prefs.getString("fullName");
    String? setting_nd = prefs.getString("f_negativeDrawdown");

    if (mounted) {
      setState(() {
        _name = name;
        _fullname = fullname;
        _txtuserReceive.text = fullname.toString();
        _setting_nd = setting_nd;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // FocusNode myFocusNode = new FocusNode();
    // int count = 0;
    // String dropdownValue = 'One';

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : VisibilityDetector(
            onVisibilityChanged: (VisibilityInfo info) {
              visible = info.visibleFraction > 0;
            },
            key: const Key('visible-detector-key'),
            child: BarcodeKeyboardListener(
                bufferDuration: const Duration(milliseconds: 200),
                onBarcodeScanned: (barcode) {
                  if (!visible) return;
                  if (barcode.isEmpty) {
                    print("no-barcode");
                  } else {
                    print("barcode");
                    print(barcode);

                    if (_selectedItem!.f_wareID != Null) {
                      getProduct(barcode, _selectedItem!.f_wareID);
                    }
                  }
                  // setState(() {
                  //   _barcode = barcode;
                  // });
                },
                useKeyDownEvent: Platform.isWindows,
                child: Scaffold(
                  // resizeToAvoidBottomInset: false,
                  backgroundColor: Colors.grey[200],
                  drawer: new Drawer(
                    child: MenuDrawer(),
                  ),
                  appBar: AppBar(
                    iconTheme: IconThemeData(
                      color: Colors.green,
                      size: Responsive.isMobile(context) ? 20 : 24,
                    ),
                    title: Text(
                      'Receive ( รับเข้าสินค้า )',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: Responsive.isMobile(context) ? 15 : 24,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0,
                    actions: [
                      IconButton(
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              SumValue = 0;
                              _showButton = true;
                              _productlist.clear();
                              _receveDetail.clear();

                              _txtdocumentID.clear();
                              _txtdocumentDate.clear();
                              _txtdocumentRef.clear();
                              _txtdocumentRefDate.clear();
                              _txtuserReceive.clear();
                              _txtRemark.clear();
                              _inventory.clear();

                              getSupplier();
                              getInventory();
                              getReceiveID();
                              getDataPref();
                              _selected = statuscheck[0];
                            });
                          }
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (BuildContext context) => ReceivePage(),
                          //   ),
                          // );
                        },
                        icon: Icon(
                          Icons.addchart,
                          size: Responsive.isMobile(context) ? 20 : 24,
                        ),
                      ),
                      SizedBox(
                        width: Responsive.isMobile(context) ? 1 : 10,
                      ),
                      IconButton(
                        onPressed: () {
                          _txtSearchDocument.text = '';
                          getReceiveHistory();
                        },
                        icon: Icon(
                          Icons.description_sharp,
                          size: Responsive.isMobile(context) ? 20 : 24,
                        ),
                      ),
                    ],
                  ),
                  body: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _buildMobile(context),
                  //  Responsive.isMobile(context)
                  //     ? _buildMobile(context)
                  //     : _buildTablet(context),

                  bottomNavigationBar: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        // height: _showButton && _productlist.length > 0
                        //     ? MediaQuery.of(context).size.height * 0.15
                        //     : MediaQuery.of(context).size.height * 0.1,
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: Responsive.isMobile(context) ? 2 : 6,
                                    child: Text(
                                      // 'Total ${_productlist.length > 0 ? _productlist.length : _receveDetail.length} list.',
                                      'Total ${totallist != 0 ? totallist : 0} list.',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Total  ${SumValue}  pcs.',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            _showButton && SumValue > 0
                                ? _buildButtonSave()
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ],
                  ),
                )));
  }

  Widget _buildMobile(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: _productlist.length > 0
            ? MediaQuery.of(context).size.height * 0.74
            : MediaQuery.of(context).size.height * 0.84,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.only(top: 0, left: 5, right: 5, bottom: 0),
              width: MediaQuery.of(context).size.width / 1,
              //height: MediaQuery.of(context).size.height * 0.22,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Column(
                    children: [
                      Row(
                        //เลขที่เอกสาร and วันที่บันทึก
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            //เลขที่เอกสาร
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Colors.green,
                            child: Center(
                              child: Text(
                                'เลขที่เอกสาร',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 50),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          Container(
                            //TextFormField
                            width: MediaQuery.of(context).size.width / 3.67,
                            height: MediaQuery.of(context).size.height / 34,
                            color: Colors.black,
                            margin: const EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              textAlign: TextAlign.start,
                              enabled: _showButton,
                              readOnly: true,
                              style: TextStyle(
                                color: Colors.yellow,
                                backgroundColor: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width / 50,
                              ),
                              controller: _txtdocumentID,
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
                                border: OutlineInputBorder(),
                                errorBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            //วันที่บันทึก
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Colors.green,
                            child: Center(
                              child: Text(
                                'วันที่บันทึก',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 50),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          Container(
                            //TextFormField
                            width: MediaQuery.of(context).size.width / 3.25,
                            height: MediaQuery.of(context).size.height / 34,
                            color: Colors.black,
                            //  margin: EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              enabled: _showButton,
                              style: TextStyle(
                                color: Colors.yellow,
                                backgroundColor: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width / 50,
                              ),
                              readOnly: true,
                              // onTap: () async {
                              //   await showDatePicker(
                              //     context: context,
                              //     initialDate: DateTime.now(),
                              //     firstDate: DateTime(2020),
                              //     lastDate: DateTime(2099),
                              //   ).then((selectedDate) {
                              //     if (selectedDate != null) {
                              //       // _txtdocumentDate.text =
                              //       //     '${DateFormat('dd-MM-yyyy HH:mm:ss').format(selectedDate)}';
                              //     }
                              //   });
                              // },
                              controller: _txtdocumentDate,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                // labelText: 'วันที่บันทึก',
                                labelStyle:
                                    const TextStyle(fontSize: mediumText),
                                border: const OutlineInputBorder(),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.red,
                                      width: MediaQuery.of(context).size.width /
                                          50),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      Row(
                        //เอกสารอ้างอิง and วันที่เอกสารอ้างอิง
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            //เอกสารอ้างอิง
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Colors.green,
                            child: Center(
                              child: Text(
                                'เอกสารอ้างอิง',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 50),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          Container(
                            //TextFormField
                            width: MediaQuery.of(context).size.width / 3.67,
                            height: MediaQuery.of(context).size.height / 34,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50),
                              enabled: _showButton,
                              validator: (value) {
                                if (value == null || value.isEmpty) {}
                                return null;
                              },
                              controller: _txtdocumentRef,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                // labelText: 'เอกสารอ้างอิง',
                                labelStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 50),
                                border: const OutlineInputBorder(),
                                errorBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            //วันที่เอกสารอ้างอิง
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Colors.green,
                            child: Align(
                              child: Text(
                                'วันที่เอกสารอ้างอิง',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 65),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          Container(
                            //TextFormField
                            width: MediaQuery.of(context).size.width / 3.25,
                            height: MediaQuery.of(context).size.height / 34,
                            // margin: EdgeInsets.only(bottom: 10),
                            margin: const EdgeInsets.only(bottom: 5),
                            color: Colors.white,
                            // margin: EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              enabled: _showButton,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please insert data';
                                }
                                return null;
                              },
                              readOnly: true,
                              onTap: () async {
                                if (_showButton) {
                                  await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2021),
                                    lastDate: DateTime(2099),
                                  ).then(
                                    (selectedDate) {
                                      if (selectedDate != null) {
                                        _txtdocumentRefDate.text =
                                            '${DateFormat('dd-MM-yyyy').format(selectedDate)}';
                                      }
                                    },
                                  );
                                }
                              },
                              controller: _txtdocumentRefDate,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 50,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                hintText: "กรุณาเลือกวัน",
                                labelStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 50),
                                border: const OutlineInputBorder(),
                                errorBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        //คลังสินค้า and ผู้ผลิต/ผู้ขาย
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            //คลังสินค้า
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Colors.green,
                            child: Center(
                              child: Text(
                                'คลังสินค้า',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 50),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          _showButton
                              ? _buildDropdownInventory()
                              : _buildDropdownInventoryHistory(),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            //ผู้ผลิต/ผู้ขาย
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Colors.green,
                            child: Center(
                              child: Text(
                                'ผู้ผลิต/ผู้ขาย',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 50),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          _showButton
                              ? _buildDropdownSupplier()
                              : _buildDropdownSupplierHistory(),
                        ],
                      ),
                      Row(
                        //ผู้รับเข้าสินค้า and หมายเหตุ
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            //ผู้รับเข้าสินค้า
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Colors.green,
                            child: Center(
                              child: Text(
                                'ผู้รับเข้าสินค้า',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 50),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          Container(
                            //TextFormField
                            width: MediaQuery.of(context).size.width / 3.67,
                            height: MediaQuery.of(context).size.height / 34,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50),
                              enabled: _showButton,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  // showMessageAlert("Alert ",
                                  //     "Please insert user receiver !");
                                }
                                return null;
                              },
                              controller: _txtuserReceive,
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
                                labelStyle: TextStyle(fontSize: 9),
                                border: OutlineInputBorder(),
                                errorBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            //หมายเหตุ
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Colors.green,
                            child: Center(
                              child: Text(
                                'หมายเหตุ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 50),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          Container(
                            //TextFormField
                            width: MediaQuery.of(context).size.width / 3.25,
                            height: MediaQuery.of(context).size.height / 34,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50),
                              enabled: _showButton,
                              controller: _txtRemark,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                //labelText: 'หมายเหตุ',
                                labelStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 50),
                                border: const OutlineInputBorder(),
                                errorBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(
                      //   height: 5,
                      // )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 10,
              color: Colors.green,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                            // color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                          child: TextField(
                            onSubmitted: (value) => {
                              _txtBarcode.text.isEmpty
                                  ? ""
                                  : getProduct(
                                      value.toString(), _selectedItem!.f_wareID)
                            },
                            //autofocus: true,
                            enabled: _showButton,
                            controller: _txtBarcode,
                            cursorColor: Colors.amber[900],
                            maxLines: 1,
                            style: TextStyle(color: Colors.amber[900]),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.transparent)),
                              disabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.transparent)),
                              enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.transparent)),
                              errorBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.transparent)),
                              focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.transparent)),
                              focusedErrorBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.transparent)),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    _showButton ? scanBarcodeNormal() : '',
                                icon: Icon(
                                  Icons.qr_code_scanner,
                                  color: _showButton
                                      ? Colors.amber[900]
                                      : Colors.grey,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal:
                                      MediaQuery.of(context).size.width / 30),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            _productlist.length > 0 ? _buildProduct() : _buildHistoryProduct(),
          ],
          // useKeyDownEvent: Platform.isWindows,
        ),
      ),
    );
  }

  Widget _buildTablet(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
          width: MediaQuery.of(context).size.width,
          //height: MediaQuery.of(context).size.height * 0.13,
          height: MediaQuery.of(context).size.height * 0.22,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        //เลขที่เอกสาร
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Colors.green,
                        child: const Center(
                          child: Text(
                            'เลขที่เอกสาร',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 1,
                      ),
                      Container(
                        //TextFormField เลขที่เอกสาร
                        width: MediaQuery.of(context).size.width * 0.28,
                        height: 40,
                        color: Colors.black,
                        margin: const EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          enabled: _showButton,
                          readOnly: true,
                          style: const TextStyle(
                            color: Colors.yellow,
                            backgroundColor: Colors.black,
                          ),
                          controller: _txtdocumentID,
                          decoration: const InputDecoration(
                            // labelText: 'เลขที่เอกสาร',
                            // labelStyle: TextStyle(
                            //   fontSize: mediumText,
                            // ),
                            border: OutlineInputBorder(),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        //วันที่บันทึก
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Colors.green,
                        child: const Center(
                          child: Text(
                            'วันที่บันทึก',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 1,
                      ),
                      Container(
                        //TextFormField วันที่บันทึก
                        width: MediaQuery.of(context).size.width * 0.28,
                        height: 40,
                        color: Colors.black,
                        margin: const EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          enabled: _showButton,
                          style: const TextStyle(
                              color: Colors.yellow,
                              backgroundColor: Colors.black),
                          readOnly: true,
                          onTap: () async {
                            await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2099),
                            ).then((selectedDate) {
                              if (selectedDate != null) {
                                // _txtdocumentDate.text =
                                //     '${DateFormat('dd-MM-yyyy HH:mm:ss').format(selectedDate)}';
                              }
                            });
                          },
                          controller: _txtdocumentDate,
                          decoration: const InputDecoration(
                            // labelText: 'วันที่บันทึก',
                            labelStyle: TextStyle(fontSize: mediumText),
                            border: OutlineInputBorder(),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  Row(
                    //เอกสารอ้างอิง Text
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Colors.green,
                        child: const Center(
                          child: Text(
                            'เอกสารอ้างอิง',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.28,
                        height: 40,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          enabled: _showButton,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              // showMessageAlert(
                              //     "Alert ", "Please insert document ref !");
                            }
                            return null;
                          },
                          controller: _txtdocumentRef,
                          decoration: const InputDecoration(
                            // labelText: 'เอกสารอ้างอิง',
                            labelStyle: TextStyle(fontSize: mediumText),
                            border: OutlineInputBorder(),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Colors.green,
                        child: const Center(
                          child: Text(
                            'วันที่เอกสารอ้างอิง',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.28,
                        height: 40,
                        // margin: EdgeInsets.only(bottom: 10),
                        margin: const EdgeInsets.only(bottom: 5),
                        color: Colors.white,
                        // margin: EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          enabled: _showButton,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'please insert data';
                            }
                            return null;
                          },
                          readOnly: true,
                          onTap: () async {
                            await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2021),
                              lastDate: DateTime(2099),
                            ).then(
                              (selectedDate) {
                                if (selectedDate != null) {
                                  _txtdocumentRefDate.text =
                                      '${DateFormat('dd-MM-yyyy').format(selectedDate)}';
                                }
                              },
                            );
                          },
                          controller: _txtdocumentRefDate,
                          decoration: const InputDecoration(
                            // labelText: 'วันที่เอกสารอ้างอิง',
                            // constraints: BoxConstraints.expand(),
                            // contentPadding:
                            //     EdgeInsets.symmetric(vertical: 12),
                            labelStyle: TextStyle(fontSize: mediumText),
                            border: OutlineInputBorder(),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    //คลังสินค้า
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Colors.green,
                        child: const Center(
                          child: Text(
                            'คลังสินค้า',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 1,
                      ),
                      _showButton
                          ? _buildDropdownInventory()
                          : _buildDropdownInventoryHistory(),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Colors.green,
                        child: const Center(
                          child: Text(
                            'ผู้ผลิต/ผู้ขาย',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 1,
                      ),
                      _showButton
                          ? _buildDropdownSupplier()
                          : _buildDropdownSupplierHistory(),
                    ],
                  ),
                  Row(
                    //ผู้รับเข้าสินค้า
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Colors.green,
                        child: const Center(
                          child: Text(
                            'ผู้รับเข้าสินค้า',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.28,
                        height: 40,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          enabled: _showButton,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              // showMessageAlert("Alert ",
                              //     "Please insert user receiver !");
                            }
                            return null;
                          },
                          controller: _txtuserReceive,
                          decoration: const InputDecoration(
                            //labelText: 'ผู้รับเข้าสินค้า',
                            labelStyle: TextStyle(fontSize: mediumText),
                            border: OutlineInputBorder(),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Colors.green,
                        child: const Center(
                          child: Text(
                            'หมายเหตุ',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.28,
                        height: 40,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          enabled: _showButton,
                          controller: _txtRemark,
                          decoration: const InputDecoration(
                            //labelText: 'หมายเหตุ',
                            labelStyle: TextStyle(fontSize: mediumText),
                            border: OutlineInputBorder(),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 10,
          color: Colors.green,
        ),
        Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.08,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 10, bottom: 20),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30)),
                  child: TextField(
                    enabled: _showButton,
                    controller: _txtBarcode,
                    cursorColor: Colors.amber[900],
                    maxLines: 1,
                    style: TextStyle(color: Colors.amber[900]),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent)),
                      disabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent)),
                      enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent)),
                      errorBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent)),
                      focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent)),
                      focusedErrorBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent)),
                      suffixIcon: IconButton(
                        onPressed: () => _showButton ? scanBarcodeNormal() : '',
                        icon: Icon(
                          Icons.qr_code_scanner,
                          color: _showButton ? Colors.amber[900] : Colors.grey,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 25, horizontal: 10),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        _productlist.length > 0 ? _buildProduct() : _buildHistoryProduct(),
      ],
    );
  }

  Container _buildDropdownSupplierHistory() {
    return Container(
      padding: const EdgeInsets.only(left: 6.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5.0),
        ),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        color: Colors.white,
      ),
      width: MediaQuery.of(context).size.width / 3.25,
      height: MediaQuery.of(context).size.height / 34,
      margin: const EdgeInsets.only(bottom: 5),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Receive>(
          style: TextStyle(
            fontSize: Responsive.isMobile(context) ? 9 : 16.0,
            fontFamily: 'Sarabun',
            color: Colors.black,
          ),
          isExpanded: true,
          value: _selectSupplierHistory,
          items: _dropdownMenuItemSupplierHistory,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                _showButton ? _selectSupplierHistory = value : '';
              });
            }
          },
        ),
      ),
    );
  }

  Container _buildDropdownSupplier() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5.0),
        ),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        color: Colors.white,
      ),
      width: MediaQuery.of(context).size.width / 3.25,
      height: MediaQuery.of(context).size.height / 34,
      margin: const EdgeInsets.only(bottom: 5),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Supplier>(
          focusNode: FocusNode(canRequestFocus: false),
          style: TextStyle(
            fontSize: Responsive.isMobile(context) ? 9 : 16.0,
            fontFamily: 'Sarabun',
            color: Colors.black,
          ),
          isExpanded: true,
          value: _selectSupplier,
          items: _dropdownMenuItemSupplier,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                _showButton ? _selectSupplier = value : '';
              });
            }
          },
        ),
      ),
    );
  }

  Container _buildDropdownInventoryHistory() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5.0),
        ),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        color: Colors.white,
      ),
      width: MediaQuery.of(context).size.width / 3.67,
      height: MediaQuery.of(context).size.height / 34,
      margin: const EdgeInsets.only(bottom: 5),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Receive>(
          style: TextStyle(
            fontSize: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width / 45
                : 16.0,
            fontFamily: 'Sarabun',
            color: Colors.black,
          ),
          isExpanded: true,
          value: _selectedItemHistory,
          items: _dropdownMenuItemsHistory,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                _showButton ? _selectedItemHistory = value : '';
              });
            }
          },
        ),
      ),
    );
  }

  Container _buildDropdownInventory() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5.0),
        ),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        color: Colors.white,
      ),
      width: MediaQuery.of(context).size.width / 3.67,
      height: MediaQuery.of(context).size.height / 34,
      margin: const EdgeInsets.only(bottom: 5),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Inventory>(
          autofocus: false,
          style: TextStyle(
            fontSize: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width / 45
                : 16.0,
            fontFamily: 'Sarabun',
            color: Colors.black,
          ),
          isExpanded: true,
          value: _selectedItem,
          items: _dropdownMenuItems,
          focusNode: FocusNode(canRequestFocus: false),
          onChanged: (value) {
            _productlist.clear();
            sumValue();
            totallist = _productlist.length;

            if (mounted) {
              setState(() {
                _showButton ? _selectedItem = value : '';
              });
            }
          },
        ),
      ),
    );
  }

  Row _buildButtonSave() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: () async {
                _showButton = false;
                await getReceiveID();

                String _recvdate = "";
                String _recvReferanceDate = "";

                if (_txtdocumentDate.text.toString() != '') {
                  _recvdate = DateFormat("dd-MM-yyyy HH:mm:ss")
                      .parse(_txtdocumentDate.text.toString())
                      .toString();
                }

                if (_txtdocumentRefDate.text.toString() != '') {
                  _recvReferanceDate = DateFormat("dd-MM-yyyy")
                      .parse(_txtdocumentRefDate.text.toString())
                      .toString();
                }

                var f_wareID;
                if (_selectedItem != null) {
                  f_wareID = _selectedItem!.f_wareID;
                } else {
                  f_wareID = "";
                }

                var f_supplier;
                if (_selectSupplier != null) {
                  f_supplier = _selectSupplier!.f_supID;
                } else {
                  f_supplier = null;
                }

                var value = {
                  'f_recvID': _txtdocumentID.text.toString(),
                  'f_recvdate': _recvdate,
                  'f_recvRemark': _txtRemark.text.toString(),
                  'f_recvStatus': 1,
                  'f_recvReceiver': _txtuserReceive.text.toString(),
                  'f_recvReferance': _txtdocumentRef.text.toString(),
                  'f_recvReferanceDate': _recvReferanceDate,
                  'f_wareID': f_wareID,
                  'f_supID': f_supplier
                };

                insertReceiveHead(value);
                ///////// insert detail /////////////////////

                // for (int i = 0; i < _productlist.length; i++) {
                //   // print(i);
                //   var product = {};
                //   product.clear();

                //   product = {
                //     'f_recvID': _txtdocumentID.text.toString(),
                //     'f_prodID': _productlist[i].f_prodID,
                //     'f_recvQty': _productlist[i].f_count,
                //     'f_recvCost': _productlist[i].f_costprice
                //   };
                //   insertReceiveDetail(product);
                // }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Confirm'),
            ),
          ),
        ),
      ],
    );
  }

  Expanded _buildProduct() {
    return Expanded(
      child: Container(
        child: ListView.builder(
          itemCount: getCountProduct(),
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 6,
              margin: const EdgeInsets.only(
                  left: 10.0, top: 2.0, right: 10, bottom: 2),
              child: ListTile(
                onTap: () {},
                title: Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'รหัสสินค้า : ${_productlist[index].f_prodID}',
                            style: TextStyle(
                                color: Colors.amber[900],
                                fontSize: Responsive.isMobile(context)
                                    ? MediaQuery.of(context).size.width / 45
                                    : 10),
                          ),
                          IconButton(
                            onPressed: () async {
                              bool? shouldDelete =
                                  await showMessageAlert_deleteitem();
                              if (shouldDelete != null) {
                                if (shouldDelete) {
                                  if (mounted) {
                                    setState(() {
                                      totallist = totallist - 1;
                                      SumValue =
                                          SumValue - _productlist[index].QTY;
                                      print(_productlist);
                                    });
                                  }
                                  _productlist.removeAt(index);
                                }
                              }
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.amber[900],
                              size: 15,
                            ),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ชื่อสินค้า : ${_productlist[index].f_prodName}',
                            style: TextStyle(
                              fontSize: Responsive.isMobile(context)
                                  ? MediaQuery.of(context).size.width / 45
                                  : 10,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            // color: Colors.red,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.red,
                                  child: IconButton(
                                    onPressed: () async {
                                      if (_productlist[index].QTY <= 1) {
                                        final shouldDelete =
                                            await showMessageAlert_deleteitem();
                                        if (shouldDelete != null) {
                                          if (shouldDelete) {
                                            if (mounted) {
                                              setState(() {
                                                totallist = totallist - 1;
                                                SumValue = SumValue -
                                                    _productlist[index].QTY;
                                                print(_productlist);
                                              });
                                            }
                                            _productlist.removeAt(index);
                                          }
                                        }
                                      } else {
                                        if (mounted) {
                                          setState(
                                            () {
                                              // print("--");
                                              if (_productlist.length > 0) {
                                                if (_productlist[index].QTY >=
                                                    2) {
                                                  _productlist[index].QTY =
                                                      _productlist[index].QTY -
                                                          1;
                                                }
                                              }

                                              sumValue();
                                            },
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.remove),
                                    color: Colors.white,
                                    alignment: Alignment.center,
                                    iconSize: 15,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.09,
                                    height: MediaQuery.of(context).size.width *
                                        0.09,
                                    color: Colors.white.withOpacity(0.1),
                                    //color: Colors.red,
                                    child: Center(
                                      child: Text(
                                        '${_productlist[index].QTY}',
                                        style: TextStyle(
                                          color: Colors.amber[900],
                                          fontSize: Responsive.isMobile(context)
                                              ? 12
                                              : 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    _txtCount.clear();
                                    Alert(
                                        context: context,
                                        title: "Edit number",
                                        content: Column(
                                          children: <Widget>[
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.amber[900],
                                              ),
                                              controller: _txtCount,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        buttons: [
                                          DialogButton(
                                            color: Colors.green,
                                            onPressed: () {
                                              int num =
                                                  int.parse(_txtCount.text);
                                              if (num >= 1) {
                                                if (_setting_nd == "1") {
                                                  if (num <=
                                                      _productlist[index]
                                                          .QTY_all) {
                                                    _productlist[index].QTY =
                                                        int.parse(
                                                            _txtCount.text);
                                                    sumValue();
                                                    Navigator.pop(context);
                                                  } else {
                                                    final snackBar =
                                                        const SnackBar(
                                                      content: Text(
                                                          'สินค้าในคลังไม่เพียงพอ'),
                                                      duration:
                                                          Duration(seconds: 2),
                                                    );
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(snackBar);
                                                  }
                                                } else {
                                                  _productlist[index].QTY =
                                                      int.parse(_txtCount.text);
                                                  sumValue();
                                                  Navigator.pop(context);
                                                }
                                              }
                                            },
                                            child: const Text(
                                              "SAVE",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                          )
                                        ]).show();
                                  },
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: _setting_nd == "1"
                                      ? (_productlist[index].QTY <
                                              _productlist[index].QTY_all)
                                          ? Colors.green
                                          : Colors.grey
                                      : Colors.green,
                                  child: IconButton(
                                    onPressed: () async {
                                      if (mounted) {
                                        setState(
                                          () {
                                            // print("++");
                                            if (_setting_nd == "1") {
                                              if (_productlist[index].QTY <
                                                  _productlist[index].QTY_all) {
                                                _productlist[index].QTY =
                                                    _productlist[index].QTY + 1;
                                                sumValue();
                                              }
                                            } else {
                                              _productlist[index].QTY += 1;
                                              sumValue();
                                            }
                                          },
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.add),
                                    color: Colors.white,
                                    alignment: Alignment.center,
                                    iconSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                leading: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 15,
                          color: Colors.grey.withOpacity(0.1),
                          offset: const Offset(0, 3),
                        )
                      ],
                      image: const DecorationImage(
                        image: AssetImage('images/image.png'),
                        fit: BoxFit.scaleDown,
                      )),
                ),
                // trailing: Icon(
                //   Icons.close,
                //   color: Colors.amber[900],
                // ),
              ),
            );
          },
        ),
      ),
    );
  }

  Expanded _buildHistoryProduct() {
    return Expanded(
      child: Container(
        child: ListView.builder(
          itemCount: _receveDetail.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 6,
              margin: const EdgeInsets.only(
                  left: 10.0, top: 2.0, right: 10, bottom: 2),
              child: ListTile(
                onTap: () {},
                title: Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'รหัสสินค้า : ${_receveDetail[index].f_prodID}',
                            style: TextStyle(
                                color: Colors.amber[900],
                                fontSize:
                                    Responsive.isMobile(context) ? 9 : 12),
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.green,
                            child: Text(
                              '${_receveDetail[index].f_recvQty}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    Responsive.isMobile(context) ? 11 : 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'ชื่อสินค้า : ${_receveDetail[index].f_prodName} ',
                            style: TextStyle(
                                fontSize:
                                    Responsive.isMobile(context) ? 9 : 12),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            // color: Colors.red,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [],
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                leading: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15,
                        color: Colors.grey.withOpacity(0.1),
                        offset: const Offset(0, 3),
                      )
                    ],
                    image: const DecorationImage(
                      image: AssetImage('images/image.png'),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  int getCountProduct() {
    int amount = 0;
    this._productlist.forEach((_product) {
      amount++;
    });

    return amount;
  }

  Future<bool?> showMessageAlert_deleteitem() {
    return showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("ต้องการลบหรือไม่?"),
          content: new Text("กดลบรายการนี้จะถูกลบออกในทันที"),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                new TextButton(
                  child: new Text(
                    "Close",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                new TextButton(
                  child: new Text(
                    "Delete",
                    style: const TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> showMessageAlert(String title, String content) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            new TextButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _Triangle extends StatelessWidget {
  const _Triangle({
    Key? key,
    this.color = Colors.white,
  }) : super(key: key);
  final Color color;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _ShapesPainter(color),
        child: Container(
            height: 50,
            width: 50,
            child: Center(
                child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, bottom: 16),
                    child: Transform.rotate(
                        angle: math.pi / 4,
                        child: const Text('',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            )))))));
  }
}

class _ShapesPainter extends CustomPainter {
  final Color color;
  _ShapesPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = color;
    var path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.height, size.width);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
