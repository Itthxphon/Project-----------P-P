import 'dart:convert';

import 'package:Nippostock/config/constant.dart';
import 'package:Nippostock/models/inventory.dart';
import 'package:Nippostock/models/statusCheck.dart';
import 'package:Nippostock/models/withdrawDetail.dart';
import 'package:Nippostock/models/withdrawHead.dart';
import 'package:Nippostock/widgets/responsive.dart';
import 'package:flutter/material.dart';
import 'package:Nippostock/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert' as convert;
import 'menu_drawer.dart';
import 'dart:math' as math;
import 'package:toggle_switch/toggle_switch.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ConfirmWithdrawPage extends StatefulWidget {
  ConfirmWithdrawPage({Key? key}) : super(key: key);

  @override
  _ConfirmWithdrawPage createState() => _ConfirmWithdrawPage();
}

class _ConfirmWithdrawPage extends State<ConfirmWithdrawPage> {
  @override
  void initState() {
    super.initState();
    //getInventory();
  }

  final _txtBarcode = TextEditingController();
  int Count = 0;
  int SumValue = 0;
  List<Product> _productlist = [];
  List<WithDrawHead> _withdrawHead = [];
  List<WithDrawDetail> _withdrawDetail = [];
  int productCount = 0;
  final GlobalKey<FormState> _formKey = GlobalKey();

  List<DropdownMenuItem<Inventory>> _dropdownMenuItems = [];
  Inventory? _selectedItem;
  List<DropdownMenuItem<WithDrawHead>> _dropdownMenuItemsHistory = [];
  WithDrawHead? _selectedItemHistory;
  bool _showButton = true;
  String withReq = "";

  bool _showIndicator = true;

  final _txtdocumentID = TextEditingController();
  final _txtdocumentDate = TextEditingController();
  final _txtuserWithdraw = TextEditingController();
  final _txtdocumentRef = TextEditingController();
  final _txtdocumentRefDate = TextEditingController();
  final _txtRemark = TextEditingController();
  final _txtSearchDocument = TextEditingController();

  bool checkSuccess = false;
  bool checkCloseJob = false;

  final _txtSearchDateStart = TextEditingController();
  final _txtSearchDateEnd = TextEditingController();

  StatusCheck? _selected;
  StatusCheck? _selectedHistory;

  List<StatusCheck> statuscheck = <StatusCheck>[
    const StatusCheck(0, 'Waitcheck'),
    const StatusCheck(1, 'Checked')
  ];

  List<StatusCheck> statuscheckHistory = <StatusCheck>[
    const StatusCheck(1, 'Checked'),
  ];

  Future<void> getInventory() async {
    String url = server + "/api/inventory";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(responce.body);
    List<Inventory> temp = (jsonResponce['data'] as List)
        .map((itemWord) => Inventory.fromJson(itemWord))
        .toList();

    _dropdownMenuItems = buildDropDownMenuItems(temp);
    _selectedItem = _dropdownMenuItems[0].value as Inventory;
  }

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

  List<DropdownMenuItem<WithDrawHead>> buildDropDownMenuItemsHistory(
      List listItems) {
    List<DropdownMenuItem<WithDrawHead>> items = [];
    for (int i = 0; i <= listItems.length - 1; i++) {
      WithDrawHead listItem = listItems[i];
      items.add(
        DropdownMenuItem(
          child: Text(listItem.f_wareName),
          value: listItem,
        ),
      );
    }
    return items;
  }

  // ค้นหาเอกสารเบิกออกจากแว่นขยาย
  Future<void> getWithDrawHByShip() async {
    String url = server + "/api/withdraw/getbyship/";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    final jsonResponce = json.decode(responce.body);

    List<WithDrawHead> temp = (jsonResponce['data'] as List)
        .map((item) => WithDrawHead.fromJson(item))
        .toList();

    if (mounted) {
      setState(() {
        //checkSuccess = true;
        DateTime _dateStart;
        DateTime _dateEnd;
        _dateStart = DateTime.now().subtract(Duration(days: 45));
        _dateEnd = DateTime.now();

        _txtSearchDateStart.text =
            '${DateFormat('dd-MM-yyyy').format(_dateStart)}';
        _txtSearchDateEnd.text = '${DateFormat('dd-MM-yyyy').format(_dateEnd)}';

        _withdrawHead.clear();
        _withdrawHead.addAll(temp);
        _selected = statuscheck[0];

        //todo
        Responsive.isMobile(context)
            ? showAlertgetWithdrawMobile()
            : showAlertgetWithdrawTablet();
      });
    }
  }

