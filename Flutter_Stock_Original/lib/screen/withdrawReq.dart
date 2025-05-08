import 'dart:convert';
import 'dart:io';

import 'package:Nippostock/config/constant.dart';
import 'package:Nippostock/models/customer.dart';
import 'package:Nippostock/models/delivery.dart';
import 'package:Nippostock/models/inventory.dart';
import 'package:Nippostock/models/receiveDetail.dart';
import 'package:Nippostock/models/stockbalance.dart';
import 'package:Nippostock/models/statusCheck.dart';
import 'package:Nippostock/models/withdrawReq.dart';
import 'package:Nippostock/models/withdrawReqDetail.dart';
import 'package:Nippostock/widgets/responsive.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:Nippostock/models/product.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:convert' as convert;
import 'menu_drawer.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class WithdrawReqPage extends StatefulWidget {
  WithdrawReqPage({Key? key}) : super(key: key);

  @override
  _WithdrawReqPageState createState() => _WithdrawReqPageState();
}

class _WithdrawReqPageState extends State<WithdrawReqPage> {
  late bool visible;

  @override
  void initState() {
    super.initState();
    getCustomer();
    getInventory();
    getWithdrawReqID();
    getDataPref();

    _selected = delivery[0];
  }

  String _scanBarcode = 'Unknown';
  final _txtBarcode = TextEditingController();
  int Count = 0;
  int SumValue = 0;
  int SumValueHistory = 0;

  int totallist = 0;
  int totalpcs = 0;

  List<Product> _productlist = [];
  List<StockBalance> _stockbalance = [];
  List<dynamic> _inventory = [];
  List<ReceiveDetail> _receveDetail = [];
  final GlobalKey<FormState> _formKey = GlobalKey();
  dynamic inventory = 0;

  final _txtdocumentID = TextEditingController();
  final _txtdocumentDate = TextEditingController();
  final _txtdocumentRef = TextEditingController();
  final _txtdocumentRefDate = TextEditingController();
  final _txtuserWithdraw = TextEditingController();
  final _txtRemark = TextEditingController();

  final _txtSearchDocument = TextEditingController();
  final _txtSearchDateStart = TextEditingController();
  final _txtSearchDateEnd = TextEditingController();
  final _txtCount = TextEditingController();

  bool _showButton = true;

  bool isLoading = true;

  List<Product> count = [];

  // inventory
  List<DropdownMenuItem<Inventory>> _dropdownMenuItems = [];
  Inventory? _selectedItem;

  List<DropdownMenuItem<WithdrawReqHead>> _dropdownMenuItemsHistory = [];
  WithdrawReqHead? _selectedItemHistory;
  // inventory

  List<DropdownMenuItem<Customer>> _dropdownMenuItemsCustomer = [];
  Customer? _selectedItemCustomer;

  List<DropdownMenuItem<WithdrawReqHead>> _dropdownMenuItemCustomerHistory = [];
  WithdrawReqHead? _selectCustomerHistory;

  Delivery? _selected;
  Delivery? _selectedHistory;

  StatusCheck? _selectedStatusCheck;
  StatusCheck? __selectedStatusCheckHistory;

  List<StatusCheck> statuscheck = <StatusCheck>[
    const StatusCheck(1, 'Normal'),
    const StatusCheck(0, 'Cancle')
  ];

  String? _setting_nd;
  String? _name = "";
  String? _fullname = "";
  String? _userId = "";
  bool _checkSearch = true;

  List<WithdrawReqHead> _withdrawReqHead = [];
  List<WithdrawReqDetail> _withdrawReqDetail = [];

  List<Delivery> delivery = <Delivery>[
    const Delivery(0, "มารับเองที่คลัง"),
    const Delivery(1, "ขนส่งบริษัท")
  ];

  String withReq = "";
  bool _showHistory = true;
  bool _showButtonSave = false;
  int productCount = 0;

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