  // Load Data จากแว่นขยาย
  Future<void> getWithDrawHistoryByID(Map<dynamic, dynamic> values) async {
    print(values);
    String url = server + "/api/withdraw/historyAllCheck/";
    final responce = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {
          'f_withID': values['f_withID'],
          'f_dateStart': values['f_dateStart'],
          'f_dateEnd': values['f_dateEnd'],
          'f_shippingCheck': values['f_shippingCheck']
        },
      ),
    );
    final jsonResponce = json.decode(responce.body);

    List<WithDrawHead> temp = (jsonResponce['data'] as List)
        .map((item) => WithDrawHead.fromJson(item))
        .toList();

    setState(() {
      _withdrawHead.clear();
      _withdrawHead.addAll(temp);
      Navigator.pop(context);
      Responsive.isMobile(context)
          ? showAlertgetWithdrawMobile()
          : showAlertgetWithdrawTablet();
    });
  }

  // ค้นหาเอกสาร shipsuccess จาก appbar
  Future<void> getWithDrawHByShipSuccess() async {
    String url = server + "/api/withdraw/getbyshipSuccess/";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    final jsonResponce = json.decode(responce.body);

    List<WithDrawHead> temp = (jsonResponce['data'] as List)
        .map((item) => WithDrawHead.fromJson(item))
        .toList();

    setState(() {
      checkCloseJob = true;
      DateTime _dateStart;
      DateTime _dateEnd;
      _dateStart = DateTime.now().subtract(Duration(days: 45));
      _dateEnd = DateTime.now();

      _txtSearchDateStart.text =
          '${DateFormat('dd-MM-yyyy').format(_dateStart)}';
      _txtSearchDateEnd.text = '${DateFormat('dd-MM-yyyy').format(_dateEnd)}';

      _withdrawHead.clear();
      _withdrawHead.addAll(temp);
      _selectedHistory = statuscheckHistory[0];

      //todo
      Responsive.isMobile(context)
          ? showAlertgetWithdrawHistoryMobile()
          : showAlertgetWithdrawHistoryTablet();
    });
  }

  //Load Data History
  Future<void> getWithDrawHistoryByIDAppbar(
      Map<dynamic, dynamic> values) async {
    print(values);
    String url = server + "/api/withdraw/historyAllCheck/";
    final responce = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {
          'f_withID': values['f_withID'],
          'f_dateStart': values['f_dateStart'],
          'f_dateEnd': values['f_dateEnd'],
          'f_shippingCheck': values['f_shippingCheck']
        },
      ),
    );
    final jsonResponce = json.decode(responce.body);

    List<WithDrawHead> temp = (jsonResponce['data'] as List)
        .map((item) => WithDrawHead.fromJson(item))
        .toList();

    setState(() {
      _withdrawHead.clear();
      _withdrawHead.addAll(temp);
      _selectedHistory = statuscheckHistory[0];
      Responsive.isMobile(context)
          ? showAlertgetWithdrawHistoryMobile()
          : showAlertgetWithdrawHistoryTablet();
    });
  }

  Future<void> getWithdrawID(String id) async {
    String url = server + "/api/withdraw/'${id}'";
    final response = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(response.body);

    List<WithDrawHead> temp = (jsonResponce['data'] as List)
        .map((itemWord) => WithDrawHead.fromJson(itemWord))
        .toList();

    setState(
      () {
        _withdrawHead.clear();
        _withdrawDetail.clear();
        _withdrawHead.addAll(temp);
        _txtBarcode.clear();

        if (_withdrawHead.length > 0) {
          withReq = _withdrawHead[0].f_withTo;
          _showButton = false;
          _txtdocumentID.text = _withdrawHead[0].f_withID == null
              ? ''
              : _withdrawHead[0].f_withID;

          DateTime now = DateTime.now();
          _txtdocumentDate.text = _withdrawHead[0].f_withDate == null
              ? ''
              : DateFormat('dd-MM-yyyy HH:mm:ss')
                  .format(DateTime.parse(_withdrawHead[0].f_withDate));

          _txtuserWithdraw.text = _withdrawHead[0].f_withWithdrawer == null
              ? ''
              : _withdrawHead[0].f_withWithdrawer;

          _txtdocumentRef.text = _withdrawHead[0].f_withReferance == null
              ? ''
              : _withdrawHead[0].f_withReferance;

          _txtdocumentRefDate.text = _withdrawHead[0].f_withReferanceDate != ''
              ? DateFormat('dd-MM-yyyy HH:mm:ss')
                  .format(DateTime.parse(_withdrawHead[0].f_withReferanceDate))
              : '';

          _txtRemark.text = _withdrawHead[0].f_withRemark == null
              ? ''
              : _withdrawHead[0].f_withRemark;

          _dropdownMenuItemsHistory = buildDropDownMenuItemsHistory(temp);
          _selectedItemHistory =
              _dropdownMenuItemsHistory[0].value as WithDrawHead;
        } else {
          showMessageAlert();
        }
      },
    );

    getWithdrawDetail(id);
  }

  _showStatusMobile(String _text) {
    String _content;
    if (_text == "1") {
      _content = "Checked";
    } else {
      _content = "Waitcheck";
    }

    return Container(
      width: 50,
      height: 30,
      decoration: BoxDecoration(
        color: _text == '1' ? Colors.green[600] : Colors.orange,
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

  _showStatusTablet(String _text) {
    String _content;
    if (_text == "1") {
      _content = "Checked";
    } else {
      _content = "Waitcheck";
    }

    return Container(
      width: 100,
      height: 30,
      decoration: BoxDecoration(
        color: _text == '1' ? Colors.green[600] : Colors.orange,
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

  Future<void> showAlertgetWithdrawHistoryMobile() async {
    //  _txtSearchDocument.text = "";
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
                              radius: 20,
                              backgroundImage: AssetImage('images/POS.jpg'),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                ' Sending ( ส่งของ )',
                                style: TextStyle(
                                  color: Colors.cyan[600],
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            _Triangle(
                              color: Color.fromRGBO(0, 175, 196, 1),
                            )
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width - 60,
                      //color: Colors.red,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 30,
                                width: 60,
                                color: Colors.cyan[600],
                                margin: EdgeInsets.only(bottom: 5),
                                child: Center(
                                  child: Text(
                                    'เลขที่ใบเบิก',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
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
                                  width: 60,
                                  height: 30,
                                  color: Colors.white,
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor: Colors.white,
                                      fontSize: 9,
                                    ),
                                    controller: _txtSearchDocument,
                                    decoration: InputDecoration(
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
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 30,
                                margin: EdgeInsets.only(bottom: 5),
                                color: Colors.white,
                                child: TextFormField(
                                  //  enabled: _checkSearch,
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
                                    fontSize: 9,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    labelStyle: TextStyle(fontSize: mediumText),
                                    labelText: 'วันที่เริ่มต้น',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(0, 175, 196, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(0, 175, 196, 1),
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
                                width: 80,
                                height: 30,
                                margin: EdgeInsets.only(bottom: 5),
                                color: Colors.white,
                                child: TextFormField(
                                  // enabled: _checkSearch,
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
                                  style: TextStyle(
                                    fontSize: 9,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    labelStyle: TextStyle(fontSize: mediumText),
                                    labelText: 'วันที่สุดท้าย',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(0, 175, 196, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(0, 175, 196, 1),
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
                                width: 80,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromRGBO(0, 175, 196, 1),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.only(left: 10),
                                margin: EdgeInsets.only(bottom: 5),
                                child: new DropdownButton<StatusCheck>(
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.black,
                                  ),
                                  underline: SizedBox.shrink(),
                                  isExpanded: true,
                                  value: _selectedHistory,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedHistory = newValue;
                                      //print(_selected!.id);
                                    });
                                  },
                                  items: statuscheckHistory.map(
                                    (StatusCheck _check) {
                                      return new DropdownMenuItem<StatusCheck>(
                                        value: _check,
                                        child: new Text(_check.name),
                                      );
                                    },
                                  ).toList(),
                                ),
                              )
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
                                'f_withID':
                                    _txtSearchDocument.text.toString() != ''
                                        ? _txtSearchDocument.text.toString()
                                        : '',
                                'f_dateStart': _dateStart,
                                'f_dateEnd': _dateEnd,
                                'f_shippingCheck': '1'
                              };

                              // print(data);

                              if (data.length > 0) {
                                getWithDrawHistoryByIDAppbar(data);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan[600],
                              ),
                              width: MediaQuery.of(context).size.width - 60,
                              height: 30,
                              child: Center(
                                child: Text(
                                  'Load Data',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
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
                          itemCount: _withdrawHead.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 6,
                              margin: EdgeInsets.all(5),
                              child: ListTile(
                                onTap: () {
                                  getWithdrawID(_withdrawHead[index].f_withID);
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
                                                'เลขที่เอกสารใบเบิก : ${_withdrawHead[index].f_withID}',
                                                style: TextStyle(fontSize: 9),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'วันที่เบิกออก : ${_withdrawHead[index].f_withDate == '' ? '' : DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(_withdrawHead[index].f_withDate))}',
                                                style: TextStyle(fontSize: 9),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'ผู้เบิกออกสินค้า : ${_withdrawHead[index].f_withWithdrawer}',
                                                style: TextStyle(fontSize: 9),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Responsive.isMobile(context)
                                          ? _showStatusMobile(
                                              _withdrawHead[index]
                                                  .f_shippingCheck)
                                          : _showStatusTablet(
                                              _withdrawHead[index]
                                                  .f_shippingCheck),
                                    ],
                                  ),
                                ),
                                // leading: Icon(
                                //   Icons.analytics_outlined,
                                //   size: 60,
                                //   color: Colors.cyan[600],
                                // ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 60,
                          height: 10,
                          child: Text(
                            '${_withdrawHead.length} Records.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                            ),
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

  Future<void> _updateFinishShipping() async {
    String url = server + "/api/withdraw/updateFinishShipping";
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {'f_withID': _txtdocumentID.text, 'f_finishShipping': 1},
      ),
    );
  }

  // ประวัติจาก Appbar
  Future<void> showAlertgetWithdrawHistoryTablet() async {
    //  _txtSearchDocument.text = "";
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
                            Expanded(
                              flex: 4,
                              child: Text(
                                ' Sending ( ส่งของ )',
                                style: TextStyle(
                                  color: Colors.cyan[600],
                                ),
                              ),
                            ),
                            _Triangle(
                              color: Color.fromRGBO(0, 175, 196, 1),
                            )
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
                                color: Colors.cyan[600],
                                margin: EdgeInsets.only(bottom: 5),
                                child: Center(
                                  child: Text(
                                    'เลขที่ใบเบิก',
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
                                    style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor: Colors.white,
                                    ),
                                    controller: _txtSearchDocument,
                                    decoration: InputDecoration(
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
                              SizedBox(
                                width: 20,
                              ),
                              Container(
                                width: 110,
                                height: 40,
                                margin: EdgeInsets.only(bottom: 5),
                                color: Colors.white,
                                child: TextFormField(
                                  //  enabled: _checkSearch,
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
                                        color: Color.fromRGBO(0, 175, 196, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(0, 175, 196, 1),
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
                                  // enabled: _checkSearch,
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
                                        color: Color.fromRGBO(0, 175, 196, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(0, 175, 196, 1),
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
                              // Container(
                              //   width: 110,
                              //   height: 40,
                              //   decoration: BoxDecoration(
                              //     border: Border.all(
                              //       color: Color.fromRGBO(0, 175, 196, 1),
                              //       width: 2,
                              //     ),
                              //     borderRadius: BorderRadius.circular(5),
                              //   ),
                              //   padding: EdgeInsets.only(left: 10),
                              //   margin: EdgeInsets.only(bottom: 5),
                              //   child: new DropdownButton<StatusCheck>(
                              //     underline: SizedBox.shrink(),
                              //     isExpanded: true,
                              //     value: _selectedHistory,
                              //     onChanged: (newValue) {
                              //       setState(() {
                              //         _selectedHistory = newValue;
                              //         //print(_selected!.id);
                              //       });
                              //     },
                              //     items: statuscheckHistory.map(
                              //       (StatusCheck _check) {
                              //         return new DropdownMenuItem<StatusCheck>(
                              //           value: _check,
                              //           child: new Text(_check.name),
                              //         );
                              //       },
                              //     ).toList(),
                              //   ),
                              // )
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
                                'f_withID':
                                    _txtSearchDocument.text.toString() != ''
                                        ? _txtSearchDocument.text.toString()
                                        : '',
                                'f_dateStart': _dateStart,
                                'f_dateEnd': _dateEnd,
                                'f_shippingCheck': '1'
                              };

                              // print(data);

                              if (data.length > 0) {
                                getWithDrawHistoryByIDAppbar(data);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan[600],
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
                          itemCount: _withdrawHead.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 6,
                              margin: EdgeInsets.all(10),
                              child: ListTile(
                                onTap: () {
                                  getWithdrawID(_withdrawHead[index].f_withID);
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
                                                'เลขที่เอกสารใบเบิก : ${_withdrawHead[index].f_withID}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'วันที่เบิกออก : ${_withdrawHead[index].f_withDate == '' ? '' : DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(_withdrawHead[index].f_withDate))}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'ผู้เบิกออกสินค้า : ${_withdrawHead[index].f_withWithdrawer}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      _showStatusTablet(
                                          _withdrawHead[index].f_shippingCheck),
                                    ],
                                  ),
                                ),
                                leading: Icon(
                                  Icons.analytics_outlined,
                                  size: 60,
                                  color: Colors.cyan[600],
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
                            '${_withdrawHead.length} Records.',
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

  // ค้นหาจากแว่นขยาย
  Future<void> showAlertgetWithdrawTablet() async {
    //  _txtSearchDocument.text = "";
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
                            Expanded(
                              flex: 4,
                              child: Text(
                                ' Withdraw ( ใบเบิกสินค้า )',
                                style: TextStyle(
                                  color: Color.fromRGBO(187, 56, 27, 1),
                                ),
                              ),
                            ),
                            _Triangle(
                              color: Color.fromRGBO(187, 56, 27, 1),
                            )
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
                                color: Color.fromRGBO(187, 56, 27, 1),
                                margin: EdgeInsets.only(bottom: 5),
                                child: Center(
                                  child: Text(
                                    'เลขที่ใบเบิก',
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
                                    style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor: Colors.white,
                                    ),
                                    controller: _txtSearchDocument,
                                    decoration: InputDecoration(
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
                              SizedBox(
                                width: 20,
                              ),
                              Container(
                                width: 110,
                                height: 40,
                                margin: EdgeInsets.only(bottom: 5),
                                color: Colors.white,
                                child: TextFormField(
                                  //  enabled: _checkSearch,
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
                                        color: Color.fromRGBO(187, 56, 27, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(187, 56, 27, 1),
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
                                  // enabled: _checkSearch,
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
                                        color: Color.fromRGBO(187, 56, 27, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(187, 56, 27, 1),
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
                                    color: Color.fromRGBO(187, 56, 27, 1),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.only(left: 10),
                                margin: EdgeInsets.only(bottom: 5),
                                child: new DropdownButton<StatusCheck>(
                                  underline: SizedBox.shrink(),
                                  isExpanded: true,
                                  value: _selected,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selected = newValue;
                                      // print(_selected!.id);
                                    });
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
                              )
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
                                'f_withID':
                                    _txtSearchDocument.text.toString() != ''
                                        ? _txtSearchDocument.text.toString()
                                        : '',
                                'f_dateStart': _dateStart,
                                'f_dateEnd': _dateEnd,
                                'f_shippingCheck': _selected!.id
                              };

                              print(data);
                              // ค้นหาจากแว่นขยาย
                              if (data.length > 0) {
                                getWithDrawHistoryByID(data);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(187, 56, 27, 1),
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
                          itemCount: _withdrawHead.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 6,
                              margin: EdgeInsets.all(10),
                              child: ListTile(
                                onTap: () {
                                  getWithdrawID(_withdrawHead[index].f_withID);
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
                                                'เลขที่เอกสารใบเบิก : ${_withdrawHead[index].f_withID}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'วันที่เบิกออก : ${_withdrawHead[index].f_withDate == '' ? '' : DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(_withdrawHead[index].f_withDate))}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'ผู้เบิกออกสินค้า : ${_withdrawHead[index].f_withWithdrawer}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      _showStatusTablet(
                                          _withdrawHead[index].f_shippingCheck),
                                    ],
                                  ),
                                ),
                                leading: Icon(
                                  Icons.analytics_outlined,
                                  size: 60,
                                  color: Color.fromRGBO(187, 56, 27, 1),
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
                            '${_withdrawHead.length} Records.',
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

  Future<void> showAlertgetWithdrawMobile() async {
    //  _txtSearchDocument.text = "";
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
                              radius: 20,
                              backgroundImage: AssetImage('images/POS.jpg'),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                ' Withdraw ( ใบเบิกสินค้า )',
                                style: TextStyle(
                                  color: Colors.amber[900],
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            _Triangle(
                              color: Color.fromRGBO(187, 56, 27, 1),
                            )
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width - 60,
                      //color: Colors.red,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 30,
                                width: 60,
                                color: Colors.amber[900],
                                margin: EdgeInsets.only(bottom: 5),
                                child: Center(
                                  child: Text(
                                    'เลขที่ใบเบิก',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
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
                                  width: 60,
                                  height: 30,
                                  color: Colors.white,
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    style: TextStyle(
                                      color: Colors.black,
                                      backgroundColor: Colors.white,
                                      fontSize: 9,
                                    ),
                                    controller: _txtSearchDocument,
                                    decoration: InputDecoration(
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
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 30,
                                margin: EdgeInsets.only(bottom: 5),
                                color: Colors.white,
                                child: TextFormField(
                                  //  enabled: _checkSearch,
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
                                    fontSize: 9,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    labelStyle: TextStyle(fontSize: mediumText),
                                    labelText: 'วันที่เริ่มต้น',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(187, 56, 27, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(187, 56, 27, 1),
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
                                width: 80,
                                height: 30,
                                margin: EdgeInsets.only(bottom: 5),
                                color: Colors.white,
                                child: TextFormField(
                                  // enabled: _checkSearch,
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
                                  style: TextStyle(
                                    fontSize: 9,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    labelStyle: TextStyle(fontSize: mediumText),
                                    labelText: 'วันที่สุดท้าย',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(187, 56, 27, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(187, 56, 27, 1),
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
                                width: 80,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromRGBO(187, 56, 27, 1),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.only(left: 10),
                                margin: EdgeInsets.only(bottom: 5),
                                child: new DropdownButton<StatusCheck>(
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.black,
                                  ),
                                  underline: SizedBox.shrink(),
                                  isExpanded: true,
                                  value: _selected,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selected = newValue;
                                      // print(_selected!.id);
                                    });
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
                              )
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
                                'f_withID':
                                    _txtSearchDocument.text.toString() != ''
                                        ? _txtSearchDocument.text.toString()
                                        : '',
                                'f_dateStart': _dateStart,
                                'f_dateEnd': _dateEnd,
                                'f_shippingCheck': _selected!.id
                              };

                              print(data);
                              // ค้นหาจากแว่นขยาย
                              if (data.length > 0) {
                                getWithDrawHistoryByID(data);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(187, 56, 27, 1),
                              ),
                              width: MediaQuery.of(context).size.width - 60,
                              height: 30,
                              child: Center(
                                child: Text(
                                  'Load Data',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
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
                          itemCount: _withdrawHead.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 6,
                              margin: EdgeInsets.all(5),
                              child: ListTile(
                                onTap: () {
                                  getWithdrawID(_withdrawHead[index].f_withID);
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
                                                'เลขที่เอกสารใบเบิก : ${_withdrawHead[index].f_withID}',
                                                style: TextStyle(fontSize: 9),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'วันที่เบิกออก : ${_withdrawHead[index].f_withDate == '' ? '' : DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(_withdrawHead[index].f_withDate))}',
                                                style: TextStyle(fontSize: 9),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'ผู้เบิกออกสินค้า : ${_withdrawHead[index].f_withWithdrawer}',
                                                style: TextStyle(fontSize: 9),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Responsive.isMobile(context)
                                          ? _showStatusMobile(
                                              _withdrawHead[index]
                                                  .f_shippingCheck)
                                          : _showStatusTablet(
                                              _withdrawHead[index]
                                                  .f_shippingCheck),
                                    ],
                                  ),
                                ),
                                // leading: Icon(
                                //   Icons.analytics_outlined,
                                //   size: 60,
                                //   color: Colors.amber[900],
                                // ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 60,
                          height: 10,
                          child: Text(
                            '${_withdrawHead.length} Records.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                            ),
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

  Future<void> showMessageAlert() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Alert!!"),
          content: new Text("NOT FOUND THIS ID"),
          actions: <Widget>[
            new TextButton(
              child: new Text("NOT FOUND"),
              onPressed: () {
                setState(() {
                  _txtdocumentID.clear();
                  _txtdocumentDate.clear();
                  _txtdocumentRef.clear();
                  _txtdocumentRefDate.clear();
                  _txtuserWithdraw.clear();
                  _txtRemark.clear();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getWithdrawDetail(String id) async {
    String url = server + "/api/withdrawdetail/'${id}'";
    final response = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(response.body);
    // print(jsonResponce['data']);

    List<WithDrawDetail> temp = (jsonResponce['data'] as List)
        .map((itemWord) => WithDrawDetail.fromJson(itemWord))
        .toList();

    setState(() {
      int Count = 0;
      for (int i = 0; i < temp.length; i++) {
        // print(' i = ${temp[i].f_Confirm.toString()} ');
        if (temp[i].f_Confirm == Null) {
          temp[i].checked = false;
        } else if (temp[i].f_Confirm == 1) {
          temp[i].checked = true;
          Count++;
        }
      }
      if (Count == temp.length) {
        checkSuccess = false;
      } else {
        checkSuccess = true;
      }

      _withdrawDetail.addAll(temp);
      sumValue();

      if (_withdrawDetail.length > 0) {
        productCount = _withdrawDetail.length;
      }
    });
  }

  Future<void> getProduct(String id) async {
    String encodedId = Uri.encodeComponent(id.replaceAll("'", ""));
    String url = server + "/api/product/'$encodedId'";
    final response = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(response.body);
    // print(jsonResponce['data']);

    List<Product> temp = (jsonResponce['data'] as List)
        .map((itemWord) => Product.fromJson(itemWord))
        .toList();

    setState(() {
      _productlist.addAll(temp);
      _txtBarcode.clear();
    });
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
      width: Responsive.isMobile(context)
          ? 125
          : MediaQuery.of(context).size.width * 0.28,
      height: Responsive.isMobile(context) ? 30 : 40,
      margin: EdgeInsets.only(bottom: 5),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Inventory>(
          style: TextStyle(
            fontSize: Responsive.isMobile(context) ? 9 : 16,
            fontFamily: 'Sarabun',
            color: Colors.black,
          ),
          isExpanded: true,
          value: _selectedItem,
          items: _dropdownMenuItems,
          onChanged: (value) {
            setState(() {
              _showButton ? _selectedItem = value : '';
            });
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
      width: Responsive.isMobile(context)
          ? 125
          : MediaQuery.of(context).size.width * 0.28,
      height: Responsive.isMobile(context) ? 30 : 40,
      margin: EdgeInsets.only(bottom: 5),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<WithDrawHead>(
          style: TextStyle(
            fontSize: Responsive.isMobile(context) ? 9 : 16,
            fontFamily: 'Sarabun',
            color: Colors.black,
          ),
          isExpanded: true,
          value: _selectedItemHistory,
          items: _dropdownMenuItemsHistory,
          onChanged: (value) {
            setState(() {
              _showButton ? _selectedItemHistory = value : '';
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FocusNode myFocusNode = new FocusNode();
    int count = 0;
    String dropdownValue = 'One';

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        drawer: new Drawer(
          child: MenuDrawer(),
        ),
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: Colors.cyan[600],
              size: Responsive.isMobile(context) ? 20 : 24),
          title: Text(
            'Delivery Check ( เช็คของขึ้นรถ )',
            style: TextStyle(
              color: Colors.cyan[600],
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
                    builder: (BuildContext context) => ConfirmWithdrawPage(),
                  ),
                );
              },
              icon: Icon(
                Icons.addchart,
                color: Colors.cyan[600],
                size: Responsive.isMobile(context) ? 20 : 24,
              ),
            ),
            SizedBox(
              width: Responsive.isMobile(context) ? 1 : 10,
            ),
            IconButton(
              onPressed: () {
                _txtSearchDocument.text = '';
                // getWithdrawAll(1);
                getWithDrawHByShipSuccess();
              },
              icon: Icon(
                Icons.directions_bus_filled_sharp,
                size: Responsive.isMobile(context) ? 20 : 24,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        body: Responsive.isMobile(context)
            ? _buildMobile(context)
            : _buildTablet(context),
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          height: checkSuccess
              ? MediaQuery.of(context).size.height * 0.15
              : MediaQuery.of(context).size.height * 0.1,
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20, top: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: Responsive.isMobile(context) ? 3 : 6,
                      child: Text(
                        'Total ${productCount != 0 ? productCount : 0} list.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Total ${SumValue != 0 ? SumValue : 0} pcs.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
              checkSuccess ? _buildButtonSave() : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 5, left: 10, right: 5, bottom: 5),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.22,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        width: 60,
                        color: Colors.cyan[600],
                        child: Center(
                          child: Align(
                            child: Text(
                              'เลขที่เอกสารใบเบิก',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: 100,
                        height: 30,
                        color: Colors.black,
                        margin: EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          readOnly: true,
                          style: TextStyle(
                            color: Colors.cyan[600],
                            backgroundColor: Colors.black,
                            fontSize: 9,
                          ),
                          controller: _txtdocumentID,
                          decoration: InputDecoration(
                            hintText: 'เลขที่เอกสารใบเบิก',
                            labelStyle: TextStyle(fontSize: mediumText),
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
                      Container(
                        width: 25,
                        height: 30,
                        decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(10),
                            color: Colors.cyan[600]),
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              //todo
                              //getWithdrawAll(0);
                              getWithDrawHByShip();
                            },
                            icon: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        height: 30,
                        width: 60,
                        color: Colors.cyan[600],
                        child: Center(
                          child: Text(
                            'วันที่บันทึก',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: 110,
                        height: 30,
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          style: TextStyle(fontSize: 9),
                          readOnly: true,
                          onTap: () {},
                          controller: _txtdocumentDate,
                          decoration: InputDecoration(
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
                        height: 30,
                        width: 60,
                        color: Colors.cyan[600],
                        child: Center(
                          child: Text(
                            'เอกสารอ้างอิง',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: 125,
                        height: 30,
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 9,
                          ),
                          readOnly: true,
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
                        width: 5,
                      ),
                      Container(
                        height: 30,
                        width: 60,
                        color: Colors.cyan[600],
                        child: Center(
                          child: Align(
                            child: Text(
                              'วันที่เอกสารอ้างอิง',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 9),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: 110,
                        height: 30,
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 9,
                          ),
                          readOnly: true,
                          onTap: () {},
                          controller: _txtdocumentRefDate,
                          decoration: InputDecoration(
                            // labelText: 'วันที่เอกสารอ้างอิง',
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
                        height: 30,
                        width: 60,
                        color: Colors.cyan[600],
                        child: Center(
                          child: Text(
                            'คลังสินค้า',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
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
                        width: 5,
                      ),
                      Container(
                        height: 30,
                        width: 60,
                        color: Colors.cyan[600],
                        child: Center(
                          child: Text(
                            'ผู้เบิกสินค้า',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: 110,
                        height: 30,
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 9,
                          ),
                          readOnly: true,
                          controller: _txtuserWithdraw,
                          decoration: InputDecoration(
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
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        width: 60,
                        color: Colors.cyan[600],
                        child: Center(
                          child: Text(
                            'หมายเหตุ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: 30,
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 9,
                          ),
                          readOnly: true,
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
                      SizedBox(
                        width: 10,
                      ),
                      checkCloseJob
                          ? Container(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  _updateFinishShipping();
                                  _onAlertButtonPressed(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: Text('Close Job'),
                              ),
                            )
                          : SizedBox.shrink(),
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
          color: Colors.cyan[600],
        ),
        Expanded(
          child: Container(
            child: ListView.builder(
              itemCount: getCountProduct(),
              itemBuilder: (BuildContext context, int vindex) {
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
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'รหัสสินค้า : ${_withdrawDetail[vindex].f_prodID}',
                                style: TextStyle(
                                  color: Colors.amber[900],
                                  fontSize:
                                      Responsive.isMobile(context) ? 9 : 12,
                                ),
                              ),
                              ToggleSwitch(
                                minWidth:
                                    Responsive.isMobile(context) ? 40.0 : 50.0,
                                minHeight:
                                    Responsive.isMobile(context) ? 30.0 : 50.0,
                                cornerRadius: 10.0,
                                activeBgColors: [
                                  [Colors.green],
                                  [Colors.redAccent]
                                ],
                                activeFgColor: Colors.white,
                                inactiveBgColor: Colors.grey,
                                inactiveFgColor: Colors.white,
                                totalSwitches: 2,
                                // toggle
                                labels: [
                                  '${_withdrawDetail[vindex].f_withQty}',
                                  'NO'
                                ],
                                initialLabelIndex:
                                    _withdrawDetail[vindex].checked == true
                                        ? 0
                                        : 1,
                                icons: [null, null],
                                onToggle: (index) {
                                  index == 0
                                      ? _withdrawDetail[vindex].checked = true
                                      : _withdrawDetail[vindex].checked = false;

                                  // print(_withdrawDetail[vindex].checked);
                                },
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ชื่อสินค้า : ${_withdrawDetail[vindex].f_prodName}',
                                style: TextStyle(
                                  fontSize:
                                      Responsive.isMobile(context) ? 9 : 10,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    leading: Container(
                      // padding: EdgeInsets.only(top: 20),
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
        ),
      ],
    );
  }

  Widget _buildTablet(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.18,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Colors.cyan[600],
                        child: Center(
                          child: Text(
                            'เลขที่เอกสารใบเบิก',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.21,
                        height: 40,
                        color: Colors.black,
                        margin: EdgeInsets.only(bottom: 5),
                        child: Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: TextFormField(
                            readOnly: true,
                            style: TextStyle(
                              color: Colors.cyan[600],
                              backgroundColor: Colors.black,
                            ),
                            controller: _txtdocumentID,
                            decoration: InputDecoration(
                              hintText: 'เลขที่เอกสารใบเบิก',
                              labelStyle: TextStyle(fontSize: mediumText),
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
                      Container(
                        width: 50,
                        height: 40,
                        decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(10),
                            color: Colors.cyan[600]),
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              //todo
                              //getWithdrawAll(0);
                              getWithDrawHByShip();
                            },
                            icon: Icon(
                              Icons.search,
                              color: Colors.white,
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
                        color: Colors.cyan[600],
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
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          readOnly: true,
                          onTap: () {},
                          controller: _txtdocumentDate,
                          decoration: InputDecoration(
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
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Colors.cyan[600],
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
                          readOnly: true,
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
                        color: Colors.cyan[600],
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
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          readOnly: true,
                          onTap: () {},
                          controller: _txtdocumentRefDate,
                          decoration: InputDecoration(
                            // labelText: 'วันที่เอกสารอ้างอิง',
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
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Colors.cyan[600],
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
                        color: Colors.cyan[600],
                        child: Center(
                          child: Text(
                            'ผู้เบิกสินค้า',
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
                          readOnly: true,
                          controller: _txtuserWithdraw,
                          decoration: InputDecoration(
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
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: Colors.cyan[600],
                        child: Center(
                          child: Text(
                            'หมายเหตุ',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: 40,
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          readOnly: true,
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
                      SizedBox(
                        width: 10,
                      ),
                      checkCloseJob
                          ? Container(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  _updateFinishShipping();
                                  _onAlertButtonPressed(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: Text('Close Job'),
                              ),
                            )
                          : SizedBox.shrink(),
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
          color: Colors.cyan[600],
        ),
        SizedBox(
          height: 15,
        ),
        Expanded(
          child: Container(
            child: ListView.builder(
              itemCount: getCountProduct(),
              itemBuilder: (BuildContext context, int vindex) {
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
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'รหัสสินค้า : ${_withdrawDetail[vindex].f_prodID}',
                                style: TextStyle(
                                    color: Colors.amber[900], fontSize: 12),
                              ),
                              ToggleSwitch(
                                minWidth: 50.0,
                                cornerRadius: 10.0,
                                activeBgColors: [
                                  [Colors.green],
                                  [Colors.redAccent]
                                ],
                                activeFgColor: Colors.white,
                                inactiveBgColor: Colors.grey,
                                inactiveFgColor: Colors.white,
                                totalSwitches: 2,
                                // toggle
                                labels: [
                                  '${_withdrawDetail[vindex].f_withQty}',
                                  'NO'
                                ],
                                initialLabelIndex:
                                    _withdrawDetail[vindex].checked == true
                                        ? 0
                                        : 1,
                                icons: [null, null],
                                onToggle: (index) {
                                  index == 0
                                      ? _withdrawDetail[vindex].checked = true
                                      : _withdrawDetail[vindex].checked = false;

                                  // print(_withdrawDetail[vindex].checked);
                                },
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ชื่อสินค้า : ${_withdrawDetail[vindex].f_prodName}',
                                style: TextStyle(fontSize: 10),
                              ),
                              SizedBox(
                                height: 10,
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
                      // padding: EdgeInsets.only(top: 20),
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
        ),
      ],
    );
  }

  // update Check
  Row _buildButtonSave() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: () {
                int count = 0;
                var data = {};
                data.clear();
                // print(_withdrawDetail.length);
                for (int i = 0; i < _withdrawDetail.length; i++) {
                  //  print(_withdrawDetail[i].checked);
                  data = {
                    'f_withID': _txtdocumentID.text.toString(),
                    'f_prodID': _withdrawDetail[i].f_prodID.toString(),
                    'f_Confirm': _withdrawDetail[i].checked == true ? '1' : '0'
                  };
                  _confirmWithDraw(data);

                  if (_withdrawDetail[i].checked == true) {
                    count++;
                  }
                } // end for

                if (count == _withdrawDetail.length) {
                  var dataUpdateShip = {};
                  dataUpdateShip.clear();

                  dataUpdateShip = {
                    'f_withID': _txtdocumentID.text.toString(),
                    'f_shippingCheck': "1"
                  };

                  _updateShipSuccess(dataUpdateShip);
                  // _showDialog();

                  _onAlertButtonPressed(context);
                } else {
                  // _showDialog();

                  _onAlertButtonPressed(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan[600],
              ),
              child: Text('Confirm'),
            ),
          ),
        ),
      ],
    );
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
          onPressed: () {
            Navigator.pop(context);

            setState(() {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ConfirmWithdrawPage(),
                ),
              );
            });
          },
          width: 120,
        )
      ],
    ).show();
  }

  Future<void> _updateShipSuccess(Map<dynamic, dynamic> values) async {
    String url = server + "/api/withdraw/updateShippingCheck";
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {
          'f_withID': values['f_withID'],
          'f_shippingCheck': values['f_shippingCheck']
        },
      ),
    );
  }

  Future<void> _confirmWithDraw(Map<dynamic, dynamic> values) async {
    String url = server + "/api/withdrawdetail";
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {
          'f_withID': values['f_withID'],
          'f_prodID': values['f_prodID'],
          'f_Confirm': values['f_Confirm']
        },
      ),
    );
  }

  int getCountProduct() {
    int amount = 0;
    this._withdrawDetail.forEach((_product) {
      amount++;
    });

    return amount;
  }

  Future<void> sumValue() async {
    SumValue = 0;
    for (int i = 0; i < _withdrawDetail.length; i++) {
      SumValue = SumValue + _withdrawDetail[i].f_withQty;
    }
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