  // ดึงประวัติใบขอเบิก
  List<DropdownMenuItem<WithdrawReqHead>> buildDropDownMenuItemsHistory(
      List listItems) {
    List<DropdownMenuItem<WithdrawReqHead>> items = [];
    for (int i = 0; i <= listItems.length - 1; i++) {
      WithdrawReqHead listItem = listItems[i];
      items.add(
        DropdownMenuItem(
          child: Text(listItem.f_wareName),
          value: listItem,
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<Customer>> buildDropDownMenuItemsCustomer(
      List listItems) {
    List<DropdownMenuItem<Customer>> items = [];
    for (int i = 0; i <= listItems.length - 1; i++) {
      Customer listItem = listItems[i];
      items.add(
        DropdownMenuItem(
          child: Text(listItem.f_cusName),
          value: listItem,
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<WithdrawReqHead>> buildDropDownMenuItemsCustomerHistory(
      List listItems) {
    List<DropdownMenuItem<WithdrawReqHead>> items = [];
    for (int i = 0; i <= listItems.length - 1; i++) {
      WithdrawReqHead listItem = listItems[i];
      items.add(
        DropdownMenuItem(
          child: Text(listItem.f_cusName),
          value: listItem,
        ),
      );
    }
    return items;
  }

  Future<void> getWithDrawReqHistoryByID(Map<dynamic, dynamic> values) async {
    String url = server + "/api/withdrawReq/historyAll/";
    final responce = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: convert.jsonEncode({
          'f_withReqID': values['f_withReqID'],
          'f_dateStart': values['f_dateStart'],
          'f_dateEnd': values['f_dateEnd'],
          'f_withReqStatus': values['f_withReqStatus']
        }));
    final jsonResponce = json.decode(responce.body);

    List<WithdrawReqHead> temp = (jsonResponce['data'] as List)
        .map((item) => WithdrawReqHead.fromJson(item))
        .toList();

    if (mounted) {
      setState(() {
        _withdrawReqHead.clear();
        _withdrawReqHead.addAll(temp);

        Navigator.pop(context);
        showAlertgetWithdrawReqMobile();
        // Responsive.isMobile(context)
        //     ? showAlertgetWithdrawReqMobile()
        //     : showAlertgetWithdrawReqTablet();
      });
    }
  }

  Future<void> getWithdrawReqAll() async {
    String url = server + "/api/withdrawReq";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    final jsonResponce = json.decode(responce.body);
    List<WithdrawReqHead> temp = (jsonResponce['data'] as List)
        .map((item) => WithdrawReqHead.fromJson(item))
        .toList();

    if (mounted) {
      setState(() {
        _selectedStatusCheck = statuscheck[0];
        _txtSearchDocument.clear();
        _txtSearchDateStart.clear();
        _txtSearchDateEnd.clear();

        DateTime _dateStart;
        DateTime _dateEnd;
        _dateStart = DateTime.now().subtract(Duration(days: 45));
        _dateEnd = DateTime.now();

        _txtSearchDateStart.text =
            '${DateFormat('dd-MM-yyyy').format(_dateStart)}';
        _txtSearchDateEnd.text = '${DateFormat('dd-MM-yyyy').format(_dateEnd)}';

        _withdrawReqHead.clear();
        _withdrawReqHead.addAll(temp);

        // showAlertgetWithdrawReqTablet();
        // Responsive.isMobile(context)
        //     ? showAlertgetWithdrawReqMobile()
        //     : ;

        showAlertgetWithdrawReqMobile();
        // Responsive.isMobile(context)
        //     ? showAlertgetWithdrawReqMobile()
        //     : showAlertgetWithdrawReqTablet();
      });
    }
  }

  // ดึงประวัติการค้นหาจาก History ออกมา
  Future<void> getWithdrawReqIDAfter(String id) async {
    // print("OK");
    String url = server + "/api/withdrawReq/'${id}'";
    final response = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(response.body);

    List<WithdrawReqHead> temp = (jsonResponce['data'] as List)
        .map((itemWord) => WithdrawReqHead.fromJson(itemWord))
        .toList();

    if (mounted) {
      setState(
        () {
          _withdrawReqHead.clear();
          _withdrawReqHead.addAll(temp);

          // print("OK");
          // print(_withdrawReqHead[0].f_cusName);

          if (_withdrawReqHead.length > 0) {
            _txtdocumentID.text = _withdrawReqHead[0].f_withReqID;
            _showButton = false;
            _showHistory = true;

            if (_withdrawReqHead[0].f_withReqStatus != 1) {
              _showButtonSave = false;
            } else {
              _showButtonSave = true;
            }

            _txtSearchDocument.text = _withdrawReqHead[0].f_withReqID == null
                ? ''
                : _withdrawReqHead[0].f_withReqID;

            DateTime now = DateTime.now();
            _txtdocumentDate.text =
                DateFormat('dd-MM-yyyy HH:mm:ss').format(now);

            _txtuserWithdraw.text =
                _withdrawReqHead[0].f_withReqWithdrawer == null
                    ? ''
                    : _withdrawReqHead[0].f_withReqWithdrawer;

            _txtdocumentRef.text =
                _withdrawReqHead[0].f_withReqReferance == null
                    ? ''
                    : _withdrawReqHead[0].f_withReqReferance;

            _txtdocumentRefDate.text = _withdrawReqHead[0]
                        .f_withReqReferanceDate
                        .toString() !=
                    ''
                ? DateFormat('dd-MM-yyyy').format(
                    DateTime.parse(_withdrawReqHead[0].f_withReqReferanceDate))
                : 'ไม่มี';

            _txtRemark.text = _withdrawReqHead[0].f_withReqRemark == null
                ? ''
                : _withdrawReqHead[0].f_withReqRemark;

            _dropdownMenuItemsHistory = buildDropDownMenuItemsHistory(temp);
            _selectedItemHistory =
                _dropdownMenuItemsHistory[0].value as WithdrawReqHead;

            _dropdownMenuItemCustomerHistory =
                buildDropDownMenuItemsCustomerHistory(temp);
            _selectCustomerHistory =
                _dropdownMenuItemCustomerHistory[0].value as WithdrawReqHead;
          }
        },
      );
    }

    getWithdrawReqDetail(id);
  }

  // todo build Product list
  Future<void> getWithdrawReqDetail(String id) async {
    String url = server + "/api/withdrawReqDetail/${id}";
    final response = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(response.body);
    print(jsonResponce['data']);

    List<WithdrawReqDetail> temp = (jsonResponce['data'] as List)
        .map((itemWord) => WithdrawReqDetail.fromJson(itemWord))
        .toList();

    if (mounted) {}
    setState(() {
      _productlist.clear();
      _withdrawReqDetail.clear();
      _withdrawReqDetail.addAll(temp);
      sumValueHistory();
      totallist = temp.length;
      // if (_withdrawReqDetail.length > 0) {
      //   productCount = _withdrawReqDetail.length;
      // }
    });
  }

  Future<void> showAlertgetWithdrawReqTablet() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
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
                            Text(
                              'Withdraw Request ( ใบขอเบิก )',
                              style: TextStyle(
                                color: Color.fromRGBO(255, 130, 68, 1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.10,
                      width: MediaQuery.of(context).size.width - 60,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 40,
                                width: 100,
                                color: Color.fromRGBO(255, 130, 68, 1),
                                margin: EdgeInsets.only(bottom: 5),
                                child: Center(
                                  child: Text(
                                    'เลขที่ใบขอเบิก',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: 160,
                                  height: 40,
                                  color: Colors.white,
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor: Colors.white,
                                    ),
                                    controller: _txtSearchDocument,
                                    decoration: InputDecoration(
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
                              SizedBox(
                                width: 20,
                              ),
                              Container(
                                width: 110,
                                height: 40,
                                margin: EdgeInsets.only(bottom: 5),
                                color: Colors.white,
                                child: TextFormField(
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
                                    contentPadding: EdgeInsets.only(left: 10),
                                    labelStyle: TextStyle(fontSize: mediumText),
                                    labelText: 'วันที่เริ่มต้น',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(255, 130, 68, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(255, 130, 68, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 1),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Container(
                                width: 110,
                                height: 40,
                                margin: EdgeInsets.only(bottom: 5),
                                color: Colors.white,
                                child: TextFormField(
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
                                    contentPadding: EdgeInsets.only(left: 10),
                                    labelStyle: TextStyle(fontSize: mediumText),
                                    labelText: 'วันที่สุดท้าย',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(255, 130, 68, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(255, 130, 68, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 1),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Container(
                                width: 110,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromRGBO(255, 130, 68, 1),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.only(left: 10),
                                margin: EdgeInsets.only(bottom: 5),
                                child: new DropdownButton<StatusCheck>(
                                  underline: SizedBox.shrink(),
                                  isExpanded: true,
                                  value: _selectedStatusCheck,
                                  onChanged: (newValue) {
                                    if (mounted) {
                                      setState(() {
                                        _selectedStatusCheck = newValue;
                                      });
                                    }
                                  },
                                  items: statuscheck.map(
                                    (StatusCheck _check) {
                                      return new DropdownMenuItem<StatusCheck>(
                                        value: _check,
                                        child: new Text(_check.name),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
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
                                'f_withReqID':
                                    _txtSearchDocument.text.toString() != ''
                                        ? _txtSearchDocument.text.toString()
                                        : '',
                                'f_dateStart': _dateStart,
                                'f_dateEnd': _dateEnd,
                                'f_withReqStatus': _selectedStatusCheck!.id
                              };

                              if (data.length > 0) {
                                getWithDrawReqHistoryByID(data);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 130, 68, 1),
                              ),
                              width: MediaQuery.of(context).size.width - 60,
                              height: 50,
                              child: Center(
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
                          itemCount: _withdrawReqHead.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 6,
                              margin: EdgeInsets.all(10),
                              child: ListTile(
                                onTap: () {
                                  // ใบขอเบิก
                                  getWithdrawReqIDAfter(
                                      _withdrawReqHead[index].f_withReqID);
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
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                'เลขที่ใบขอเบิก : ${_withdrawReqHead[index].f_withReqID}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'วันที่ขอเบิก : ${_withdrawReqHead[index].f_withReqDate == '' ? '' : DateFormat('dd-MM-yyyy').format(DateTime.parse(_withdrawReqHead[index].f_withReqDate))}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'ผู้ขอเบิกสินค้า : ${_withdrawReqHead[index].f_withReqWithdrawer}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      _showStatusTablet(_withdrawReqHead[index]
                                          .f_withReqStatus),
                                    ],
                                  ),
                                ),
                                leading: Icon(
                                  Icons.analytics_outlined,
                                  size: 60,
                                  color: Color.fromRGBO(255, 130, 68, 1),
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
                            '${_withdrawReqHead.length} Records.',
                            style: TextStyle(color: Colors.black),
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

  Future<void> showAlertgetWithdrawReqMobile() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                // physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
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
                                'Withdraw Request ( ใบขอเบิก )',
                                style: TextStyle(
                                  color: Color.fromRGBO(255, 130, 68, 1),
                                  fontSize:
                                      MediaQuery.of(context).size.width / 35,
                                ),
                              ),
                            ),
                            _Triangle(
                              color: Color.fromRGBO(255, 130, 68, 1),
                            )
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      // height: MediaQuery.of(context).size.height * 0.2,
                      // width: MediaQuery.of(context).size.width - 60,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 30,
                                width: MediaQuery.of(context).size.width / 6,
                                color: Color.fromRGBO(255, 130, 68, 1),
                                margin: EdgeInsets.only(bottom: 5),
                                child: Center(
                                  child: Text(
                                    'เลขที่ใบขอเบิก',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                45),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 6,
                                  height: 30,
                                  color: Colors.white,
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              45,
                                      backgroundColor: Colors.white,
                                    ),
                                    controller: _txtSearchDocument,
                                    decoration: InputDecoration(
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
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  // width:(MediaQuery.of(context).size.width/5),
                                  height: 30,
                                  margin: EdgeInsets.only(bottom: 5),
                                  color: Colors.white,
                                  child: TextFormField(
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
                                      contentPadding: EdgeInsets.only(left: 10),
                                      labelStyle: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30),
                                      labelText: 'วันที่เริ่มต้น',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color:
                                              Color.fromRGBO(255, 130, 68, 1),
                                          width: 2.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color:
                                              Color.fromRGBO(255, 130, 68, 1),
                                          width: 2.0,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red, width: 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  // width: MediaQuery.of(context).size.width/5,
                                  height: 30,
                                  margin: EdgeInsets.only(bottom: 5),
                                  color: Colors.white,
                                  child: TextFormField(
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              40,
                                    ),
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
                                      contentPadding: EdgeInsets.only(left: 10),
                                      labelStyle: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30),
                                      labelText: 'วันที่สุดท้าย',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color:
                                              Color.fromRGBO(255, 130, 68, 1),
                                          width: 2.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color:
                                              Color.fromRGBO(255, 130, 68, 1),
                                          width: 2.0,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red, width: 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  // width: MediaQuery.of(context).size.width/5,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color.fromRGBO(255, 130, 68, 1),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: EdgeInsets.only(left: 10),
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: new DropdownButton<StatusCheck>(
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                40,
                                        color: Colors.black),
                                    underline: SizedBox.shrink(),
                                    isExpanded: true,
                                    value: _selectedStatusCheck,
                                    onChanged: (newValue) {
                                      if (mounted) {
                                        setState(() {
                                          _selectedStatusCheck = newValue;
                                        });
                                      }
                                    },
                                    items: statuscheck.map(
                                      (StatusCheck _check) {
                                        return new DropdownMenuItem<
                                            StatusCheck>(
                                          value: _check,
                                          child: new Text(_check.name),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
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
                                'f_withReqID':
                                    _txtSearchDocument.text.toString() != ''
                                        ? _txtSearchDocument.text.toString()
                                        : '',
                                'f_dateStart': _dateStart,
                                'f_dateEnd': _dateEnd,
                                'f_withReqStatus': _selectedStatusCheck!.id
                              };

                              if (data.length > 0) {
                                getWithDrawReqHistoryByID(data);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 130, 68, 1),
                              ),
                              width: MediaQuery.of(context).size.width - 60,
                              height: 30,
                              child: Center(
                                child: Text(
                                  'Load Data',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 40,
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
                          itemCount: _withdrawReqHead.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 6,
                              margin: EdgeInsets.all(5),
                              child: ListTile(
                                onTap: () {
                                  // ใบขอเบิก
                                  getWithdrawReqIDAfter(
                                      _withdrawReqHead[index].f_withReqID);
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Text(
                                                  'เลขที่ใบขอเบิก : ${_withdrawReqHead[index].f_withReqID}',
                                                  style: TextStyle(fontSize: 9),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  'วันที่ขอเบิก : ${_withdrawReqHead[index].f_withReqDate == '' ? '' : DateFormat('dd-MM-yyyy').format(DateTime.parse(_withdrawReqHead[index].f_withReqDate))}',
                                                  style: TextStyle(fontSize: 9),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  'ผู้ขอเบิกสินค้า : ${_withdrawReqHead[index].f_withReqWithdrawer}',
                                                  style: TextStyle(fontSize: 9),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Responsive.isMobile(context)
                                          ? _showStatusMobile(
                                              _withdrawReqHead[index]
                                                  .f_withReqStatus)
                                          : _showStatusTablet(
                                              _withdrawReqHead[index]
                                                  .f_withReqStatus),
                                    ],
                                  ),
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
                        Text(
                          '${_withdrawReqHead.length} Records.',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width / 40),
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

  // ดึงประวัติใบขอเบิก

  _showStatusTablet(int _text) {
    String _content;
    if (_text == 1) {
      _content = "Waiting";
    } else if (_text == 2) {
      _content = "Success";
    } else {
      _content = "Cancle";
    }

    return Container(
      width: 100,
      height: 30,
      decoration: BoxDecoration(
        color: _StatusColors(_text),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Center(
        child: Text(
          _content,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  _showStatusMobile(int _text) {
    String _content;
    if (_text == 1) {
      _content = "Waiting";
    } else if (_text == 2) {
      _content = "Success";
    } else {
      _content = "Cancle";
    }

    return Container(
      width: 50,
      height: 30,
      decoration: BoxDecoration(
        color: _StatusColors(_text),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Center(
        child: Text(
          _content,
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
          ),
        ),
      ),
    );
  }

  _StatusColors(int _text) {
    if (_text == 1) {
      return Colors.orange;
    } else if (_text == 2) {
      return Colors.green[600];
    } else {
      return Colors.red;
    }
  }

  Future<void> insertWithdrawReqHead(Map<String, dynamic> values) async {
    String url = server + "/api/withdrawReq/insert";
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {
          'f_withReqID': values['f_withReqID'],
          'f_withReqDate': values['f_withReqDate'],
          'f_withReqRemark': values['f_withReqRemark'],
          'f_withReqStatus': values['f_withReqStatus'],
          'f_withReqWithdrawerID': values['f_withReqWithdrawerID'],
          'f_withReqWithdrawer': values['f_withReqWithdrawer'],
          'f_withReqReferance': values['f_withReqReferance'],
          'f_withReqReferanceDate': values['f_withReqReferanceDate'],
          'f_withReqTo': values['f_withReqTo'],
          'f_wareID': values['f_wareID'],
          'f_needDelivery': values['f_needDelivery'],
        },
      ),
    );

    if (response.statusCode == 200) {
      for (int i = 0; i < _productlist.length; i++) {
        var product = {};
        product.clear();

        product = {
          'f_withReqID': _txtdocumentID.text.toString(),
          'f_prodID': _productlist[i].f_prodID,
          'f_withReqQty': _productlist[i].QTY
        };

        //insert WithdrawReq Detail
        insertWithdrawReqDetail(product);
      }
      if (mounted) {
        setState(() {
          SumValue = 0;
          _productlist.clear();

          _txtdocumentID.clear();
          _txtdocumentDate.clear();
          _txtdocumentRef.clear();
          _txtdocumentRefDate.clear();
          _txtuserWithdraw.clear();
          _txtRemark.clear();

          getWithdrawReqID();
          getDataPref();
        });
      }

      return _onAlertButtonPressed(context);
    }
  }

  Future<void> insertWithdrawReqDetail(Map<dynamic, dynamic> values) async {
    String url = server + "/api/withdrawReqDetail/insert";
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {
          'f_withReqID': values['f_withReqID'],
          'f_prodID': values['f_prodID'],
          'f_withReqQty': values['f_withReqQty']
        },
      ),
    );

    // if (response.statusCode == 200) {
    //   return _onAlertButtonPressed(context);
    // }
  }

  //dropdown Inventory
  Future<void> getInventory() async {
    String url = server + "/api/inventory";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(responce.body);
    List<Inventory> temp = (jsonResponce['data'] as List)
        .map((itemWord) => Inventory.fromJson(itemWord))
        .toList();

    if (temp.length > 0) {
      _dropdownMenuItems = buildDropDownMenuItems(temp);
      _selectedItem = _dropdownMenuItems[0].value as Inventory;
    }
  }

  // dropdown customer
  Future<void> getCustomer() async {
    String url = server + "/api/customer";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(responce.body);
    List<Customer> temp = (jsonResponce['data'] as List)
        .map((item) => Customer.fromJson(item))
        .toList();

    if (mounted) {
      setState(() {
        _dropdownMenuItemsCustomer = buildDropDownMenuItemsCustomer(temp);
        if (temp.length > 0) {
          _selectedItemCustomer =
              _dropdownMenuItemsCustomer[0].value as Customer;
        }
      });
    }
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
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            width: 120,
            onPressed: () {
              Navigator.pop(context);
            })
      ],
    ).show();
  }

  // Gen WithdrawReq
  Future<void> getWithdrawReqID() async {
    String url = server + "/api/withdrawReq/getID";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(responce.body);
    var temp = jsonResponce['data'];

    Map<String, dynamic> ID;
    String documentID = "";

    if (temp.isEmpty ?? true) {
      documentID = "";
    } else {
      ID = temp[0];
      documentID = ID.values.first;
    }

    // = temp[0];

    //  ID.values.first;

    String RR = "WQ";
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
    String encodedId = Uri.encodeComponent(id.replaceAll("'", ""));
    String warehouseID = Uri.encodeComponent(wareID);
    String url = server + "/api/product/'$encodedId'/'$warehouseID'";
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
        if (_setting_nd == "0") {
          if (temp[product_all].QTY > 0) {
            if (_productlist[product].QTY_all > _productlist[product].QTY) {
              _productlist[product].QTY = _productlist[product].QTY + 1;

              if (mounted) {
                setState(
                  () {
                    productCount = _productlist.length + 1;
                    _txtBarcode.clear();
                    sumValue();
                  },
                );
              }
            } else {
              if (_productlist[product].QTY_all == _productlist[product].QTY) {
                _txtBarcode.clear();
                final snackBar = SnackBar(
                  content: Text('สินค้าในคลังไม่เพียงพอ'),
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            }
          } else {
            _txtBarcode.clear();
            final snackBar = SnackBar(
              content: Text('สินค้าในคลังไม่เพียงพอ'),
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          if (mounted) {
            setState(
              () {
                _productlist[product].QTY = _productlist[product].QTY + 1;
                productCount = _productlist.length + 1;
                _txtBarcode.clear();
                sumValue();
              },
            );
          }
        }
      } else {
        if (mounted) {
          setState(
            () {
              _productlist.addAll(temp);
              productCount = _productlist.length + 1;
              _txtBarcode.clear();
              sumValue();
            },
          );
        }
      }
    } else {
      _txtBarcode.clear();
      final snackBar = SnackBar(
        content: Text('ไม่พบรายการสินค้า หรือจำนวนสินค้าไม่เเพียงพอ'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> getStockBalanceBywareID(String wareID) async {
    String url = server + "/api/stockbalance/'${wareID}'";
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
        showAlertProductAllInWarehouse();
      });
    }
  }

  Future<void> showAlertProductAllInWarehouse() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                // physics: NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.white,
                        child: ListView.builder(
                          itemCount: _stockbalance.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 6,
                              margin: EdgeInsets.all(5),
                              child: ListTile(
                                onTap: () {
                                  // ใบขอเบิก
                                  getProduct(_stockbalance[index].f_Barcode,
                                      _selectedItem!.f_wareID);
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
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
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                    ),
                                                    SizedBox(
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
                                                      'คงเหลือ : ${NumberFormat.decimalPattern().format(_stockbalance[index].QTY)}',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            35,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
                        Text(
                          '${_stockbalance.length} Records.',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width / 40),
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

  Future<void> sumValue() async {
    SumValue = 0;
    for (int i = 0; i < _productlist.length; i++) {
      SumValue = SumValue + _productlist[i].QTY;
    }
  }

  Future<void> sumValueHistory() async {
    SumValue = 0;
    for (int i = 0; i < _withdrawReqDetail.length; i++) {
      SumValue = SumValue + _withdrawReqDetail[i].f_withReqQty;
    }
  }

  // Scan Barcode
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

      getProduct(barcodeScanRes, _selectedItem!.f_wareID);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
  }

  // show Status
  _showStatus(int _text) {
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
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Center(
        child: Text(
          _content,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  getDataPref() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? id = prefs.getString("userID");
    String? name = prefs.getString("userName");
    String? fullname = prefs.getString("fullName");
    String? setting_nd = prefs.getString("f_negativeDrawdown");

    if (mounted) {
      setState(() {
        _name = name;
        _fullname = fullname;
        _userId = id;
        _txtuserWithdraw.text = fullname.toString();
        _setting_nd = setting_nd;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int count = 0;

    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : VisibilityDetector(
            onVisibilityChanged: (VisibilityInfo info) {
              visible = info.visibleFraction > 0;
            },
            key: Key('visible-detector-key'),
            child: BarcodeKeyboardListener(
                bufferDuration: Duration(milliseconds: 200),
                onBarcodeScanned: (barcode) {
                  if (!visible) return;
                  if (barcode.isEmpty) {
                    print("no-barcode");
                  } else {
                    print("barcode");
                    print(barcode);

                    getProduct(barcode, _selectedItem!.f_wareID);
                  }
                  // setState(() {
                  //   _barcode = barcode;
                  // });
                },
                child: Scaffold(
                  // resizeToAvoidBottomInset: false,
                  backgroundColor: Colors.grey[200],
                  drawer: new Drawer(
                    child: MenuDrawer(),
                  ),
                  appBar: AppBar(
                    iconTheme: IconThemeData(
                      color: Color.fromRGBO(255, 130, 68, 1),
                    ),
                    title: Text(
                      'Withdraw Request ( ขอเบิกสินค้า )',
                      style: TextStyle(
                        color: Color.fromRGBO(255, 130, 68, 1),
                        fontSize: Responsive.isMobile(context) ? 13 : 24,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0,
                    actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  WithdrawReqPage(),
                            ),
                          );
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
                          getWithdrawReqAll();
                        },
                        icon: Icon(
                          Icons.description_sharp,
                          size: Responsive.isMobile(context) ? 20 : 24,
                        ),
                      ),
                    ],
                  ),
                  body: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _buildMobile(context),
                  //  Responsive.isMobile(context)
                  //     ? _buildMobile(context)
                  //     : _buildTablet(context),
                  bottomNavigationBar: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        // height: _showButton
                        //     ? MediaQuery.of(context).size.height * 0.15
                        //     : MediaQuery.of(context).size.height * 0.1,
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 30,
                                    width: MediaQuery.of(context).size.width *
                                        0.40,
                                    // color: Color.fromRGBO(255, 130, 68, 1),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 8),
                                      child: Text(
                                        'ผู้ขอเบิกสินค้า ${_txtuserWithdraw.text}',
                                        style: TextStyle(
                                          color:
                                              Color.fromRGBO(255, 130, 68, 1),
                                          // fontSize: Responsive.isMobile(context) ? 12 : 18
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 1,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20, top: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: Responsive.isMobile(context) ? 3 : 5,
                                    child: Text(
                                      // 'Total ${totallist != 0 ? totallist : 0} list.',
                                      'Total ${_productlist.length > 0 ? _productlist.length : _withdrawReqDetail.length} list.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        // fontSize: 9,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Total  ${SumValue}  pcs.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        // fontSize: 9,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            _showButton
                                ? (SumValue > 0
                                    ? _buildButtonSave()
                                    : SizedBox.shrink())
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                useKeyDownEvent: Platform.isWindows));
  }

  // view Tablet
  Widget _buildTablet(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
          width: MediaQuery.of(context).size.width,
          //height: MediaQuery.of(context).size.height * 0.13,
          height: MediaQuery.of(context).size.height * 0.18,
          decoration: BoxDecoration(
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
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Color.fromRGBO(255, 130, 68, 1),
                        child: Center(
                          child: Text(
                            'เลขที่เอกสาร',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.28,
                        height: 40,
                        color: Colors.black,
                        margin: EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          enabled: _showButton,
                          readOnly: true,
                          style: TextStyle(
                            color: Colors.yellow,
                            backgroundColor: Colors.black,
                          ),
                          controller: _txtdocumentID,
                          decoration: InputDecoration(
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
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Color.fromRGBO(255, 130, 68, 1),
                        child: Center(
                          child: Text(
                            'วันที่บันทึก',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.28,
                        height: 40,
                        color: Colors.black,
                        margin: EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          enabled: _showButton,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 45,
                            color: Colors.yellow,
                            // backgroundColor: Colors.black
                          ),
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
                          decoration: InputDecoration(
                            // labelText: 'วันที่บันทึก',
                            labelStyle: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 45),
                            border: OutlineInputBorder(),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 5),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Color.fromRGBO(255, 130, 68, 1),
                        child: Center(
                          child: Text(
                            'เอกสารอ้างอิง',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.28,
                        height: 40,
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 5),
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
                          decoration: InputDecoration(
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
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Color.fromRGBO(255, 130, 68, 1),
                        child: Center(
                          child: Text(
                            'วันที่เอกสารอ้างอิง',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.28,
                        height: 40,
                        // margin: EdgeInsets.only(bottom: 10),
                        margin: EdgeInsets.only(bottom: 5),
                        color: Colors.white,
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
                          decoration: InputDecoration(
                            hintText: "กรุณาเลือกวัน",
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Color.fromRGBO(255, 130, 68, 1),
                        child: Center(
                          child: Text(
                            'คลังสินค้า',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      _showButton
                          ? _buildDropdownInventory()
                          : _buildDropdownInventoryHistory(),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Color.fromRGBO(255, 130, 68, 1),
                        child: Center(
                          child: Text(
                            'ผู้รับ/ลูกค้า',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      _showButton
                          ? _buildDropdownCustomer()
                          : _buildDropdownCustomerHistory()
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Color.fromRGBO(255, 130, 68, 1),
                        child: Center(
                          child: Text(
                            'ประเภทการจัดส่ง',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      // todo delivery
                      Container(
                        width: MediaQuery.of(context).size.width * 0.28,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: EdgeInsets.only(left: 10),
                        margin: EdgeInsets.only(bottom: 5),
                        child: new DropdownButton<Delivery>(
                          underline: SizedBox.shrink(),
                          isExpanded: true,
                          value: _selected,
                          onChanged: (newValue) {
                            if (mounted) {
                              setState(() {
                                _selected = newValue;
                              });
                            }
                          },
                          items: delivery.map(
                            (Delivery _check) {
                              return new DropdownMenuItem<Delivery>(
                                value: _check,
                                child: new Text(_check.name),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Color.fromRGBO(255, 130, 68, 1),
                        child: Center(
                          child: Text(
                            'หมายเหตุ',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.28,
                        height: 40,
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          enabled: _showButton,
                          controller: _txtRemark,
                          decoration: InputDecoration(
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
          height: 20,
          color: Color.fromRGBO(255, 130, 68, 1),
        ),
        Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.08,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30)),
                  child: TextField(
                    enabled: _showButton,
                    controller: _txtBarcode,
                    cursorColor: Color.fromRGBO(255, 130, 68, 1),
                    maxLines: 1,
                    style: TextStyle(color: Color.fromRGBO(255, 130, 68, 1)),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent)),
                      disabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent)),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent)),
                      errorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent)),
                      suffixIcon: IconButton(
                        onPressed: () => _showButton ? scanBarcodeNormal() : '',
                        icon: Icon(
                          Icons.qr_code_scanner,
                          color: _showButton
                              ? Color.fromRGBO(255, 130, 68, 1)
                              : Colors.grey,
                        ),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 15,
        ),
        _productlist.length > 0 ? _buildProduct() : _buildHistoryProduct(),
      ],
    );
  }

  // view Mobile
  Widget _buildMobile(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: _productlist.length > 0
            ? MediaQuery.of(context).size.height * 0.74
            : MediaQuery.of(context).size.height * 0.84,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 0, left: 5, right: 5, bottom: 0),
              width: MediaQuery.of(context).size.width,
              //height: MediaQuery.of(context).size.height * 0.13,
              // height: _showHistory
              //     ? MediaQuery.of(context).size.height * 0.22
              //     : MediaQuery.of(context).size.height * 0.22,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Color.fromRGBO(255, 130, 68, 1),
                            child: Center(
                              child: Text(
                                'เลขที่เอกสาร',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 1,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3.67,
                            height: MediaQuery.of(context).size.height / 34,
                            color: Colors.black,
                            margin: EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              enabled: _showButton,
                              readOnly: true,
                              style: TextStyle(
                                color: Colors.yellow,
                                backgroundColor: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width / 50,
                              ),
                              controller: _txtdocumentID,
                              decoration: InputDecoration(
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
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Color.fromRGBO(255, 130, 68, 1),
                            child: Center(
                              child: Text(
                                'วันที่บันทึก',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 1,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3.25,
                            height: MediaQuery.of(context).size.height / 34,
                            color: Colors.black,
                            // margin: EdgeInsets.only(bottom: 5),
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
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
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
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Color.fromRGBO(255, 130, 68, 1),
                            child: Center(
                              child: Text(
                                'เอกสารอ้างอิง',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 1,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3.67,
                            height: MediaQuery.of(context).size.height / 34,
                            color: Colors.white,
                            margin: EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50),
                              enabled: _showButton,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  // showMessageAlert(
                                  //     "Alert ", "Please insert document ref !");
                                }
                                return null;
                              },
                              controller: _txtdocumentRef,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
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
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Color.fromRGBO(255, 130, 68, 1),
                            child: Center(
                              child: Align(
                                child: Text(
                                  'วันที่เอกสารอ้างอิง',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 65,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 1,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3.25,
                            height: MediaQuery.of(context).size.height / 34,
                            // margin: EdgeInsets.only(bottom: 10),
                            margin: EdgeInsets.only(bottom: 5),
                            color: Colors.white,
                            child: TextFormField(
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50),
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
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
                                hintText: "กรุณาเลือกวัน",
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Color.fromRGBO(255, 130, 68, 1),
                            child: Center(
                              child: Text(
                                'คลังสินค้า',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 1,
                          ),
                          _showButton
                              ? _buildDropdownInventory()
                              : _buildDropdownInventoryHistory(),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Color.fromRGBO(255, 130, 68, 1),
                            child: Center(
                              child: Text(
                                'ผู้รับ/ลูกค้า',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 1,
                          ),
                          _showButton
                              ? _buildDropdownCustomer()
                              : _buildDropdownCustomerHistory()
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Color.fromRGBO(255, 130, 68, 1),
                            child: Center(
                              child: Align(
                                child: Text(
                                  'ประเภทการจัดส่ง',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 65,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 1,
                          ),
                          // todo delivery
                          Container(
                            width: MediaQuery.of(context).size.width / 3.67,
                            height: MediaQuery.of(context).size.height / 34,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.only(left: 10),
                            margin: EdgeInsets.only(bottom: 5),
                            child: new DropdownButton<Delivery>(
                              underline: SizedBox.shrink(),
                              style: TextStyle(
                                fontSize: Responsive.isMobile(context)
                                    ? MediaQuery.of(context).size.width / 50
                                    : 16.0,
                                fontFamily: 'Sarabun',
                                color: Colors.black,
                              ),
                              isExpanded: true,
                              value: _selected,
                              onChanged: (newValue) {
                                if (mounted) {
                                  setState(() {
                                    _selected = newValue;
                                  });
                                }
                              },
                              items: delivery.map(
                                (Delivery _check) {
                                  return new DropdownMenuItem<Delivery>(
                                    value: _check,
                                    child: new Text(_check.name),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: Color.fromRGBO(255, 130, 68, 1),
                            child: Center(
                              child: Text(
                                'หมายเหตุ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 1,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3.25,
                            height: MediaQuery.of(context).size.height / 34,
                            color: Colors.white,
                            margin: EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50),
                              enabled: _showButton,
                              controller: _txtRemark,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
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
                      // SizedBox(
                      //   height: MediaQuery.of(context).size.height / 27,
                      // )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 10,
              color: Color.fromRGBO(255, 130, 68, 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          _showButton
                              ? getStockBalanceBywareID(_selectedItem!.f_wareID)
                              : '';
                        },
                        icon: Icon(
                          Icons.search,
                          size: Responsive.isMobile(context) ? 20 : 24,
                          color: _showButton
                              ? Color.fromRGBO(255, 130, 68, 1)
                              : Colors.grey,
                        ),
                      )
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.865,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // borderRadius: BorderRadius.only(
                        //   bottomLeft: Radius.circular(30),
                        //   bottomRight: Radius.circular(30),
                        // ),
                      ),
                      child: Container(
                        // margin: EdgeInsets.only(top: 10, bottom: 10),
                        padding: EdgeInsets.only(top: 5, bottom: 5, right: 5),
                        decoration: BoxDecoration(
                            // color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30)),
                        child: TextField(
                          onSubmitted: (value) => {
                            _txtBarcode.text.isEmpty
                                ? ""
                                : getProduct(
                                    value.toString(), _selectedItem!.f_wareID)
                          },
                          enabled: _showButton,
                          controller: _txtBarcode,
                          cursorColor: Color.fromRGBO(255, 130, 68, 1),
                          maxLines: 1,
                          style:
                              TextStyle(color: Color.fromRGBO(255, 130, 68, 1)),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            disabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            focusedErrorBorder: OutlineInputBorder(
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
                                    ? Color.fromRGBO(255, 130, 68, 1)
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
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            _productlist.length > 0 ? _buildProduct() : _buildHistoryProduct(),
          ],
        ),
      ),
    );
  }

  Expanded _buildHistoryProduct() {
    return Expanded(
      child: Container(
        child: ListView.builder(
          itemCount: _withdrawReqDetail.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 6,
              margin: EdgeInsets.all(10),
              child: ListTile(
                onTap: () {},
                title: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'รหัสสินค้า : ${_withdrawReqDetail[index].f_prodID}',
                            style: TextStyle(
                                color: Colors.amber[900],
                                fontSize:
                                    Responsive.isMobile(context) ? 9 : 12),
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.green,
                            child: Text(
                              '${_withdrawReqDetail[index].f_withReqQty}',
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
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            'ชื่อสินค้า : ${_withdrawReqDetail[index].f_prodName} ',
                            style: TextStyle(
                                fontSize:
                                    Responsive.isMobile(context) ? 9 : 12),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            // color: Colors.red,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [],
                            ),
                          ),
                          SizedBox(
                            height: 10,
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
                        offset: Offset(0, 3),
                      )
                    ],
                    image: DecorationImage(
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

  Container _buildDropdownInventoryHistory() {
    return Container(
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
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
      margin: EdgeInsets.only(bottom: 5),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<WithdrawReqHead>(
          style: TextStyle(
            fontSize: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width / 50
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

  Container _buildDropdownCustomer() {
    return Container(
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
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
      margin: EdgeInsets.only(bottom: 5),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Customer>(
          style: TextStyle(
            fontSize: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width / 50
                : 16.0,
            fontFamily: 'Sarabun',
            color: Colors.black,
          ),
          isExpanded: true,
          value: _selectedItemCustomer,
          items: _dropdownMenuItemsCustomer,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                _showButton ? _selectedItemCustomer = value : '';
              });
            }
          },
        ),
      ),
    );
  }

  Container _buildDropdownCustomerHistory() {
    return Container(
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
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
      margin: EdgeInsets.only(bottom: 5),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<WithdrawReqHead>(
          style: TextStyle(
            fontSize: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width / 50
                : 16.0,
            fontFamily: 'Sarabun',
            color: Colors.black,
          ),
          isExpanded: true,
          value: _selectCustomerHistory,
          items: _dropdownMenuItemCustomerHistory,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                _showButton ? _selectCustomerHistory = value : '';
              });
            }
          },
        ),
      ),
    );
  }

  Container _buildDropdownInventory() {
    return Container(
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
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
      margin: EdgeInsets.only(bottom: 5),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Inventory>(
          style: TextStyle(
            fontSize: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width / 50
                : 16.0,
            fontFamily: 'Sarabun',
            color: Colors.black,
          ),
          isExpanded: true,
          value: _selectedItem,
          items: _dropdownMenuItems,
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

  // ปุ่ม Confirm and Save
  Row _buildButtonSave() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 5),
            child: ElevatedButton(
              onPressed: () async {
                await getWithdrawReqID();

                String _docDate = "";
                String _docRefDate = "";

                if (_txtdocumentDate.text.toString() != '') {
                  _docDate = DateFormat("dd-MM-yyyy HH:mm:ss")
                      .parse(_txtdocumentDate.text.toString())
                      .toString();
                }

                if (_txtdocumentRefDate.text.toString() != '') {
                  _docRefDate = DateFormat("dd-MM-yyyy")
                      .parse(_txtdocumentRefDate.text.toString())
                      .toString();
                }

                var value = {
                  'f_withReqID': _txtdocumentID.text.toString(),
                  'f_withReqDate': _docDate,
                  'f_withReqRemark': _txtRemark.text.toString(),
                  'f_withReqStatus': 1,
                  'f_withReqWithdrawerID': _userId.toString(),
                  'f_withReqWithdrawer': _fullname.toString(),
                  'f_withReqReferance': _txtdocumentRef.text.toString(),
                  'f_withReqReferanceDate': _docRefDate,
                  'f_withReqTo': _selectedItemCustomer!.f_cusID,
                  'f_wareID': _selectedItem!.f_wareID,
                  'f_needDelivery': _selected!.id,
                };

                //insert WithdrawReq Head
                insertWithdrawReqHead(value);

                // for (int i = 0; i < _productlist.length; i++) {
                //   var product = {};
                //   product.clear();

                //   product = {
                //     'f_withReqID': _txtdocumentID.text.toString(),
                //     'f_prodID': _productlist[i].f_prodID,
                //     'f_withReqQty': _productlist[i].QTY
                //   };

                //   //insert WithdrawReq Detail
                //   insertWithdrawReqDetail(product);
                // }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(255, 130, 68, 1),
              ),
              child: Text('Confirm'),
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
              margin: EdgeInsets.all(10),
              child: ListTile(
                onTap: () {},
                title: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _productlist[index].f_prodID,
                            style: TextStyle(
                                color: Colors.amber[900],
                                fontSize: Responsive.isMobile(context)
                                    ? MediaQuery.of(context).size.width / 45
                                    : 10),
                          ),
                          IconButton(
                              onPressed: () async {
                                final shouldDelete =
                                    await showMessageAlert_deleteitem();
                                if (shouldDelete != null) {
                                  if (shouldDelete) {
                                    if (mounted) {
                                      setState(() {
                                        if (totallist > 0) {
                                          totallist = totallist - 1;
                                        }

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
                              ))
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_productlist[index].f_prodName}',
                            style: TextStyle(
                                fontSize: Responsive.isMobile(context)
                                    ? MediaQuery.of(context).size.width / 45
                                    : 10),
                          ),
                          // SizedBox(
                          //   height: 30,
                          // ),
                          SizedBox(
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
                                                if (totallist > 0) {
                                                  totallist = totallist - 1;
                                                }
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

                                              if (_productlist[index].QTY >=
                                                  2) {
                                                _productlist[index].QTY =
                                                    _productlist[index].QTY - 1;
                                              }

                                              sumValue();
                                            },
                                          );
                                        }
                                      }
                                    },
                                    icon: Icon(Icons.remove),
                                    color: Colors.white,
                                    alignment: Alignment.center,
                                    iconSize: 15,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
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
                                            SizedBox(
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
                                              decoration: InputDecoration(
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
                                                  }
                                                } else {
                                                  _productlist[index].QTY =
                                                      int.parse(_txtCount.text);
                                                  sumValue();
                                                  Navigator.pop(context);
                                                }
                                              }
                                            },
                                            child: Text(
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
                                SizedBox(
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
                                    onPressed: () {
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
                                              _productlist[index].QTY =
                                                  _productlist[index].QTY + 1;
                                              sumValue();
                                            }
                                          },
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.add),
                                    color: Colors.white,
                                    alignment: Alignment.center,
                                    iconSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
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
                          offset: Offset(0, 3),
                        )
                      ],
                      image: DecorationImage(
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
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new TextButton(
                  child: new Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
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
                        child: Text('',
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
