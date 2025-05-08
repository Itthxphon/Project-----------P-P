import 'dart:convert';
import 'dart:io';
import 'package:Nippostock/config/constant.dart';
import 'package:Nippostock/models/customer.dart';
import 'package:Nippostock/models/inventory.dart';
import 'package:Nippostock/models/statusCheck.dart';
import 'package:Nippostock/models/withdrawDetail.dart';
import 'package:Nippostock/models/withdrawHead.dart';
import 'package:Nippostock/models/withdrawReq.dart';
import 'package:Nippostock/models/withdrawReqDetail.dart';
import 'package:Nippostock/widgets/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:Nippostock/models/product.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'dart:math' as math;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'menu_drawer.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({Key? key}) : super(key: key);

  @override
  _ReceivePageState createState() => _ReceivePageState();
}

class _ReceivePageState extends State<WithdrawPage> {
  late bool visible;
  String? _name = "";
  String? _fullname = "";
  String? _userId = "";
  String? _setting = "";
  String? _setting_nd = "";

  bool _showButton = true;
  String withReq = "";
  String _wareID = "";
  bool _NewDoc = true;
  bool _showButtonSave = true;

  final _txtSearchDateStart = TextEditingController();
  final _txtSearchDateEnd = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCustomer();
    getInventory();
    getWithdrawID();
    getDataPref();
    // _selected = statuscheck[0];
  }

  getDataPref() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? id = prefs.getString("userID");
    String? name = prefs.getString("userName");
    String? fullname = prefs.getString("fullName");
    String? setting = prefs.getString("f_wbrUse");
    String? setting_nd = prefs.getString("f_negativeDrawdown");
    if (mounted) {
      setState(() {
        _setting = setting;
        _name = name;
        _fullname = fullname;
        _userId = id;
        _txtuserWithdraw.text = fullname.toString();
        _setting_nd = setting_nd;

        _setting == "1" ? _showButton = false : _showButton = true;
      });
    }
  }

  final String _scanBarcode = 'Unknown';
  final _txtBarcode = TextEditingController();
  int Count = 0;
  int SumValue = 0;
  int SumCountValue = 0;
  final List<Product> _productlist = [];
  final List<dynamic> _inventory = [];
  final List<WithdrawReqHead> _withdrawReqHead = [];
  final List<WithdrawReqDetail> _withdrawReqDetail = [];

  final List<WithDrawHead> _withdrawHeadHistory = [];
  final List<WithDrawDetail> _withdrawDetailHistory = [];

  int productCount = 0;
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _documentID = "";

  List<DropdownMenuItem<Inventory>> _dropdownMenuItems = [];
  Inventory? _selectedItem;

  final List<DropdownMenuItem<WithdrawReqHead>> _dropdownMenuItemsHistory = [];
  WithdrawReqHead? _selectedItemHistory;

  final List<DropdownMenuItem<WithDrawHead>> _dropdownMenuItemsHistory1 = [];
  WithDrawHead? _ItemHistory;

  List<DropdownMenuItem<Customer>> _dropdownMenuItemsCustomer = [];
  Customer? _selectedItemCustomer;

  final List<DropdownMenuItem<WithdrawReqHead>>
      _dropdownMenuItemCustomerHistory = [];
  WithdrawReqHead? _selectCustomerHistory;

  StatusCheck? _selected;
  StatusCheck? _selectedHistory;

  bool isLoading = true;

  List<StatusCheck> statuscheck = <StatusCheck>[
    const StatusCheck(1, 'Waiting'),
    const StatusCheck(2, 'Success'),
    const StatusCheck(0, 'Cancle')
  ];

  List<StatusCheck> statuscheckWithdraw = <StatusCheck>[
    const StatusCheck(1, 'Normal'),
    const StatusCheck(0, 'Cancle')
  ];

  final _txtdocumentID = TextEditingController();
  final _txtdocumentDate = TextEditingController();
  final _txtuserWithdraw = TextEditingController();
  final _txtdocumentRef = TextEditingController();
  final _txtdocumentRefDate = TextEditingController();
  final _txtRemark = TextEditingController();
  final _txtSearchDocument = TextEditingController();
  final _txtSearchDocument_history = TextEditingController();
  final _txtCount = TextEditingController();
  final _txtwareName = TextEditingController();
  final _txtcustomerName = TextEditingController();

  // ค้นหาประวัติใบเบิกทั้งหมด
  Future<void> getWithdrawAll() async {
    String url = "$server/api/withdraw/historyAll/";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    final jsonResponce = json.decode(responce.body);
    List<WithDrawHead> temp = (jsonResponce['data'] as List)
        .map((item) => WithDrawHead.fromJson(item))
        .toList();

    if (mounted) {
      setState(() {
        _selectedHistory = statuscheckWithdraw[0];
        _txtSearchDateStart.clear();
        _txtSearchDateEnd.clear();

        DateTime _dateStart;
        DateTime _dateEnd;
        _dateStart = DateTime.now().subtract(const Duration(days: 45));
        _dateEnd = DateTime.now();

        _txtSearchDateStart.text = DateFormat('dd-MM-yyyy').format(_dateStart);
        _txtSearchDateEnd.text = DateFormat('dd-MM-yyyy').format(_dateEnd);

        _withdrawHeadHistory.clear();
        _withdrawHeadHistory.addAll(temp);

        _wareID = "";

        showAlertgetWithdrawMobile();
        // Responsive.isMobile(context)
        //     ? showAlertgetWithdrawMobile()
        //     : showAlertgetWithdrawTablet();
      });
    }
  }

  List<DropdownMenuItem<Customer>> buildDropDownMenuItemsCustomer(
      List listItems) {
    List<DropdownMenuItem<Customer>> items = [];
    for (int i = 0; i <= listItems.length - 1; i++) {
      Customer listItem = listItems[i];
      items.add(
        DropdownMenuItem(
          value: listItem,
          child: Text(listItem.f_cusName),
        ),
      );
    }
    return items;
  }

  Future<void> showAlertgetWithdrawTablet() async {
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
                                'Withdraw History ( ประวัติเบิกออกสินค้า )',
                                style: TextStyle(
                                  color: Color.fromRGBO(187, 56, 27, 1),
                                ),
                              ),
                            ),
                            _Triangle(color: Color.fromRGBO(187, 56, 27, 1))
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
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
                                color: const Color.fromRGBO(187, 56, 27, 1),
                                margin: const EdgeInsets.only(bottom: 5),
                                child: const Center(
                                  child: Text(
                                    'เลขที่ใบเบิก',
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
                                  width: 160,
                                  height: 40,
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    style: const TextStyle(
                                      color: Colors.black,
                                      backgroundColor: Colors.white,
                                    ),
                                    controller: _txtSearchDocument,
                                    decoration: const InputDecoration(
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
                                // color: Colors.red,
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
                                              DateFormat('dd-MM-yyyy')
                                                  .format(selectedDate);
                                        }
                                      },
                                    );
                                  },
                                  controller: _txtSearchDateStart,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.only(left: 10),
                                    labelStyle:
                                        const TextStyle(fontSize: mediumText),
                                    labelText: 'วันที่เริ่มต้น',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(187, 56, 27, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(187, 56, 27, 1),
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
                                              DateFormat('dd-MM-yyyy')
                                                  .format(selectedDate);
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
                                        color: Color.fromRGBO(187, 56, 27, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(187, 56, 27, 1),
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
                                  border: Border.all(
                                      color:
                                          const Color.fromRGBO(187, 56, 27, 1),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.only(left: 10),
                                margin: const EdgeInsets.only(bottom: 5),
                                child: DropdownButton<StatusCheck>(
                                  underline: const SizedBox.shrink(),
                                  isExpanded: true,
                                  value: _selectedHistory,
                                  onChanged: (newValue) {
                                    if (mounted) {
                                      setState(() {
                                        _selectedHistory = newValue;
                                        //print(_selected!.id);
                                      });
                                    }
                                  },

                                  //todo change dropdown
                                  items: statuscheckWithdraw.map(
                                    (StatusCheck _check) {
                                      return DropdownMenuItem<StatusCheck>(
                                        value: _check,
                                        child: Text(_check.name),
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
                                'f_withID':
                                    _txtSearchDocument.text.toString() != ''
                                        ? _txtSearchDocument.text.toString()
                                        : '',
                                'f_dateStart': _dateStart,
                                'f_dateEnd': _dateEnd,
                                'f_withStatus': _selectedHistory!.id
                              };

                              if (data.isNotEmpty) {
                                // print(data);
                                getWithDrawHistoryByID(data);
                              }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(187, 56, 27, 1),
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
                          itemCount: _withdrawHeadHistory.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 6,
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                onTap: () {
                                  getWithDrawHistoryList(
                                      _withdrawHeadHistory[index].f_withID);
                                  // getReceiveHead(
                                  //     _receiveHistory[index].f_recvID);
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
                                                'เลขที่เอกสารใบเบิก : ${_withdrawHeadHistory[index].f_withID}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'วันที่เบิกออก : ${_withdrawHeadHistory[index].f_withDate == '' ? '' : DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(_withdrawHeadHistory[index].f_withDate))}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'ผู้เบิกออกสินค้า : ${_withdrawHeadHistory[index].f_withWithdrawer}',
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
                                      _showStatusWithDrawTablet(
                                          _withdrawHeadHistory[index]
                                              .f_withStatus),
                                    ],
                                  ),
                                ),
                                leading: const Icon(
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
                        SizedBox(
                          width: 100,
                          height: 20,
                          child: Text(
                            '${_withdrawHeadHistory.length} Records.',
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

  Future<void> showAlertgetWithdrawMobile() async {
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
                            'Withdraw History ( ประวัติเบิกออกสินค้า )',
                            style: TextStyle(
                              color: Color.fromRGBO(187, 56, 27, 1),
                              fontSize: 10,
                            ),
                          ),
                        ),
                        _Triangle(color: Color.fromRGBO(187, 56, 27, 1))
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width / 6,
                              color: const Color.fromRGBO(187, 56, 27, 1),
                              margin: const EdgeInsets.only(bottom: 5),
                              child: Center(
                                child: Text(
                                  'เลขที่ใบเบิก',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width /
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
                                width: MediaQuery.of(context).size.width / 6,
                                height: 30,
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 5),
                                child: TextFormField(
                                  onFieldSubmitted: (value) {},
                                  style: const TextStyle(
                                    color: Colors.black,
                                    backgroundColor: Colors.white,
                                  ),
                                  controller: _txtSearchDocument_history,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
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
                                // width: MediaQuery.of(context).size.width/5,
                                height: 30,
                                margin: const EdgeInsets.only(bottom: 5),
                                // color: Colors.red,
                                child: TextFormField(
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 45,
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
                                      lastDate: DateTime(2099),
                                    ).then(
                                      (selectedDate) {
                                        if (selectedDate != null) {
                                          _txtSearchDateStart.text =
                                              DateFormat('dd-MM-yyyy')
                                                  .format(selectedDate);
                                        }
                                      },
                                    );
                                  },
                                  controller: _txtSearchDateStart,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.only(left: 10),
                                    labelStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                40),
                                    labelText: 'วันที่เริ่มต้น',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(187, 56, 27, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(187, 56, 27, 1),
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
                                        MediaQuery.of(context).size.width / 45,
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
                                              DateFormat('dd-MM-yyyy')
                                                  .format(selectedDate);
                                        }
                                      },
                                    );
                                  },
                                  controller: _txtSearchDateEnd,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.only(left: 10),
                                    labelStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                40),
                                    labelText: 'วันที่สุดท้าย',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(187, 56, 27, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(187, 56, 27, 1),
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
                                  border: Border.all(
                                      color:
                                          const Color.fromRGBO(187, 56, 27, 1),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.only(left: 10),
                                margin: const EdgeInsets.only(bottom: 5),
                                child: DropdownButton<StatusCheck>(
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 45,
                                    color: Colors.black,
                                  ),
                                  underline: const SizedBox.shrink(),
                                  isExpanded: true,
                                  value: _selectedHistory,
                                  onChanged: (newValue) {
                                    if (mounted) {
                                      setState(() {
                                        _selectedHistory = newValue;
                                        //print(_selected!.id);
                                      });
                                    }
                                  },

                                  //todo change dropdown
                                  items: statuscheckWithdraw.map(
                                    (StatusCheck _check) {
                                      return DropdownMenuItem<StatusCheck>(
                                        value: _check,
                                        child: Text(_check.name),
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
                                  .parse(_txtSearchDateStart.text.toString())
                                  .toString();

                              _dateEnd = DateFormat("dd-MM-yyyy")
                                  .parse(_txtSearchDateEnd.text.toString())
                                  .toString();
                            }

                            data = {
                              'f_withID': _txtSearchDocument_history.text
                                          .toString() !=
                                      ''
                                  ? _txtSearchDocument_history.text.toString()
                                  : '',
                              'f_dateStart': _dateStart,
                              'f_dateEnd': _dateEnd,
                              'f_withStatus': _selectedHistory!.id
                            };

                            if (data.isNotEmpty) {
                              // print(data);
                              getWithDrawHistoryByID(data);
                            }
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(187, 56, 27, 1),
                            ),
                            width: MediaQuery.of(context).size.width - 60,
                            height: 30,
                            child: Center(
                              child: Text(
                                'Load Data',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 45,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 100,
                        height: MediaQuery.of(context).size.height * 0.5,
                        color: Colors.white,
                        child: ListView.builder(
                          itemCount: _withdrawHeadHistory.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 6,
                              margin: const EdgeInsets.all(5),
                              child: ListTile(
                                onTap: () {
                                  getWithDrawHistoryList(
                                      _withdrawHeadHistory[index].f_withID);
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
                                              'เลขที่เอกสารใบเบิก : ${_withdrawHeadHistory[index].f_withID}',
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
                                              'วันที่เบิกออก : ${_withdrawHeadHistory[index].f_withDate == '' ? '' : DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(_withdrawHeadHistory[index].f_withDate))}',
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
                                              'ผู้เบิกออกสินค้า : ${_withdrawHeadHistory[index].f_withWithdrawer}',
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
                                          ? _showStatusWithDrawMobile(
                                              _withdrawHeadHistory[index]
                                                  .f_withStatus)
                                          : _showStatusWithDrawTablet(
                                              _withdrawHeadHistory[index]
                                                  .f_withStatus),
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
                    // SizedBox(
                    //   height: 20,
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Container(
                        //   width: 60,
                        //   height: 10,
                        //   child:
                        Text(
                          '${_withdrawHeadHistory.length} Records.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 40,
                          ),
                        ),
                        // )
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

  Future<void> getWithDrawHistoryList(String id) async {
    String url = "$server/api/withdraw/'$id'";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    final jsonResponce = json.decode(responce.body);

    List<WithDrawHead> temp = (jsonResponce['data'] as List)
        .map((item) => WithDrawHead.fromJson(item))
        .toList();
    String withID = "";

    if (mounted) {
      setState(
        () {
          _withdrawHeadHistory.clear();
          _withdrawHeadHistory.addAll(temp);

          if (_withdrawHeadHistory.isNotEmpty) {
            withID = _withdrawHeadHistory[0].f_withID;
            _NewDoc = false;

            productCount = _withdrawHeadHistory.length;

            _txtdocumentID.text = _withdrawHeadHistory[0].f_withID.toString();
            _txtSearchDocument.text = _withdrawHeadHistory[0].f_withReq.isEmpty
                ? "ไม่พบใบรายการเอกสารขอเบิก"
                : _withdrawHeadHistory[0].f_withReq.toString();

            _txtdocumentDate.text = temp[0].f_withDate.toString() == null
                ? ''
                : DateFormat('dd-MM-yyyy').format(
                    DateTime.parse(temp[0].f_withDate),
                  );
            _txtuserWithdraw.text =
                _withdrawHeadHistory[0].f_withWithdrawer == null
                    ? ''
                    : _withdrawHeadHistory[0].f_withWithdrawer.toString();

            _txtdocumentRef.text =
                _withdrawHeadHistory[0].f_withReferance == null
                    ? ''
                    : _withdrawHeadHistory[0].f_withReferance.toString();

            _txtdocumentRefDate.text = _withdrawHeadHistory[0]
                        .f_withReferanceDate
                        .toString() !=
                    ''
                ? DateFormat('dd-MM-yyyy').format(
                    DateTime.parse(_withdrawHeadHistory[0].f_withReferanceDate))
                : 'ไม่มี';

            _txtRemark.text = _withdrawHeadHistory[0].f_withRemark == null
                ? ''
                : _withdrawHeadHistory[0].f_withRemark.toString();

            _wareID = _withdrawHeadHistory[0].f_wareID.toString();
            _txtwareName.text = _withdrawHeadHistory[0].f_wareName.toString();

            _txtcustomerName.text =
                _withdrawHeadHistory[0].f_cusName.toString();

            _txtuserWithdraw.text =
                _withdrawHeadHistory[0].f_withWithdrawer.toString();

            // _dropdownMenuItemsHistory1 =
            //     buildDropDownMenuItemsHistoryWithdraw(temp);
            // _ItemHistory = _dropdownMenuItemsHistory1[0].value as WithDrawHead;

            // _dropdownMenuItemsCustomer = buildDropDownMenuItemsCustomer(temp);
            // _selectedItemCustomer = _dropdownMenuItemsCustomer[0].value;

            _showButton = false;
          } else {
            showMessageAlert();
          }
        },
      );
    }

    getWithDrawDetailHistory(withID);
  }

  // ค้นหาเอกสารใบขอเบิกตามช่วงวันที่ หรือ status
  Future<void> getWithDrawReqHistoryByID(Map<dynamic, dynamic> values) async {
    String url = "$server/api/withdrawReq/historyAll/";
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

  // ค้นหาเอกสารใบเบิก ตามช่วงวันที่ หรือ status
  Future<void> getWithDrawHistoryByID(Map<dynamic, dynamic> values) async {
    String url = "$server/api/withdraw/historyAll/";
    final responce = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: convert.jsonEncode({
          'f_withID': values['f_withID'],
          'f_dateStart': values['f_dateStart'],
          'f_dateEnd': values['f_dateEnd'],
          'f_withStatus': values['f_withStatus']
        }));
    final jsonResponce = json.decode(responce.body);

    List<WithDrawHead> temp = (jsonResponce['data'] as List)
        .map((item) => WithDrawHead.fromJson(item))
        .toList();

    if (mounted) {
      setState(() {
        _withdrawHeadHistory.clear();
        _withdrawHeadHistory.addAll(temp);
        Navigator.pop(context);
        showAlertgetWithdrawMobile();
        // Responsive.isMobile(context)
        //     ? showAlertgetWithdrawMobile()
        //     : showAlertgetWithdrawTablet();
      });
    }
  }

  Future<void> getWithDrawDetailHistory(String id) async {
    String url = "$server/api/withdrawdetail/'$id'";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    final jsonResponce = json.decode(responce.body);

    List<WithDrawDetail> temp = (jsonResponce['data'] as List)
        .map((item) => WithDrawDetail.fromJson(item))
        .toList();

    if (mounted) {
      setState(
        () {
          _withdrawDetailHistory.clear();
          _withdrawDetailHistory.addAll(temp);

          sumValueHistory();

          if (_withdrawDetailHistory.isNotEmpty) {
            productCount = _withdrawDetailHistory.length;
          }
        },
      );
    }
  }

  /////////////////////////////////////////////////////////////////////////////

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
      _selectedItem = _dropdownMenuItems[0].value as Inventory;
    }
  }

  Future<void> getCustomer() async {
    String url = "$server/api/customer";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(responce.body);
    List<Customer> temp = (jsonResponce['data'] as List)
        .map((item) => Customer.fromJson(item))
        .toList();

    if (mounted) {
      setState(() {
        _dropdownMenuItemsCustomer = buildDropDownMenuItemsCustomer(temp);
        if (temp.isNotEmpty) {
          _selectedItemCustomer =
              _dropdownMenuItemsCustomer[0].value as Customer;
        }
      });
    }
  }

  List<DropdownMenuItem<Inventory>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<Inventory>> items = [];
    for (int i = 0; i <= listItems.length - 1; i++) {
      Inventory listItem = listItems[i];
      items.add(
        DropdownMenuItem(
          value: listItem,
          child: Text(listItem.f_wareName),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<WithDrawHead>> buildDropDownMenuItemsHistoryWithdraw(
      List listItems) {
    List<DropdownMenuItem<WithDrawHead>> items = [];
    for (int i = 0; i <= listItems.length - 1; i++) {
      WithDrawHead listItem = listItems[i];
      items.add(
        DropdownMenuItem(
          value: listItem,
          child: Text(listItem.f_wareName),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<WithdrawReqHead>> buildDropDownMenuItemsHistory(
      List listItems) {
    List<DropdownMenuItem<WithdrawReqHead>> items = [];
    for (int i = 0; i <= listItems.length - 1; i++) {
      WithdrawReqHead listItem = listItems[i];
      items.add(
        DropdownMenuItem(
          value: listItem,
          child: Text(listItem.f_wareName),
        ),
      );
    }
    return items;
  }

  Future<void> insertWithdrawDetail(Map<dynamic, dynamic> values) async {
    //print(values);
    String url = "$server/api/withdrawdetail";
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {
          'f_withID': values['f_withID'],
          'f_prodID': values['f_prodID'],
          'f_withQty': values['f_withQty'],
        },
      ),
    );

    updateWithdrawReqHead(_txtSearchDocument.text.toString());

    if (mounted) {
      setState(() {
        _NewDoc = true;
        _setting == "1" ? _showButton = false : _showButton = true;
        productCount = 0;
        SumValue = 0;
        SumCountValue = 0;

        _productlist.clear();
        _withdrawReqDetail.clear();

        _txtdocumentID.clear();
        _txtdocumentDate.clear();
        _txtdocumentRef.clear();
        _txtdocumentRefDate.clear();
        _txtuserWithdraw.clear();
        _txtRemark.clear();
        _inventory.clear();

        _txtSearchDocument.clear();

        getCustomer();
        getInventory();
        getWithdrawID();
        getDataPref();
      });
    }

    _onAlertButtonPressed(context);
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
            width: 120,
            onPressed: () {
              if (mounted) {
                setState(() {
                  productCount = 0;
                  SumValue = 0;
                  SumCountValue = 0;

                  _productlist.clear();
                  _txtdocumentID.clear();
                  _txtdocumentDate.clear();
                  _txtdocumentRef.clear();
                  _txtdocumentRefDate.clear();
                  _txtuserWithdraw.clear();
                  _txtRemark.clear();

                  _txtSearchDocument.clear();
                });
              }
              Navigator.pop(context);
            },
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ))
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
            width: 120,
            onPressed: () {
              Navigator.pop(context);
              // if (mounted) {
              //   setState(() {
              //     productCount = 0;
              //     SumValue = 0;
              //     SumCountValue = 0;

              //     _productlist.clear();
              //     _txtdocumentID.clear();
              //     _txtdocumentDate.clear();
              //     _txtdocumentRef.clear();
              //     _txtdocumentRefDate.clear();
              //     _txtuserWithdraw.clear();
              //     _txtRemark.clear();

              //     _txtSearchDocument.clear();
              //   });
              // }
              // Navigator.of(context).pop();
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (BuildContext context) => WithdrawPage(),
              //   ),
              // );
            },
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ))
      ],
    ).show();
  }

  Future<void> updateWithdrawReqHead(String id) async {
    String url = "$server/api/withdrawReq/'$id'";
    final response = await http
        .put(Uri.parse(url), headers: {"Content-Type": "application/json"});

    // if (response.statusCode == 200) {
    //   return _onAlertButtonPressed(context);
    // }
    // ;

    // if (response.statusCode == 200) {
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: new Text("Alert!!"),
    //         content: new Text("Save success!"),
    //         actions: <Widget>[
    //           new TextButton(
    //             child: new Text("OK"),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }
    // ;
  }

  Future<void> insertWithdrawHead(Map<String, dynamic> values) async {
    print(values);
    String url = "$server/api/withdraw";
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {
          'f_withID': values['f_withID'],
          'f_withDate': values['f_withDate'],
          'f_withRemark': values['f_withRemark'],
          'f_withStatus': values['f_withStatus'],
          'f_withWithdrawer': values['f_withWithdrawer'],
          'f_withReferance': values['f_withReferance'],
          'f_withReferanceDate': values['f_withReferanceDate'],
          'f_withTo': values['f_withTo'],
          'f_wareID': values['f_wareID'],
          'f_withReq': values['f_withReq'],
          'f_isArrive': values['f_isArrive'],
          'f_arriveDate': values['f_arriveDate']
        },
      ),
    );

    if (response.statusCode == 200) {
      /////// insert detail /////////////////////

      for (int i = 0;
          i <
              (_txtSearchDocument.text != ''
                  ? _withdrawReqDetail.length
                  : _productlist.length);
          i++) {
        // for (int i = 0; i < _productlist.length; i++) {
        // print(i);
        var withdraw = {};
        withdraw.clear();

        withdraw = {
          'f_withID': _txtdocumentID.text.toString(),
          'f_prodID': (_txtSearchDocument.text != ''
              ? _withdrawReqDetail[i].f_prodID
              : _productlist[i].f_prodID),
          'f_withQty': (_txtSearchDocument.text != ''
              ? _withdrawReqDetail[i].f_withReqQty
              : _productlist[i].QTY),
        };

        insertWithdrawDetail(withdraw);
      }

      // Navigator.of(context).pop();
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (BuildContext context) => WithdrawPage(),
      //   ),
      // );
    } else {
      return _onAlertWithDrawIDDuplicate(context);
    }
  }

  Future<void> getWithdrawID() async {
    String url = "$server/api/withdraw/";
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

    String WD = "WD";
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

    if (mounted) {
      setState(() {
        _txtdocumentID.text =
            _documentID = WD + year + _monthString + _numberString;

        _txtdocumentID.text = _documentID;

        DateTime now = DateTime.now();
        _txtdocumentDate.text = DateFormat('dd-MM-yyyy HH:mm:ss').format(now);
        isLoading = false;
      });
    }
  }

  Future<void> getWithDrawReqHistory(String id) async {
    //todo
    String url = "$server/api/withdrawReq/'$id'";
    final response = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(response.body);

    List<WithdrawReqHead> temp = (jsonResponce['data'] as List)
        .map((itemWord) => WithdrawReqHead.fromJson(itemWord))
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

  // getwithdrawReq by id and replce to list main
  Future<void> getWithdrawReqID(String id) async {
    // print("OK");
    String url = "$server/api/withdrawReq/'$id'";
    final response = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(response.body);

    List<WithdrawReqHead> temp = (jsonResponce['data'] as List)
        .map((itemWord) => WithdrawReqHead.fromJson(itemWord))
        .toList();

    if (mounted) {
      setState(
        () {
          // print(temp);
          _withdrawReqHead.clear();
          _withdrawReqHead.addAll(temp);

          if (_withdrawReqHead.isNotEmpty) {
            withReq = _withdrawReqHead[0].f_withReqTo;
            _showButton = false;
            _NewDoc = true;

            _showButtonSave = false;
            // if (_withdrawReqHead[0].f_withReqStatus != 1) {
            //   _showButtonSave = false;
            // } else {
            //   _showButtonSave = true;
            // }

            _txtSearchDocument.text = _withdrawReqHead[0].f_withReqID ?? '';

            DateTime now = DateTime.now();
            _txtdocumentDate.text =
                DateFormat('dd-MM-yyyy HH:mm:ss').format(now);

            _txtuserWithdraw.text =
                _withdrawReqHead[0].f_withReqWithdrawer ?? '';

            _txtdocumentRef.text = _withdrawReqHead[0].f_withReqReferance ?? '';

            _txtdocumentRefDate.text = _withdrawReqHead[0]
                        .f_withReqReferanceDate
                        .toString() !=
                    ''
                ? DateFormat('dd-MM-yyyy').format(
                    DateTime.parse(_withdrawReqHead[0].f_withReqReferanceDate))
                : '';

            _txtRemark.text = _withdrawReqHead[0].f_withReqRemark ?? '';

            // _dropdownMenuItemsHistory = buildDropDownMenuItemsHistory(temp);
            // _selectedItemHistory =
            //     _dropdownMenuItemsHistory[0].value as WithdrawReqHead;
            _wareID = _withdrawReqHead[0].f_wareID;
            _txtwareName.text = _withdrawReqHead[0].f_wareName;
          } else {
            showMessageAlert();
          }
        },
      );
    }
    getWithdrawReqDetail(id);
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

  _showStatusWithDrawMobile(int _text) {
    String _content;
    if (_text == 1) {
      _content = "Normal";
    } else {
      _content = "Cancle";
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

  _showStatusWithDrawTablet(int _text) {
    String _content;
    if (_text == 1) {
      _content = "Normal";
    } else {
      _content = "Cancle";
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

  // ดึงเอกสารขอเบิกทั้งหมด ปุ่มแว่นขยาย
  Future<void> getWithdrawReqAll() async {
    String url = "$server/api/withdrawReq";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    final jsonResponce = json.decode(responce.body);
    List<WithdrawReqHead> temp = (jsonResponce['data'] as List)
        .map((item) => WithdrawReqHead.fromJson(item))
        .toList();
    if (mounted) {
      setState(() {
        _selected = statuscheck[0];
        //_txtSearchDocument.clear();
        _txtSearchDateStart.clear();
        _txtSearchDateEnd.clear();

        DateTime _dateStart;
        DateTime _dateEnd;
        _dateStart = DateTime.now().subtract(const Duration(days: 45));
        _dateEnd = DateTime.now();

        _txtSearchDateStart.text = DateFormat('dd-MM-yyyy').format(_dateStart);
        _txtSearchDateEnd.text = DateFormat('dd-MM-yyyy').format(_dateEnd);

        _withdrawReqHead.clear();
        _withdrawReqHead.addAll(temp);
        showAlertgetWithdrawReqMobile();
        // Responsive.isMobile(context)
        //     ? showAlertgetWithdrawReqMobile()
        //     : showAlertgetWithdrawReqTablet();
      });
    }
  }

  // showDialog แว่นขยายขอเบิก
  Future<void> showAlertgetWithdrawReqTablet() async {
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
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
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
                                width: MediaQuery.of(context).size.width * 0.10,
                                color: const Color.fromRGBO(255, 130, 68, 1),
                                margin: const EdgeInsets.only(bottom: 5),
                                child: const Center(
                                  child: Text(
                                    'เลขที่ใบขอเบิก',
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.10,
                                  height: 40,
                                  color: Colors.black,
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.amber[900],
                                      // backgroundColor: Colors.white,
                                    ),
                                    controller: _txtSearchDocument,
                                    decoration: const InputDecoration(
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
                              Container(
                                width: 50,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color.fromRGBO(255, 130, 68, 1),
                                ),
                                child: Center(
                                  child: IconButton(
                                    onPressed: () {
                                      scanBarcodeNormal();
                                    },
                                    icon: const Icon(
                                      Icons.qr_code_scanner,
                                      color: Colors.white,
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
                                              DateFormat('dd-MM-yyyy')
                                                  .format(selectedDate);
                                        }
                                      },
                                    );
                                  },
                                  controller: _txtSearchDateStart,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.only(left: 10),
                                    labelStyle:
                                        const TextStyle(fontSize: mediumText),
                                    labelText: 'วันที่เริ่มต้น',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(255, 130, 68, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(255, 130, 68, 1),
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
                                              DateFormat('dd-MM-yyyy')
                                                  .format(selectedDate);
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
                                        color: Color.fromRGBO(255, 130, 68, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(255, 130, 68, 1),
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
                                  border: Border.all(
                                    color:
                                        const Color.fromRGBO(255, 130, 68, 1),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.only(left: 10),
                                margin: const EdgeInsets.only(bottom: 5),
                                child: DropdownButton<StatusCheck>(
                                  underline: const SizedBox.shrink(),
                                  isExpanded: true,
                                  value: _selected,
                                  onChanged: (newValue) {
                                    if (mounted) {
                                      setState(() {
                                        _selected = newValue;
                                      });
                                    }
                                  },
                                  items: statuscheck.map(
                                    (StatusCheck _check) {
                                      return DropdownMenuItem<StatusCheck>(
                                        value: _check,
                                        child: Text(_check.name),
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
                                'f_withReqID':
                                    _txtSearchDocument.text.toString() != ''
                                        ? _txtSearchDocument.text.toString()
                                        : '',
                                'f_dateStart': _dateStart,
                                'f_dateEnd': _dateEnd,
                                'f_withReqStatus': _selected!.id
                              };

                              // print(data);

                              if (data.isNotEmpty) {
                                getWithDrawReqHistoryByID(data);
                              }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(255, 130, 68, 1),
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
                          itemCount: _withdrawReqHead.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 6,
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                onTap: () {
                                  // ใบขอเบิก
                                  getWithdrawReqID(
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
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                'เลขที่ใบขอเบิก : ${_withdrawReqHead[index].f_withReqID}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'วันที่ขอเบิก : ${_withdrawReqHead[index].f_withReqDate == '' ? '' : DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(_withdrawReqHead[index].f_withReqDate))}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'ผู้เบิกสินค้า : ${_withdrawReqHead[index].f_withReqWithdrawer}',
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
                                      _showStatusTablet(_withdrawReqHead[index]
                                          .f_withReqStatus),
                                    ],
                                  ),
                                ),
                                leading: const Icon(
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
                        SizedBox(
                          width: 100,
                          height: 20,
                          child: Text(
                            '${_withdrawReqHead.length} Records.',
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

  // showDialog แว่นขยายขอเบิก Mobile
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
                    const Column(
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
                                'Withdraw Request ( ใบขอเบิก )',
                                style: TextStyle(
                                  color: Color.fromRGBO(148, 0, 211, 1),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            _Triangle(
                              color: Color.fromRGBO(148, 0, 211, 1),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width / 6,
                              color: const Color.fromRGBO(148, 0, 211, 1),
                              margin: const EdgeInsets.only(bottom: 5),
                              child: Center(
                                child: Text(
                                  'เลขที่ใบขอเบิก',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 45,
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
                                width: MediaQuery.of(context).size.width / 6,
                                height: 30,
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 5),
                                child: TextFormField(
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.black,
                                    backgroundColor: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 45,
                                  ),
                                  controller: _txtSearchDocument,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
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
                                // width: MediaQuery.of(context).size.width/5,
                                height: 30,
                                margin: const EdgeInsets.only(bottom: 5),
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
                                              DateFormat('dd-MM-yyyy')
                                                  .format(selectedDate);
                                        }
                                      },
                                    );
                                  },
                                  controller: _txtSearchDateStart,
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 45,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.only(left: 10),
                                    labelStyle:
                                        const TextStyle(fontSize: mediumText),
                                    labelText: 'วันที่เริ่มต้น',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(148, 0, 211, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(148, 0, 211, 1),
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
                                              DateFormat('dd-MM-yyyy')
                                                  .format(selectedDate);
                                        }
                                      },
                                    );
                                  },
                                  controller: _txtSearchDateEnd,
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 45,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.only(left: 10),
                                    labelStyle:
                                        const TextStyle(fontSize: mediumText),
                                    labelText: 'วันที่สุดท้าย',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(148, 0, 211, 1),
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Color.fromRGBO(148, 0, 211, 1),
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
                                  border: Border.all(
                                    color: const Color.fromRGBO(148, 0, 211, 1),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.only(left: 10),
                                margin: const EdgeInsets.only(bottom: 5),
                                child: DropdownButton<StatusCheck>(
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 45,
                                    color: Colors.black,
                                  ),
                                  underline: const SizedBox.shrink(),
                                  isExpanded: true,
                                  value: _selected,
                                  onChanged: (newValue) {
                                    if (mounted) {
                                      setState(() {
                                        _selected = newValue;
                                      });
                                    }
                                  },
                                  items: statuscheck.map(
                                    (StatusCheck _check) {
                                      return DropdownMenuItem<StatusCheck>(
                                        value: _check,
                                        child: Text(_check.name),
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
                              'f_withReqStatus': _selected!.id
                            };

                            // print(data);

                            if (data.isNotEmpty) {
                              getWithDrawReqHistoryByID(data);
                            }
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(148, 0, 211, 1),
                            ),
                            // width: MediaQuery.of(context).size.width - 60,
                            height: 30,
                            child: Center(
                              child: Text(
                                'Load Data',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 45,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                              margin: const EdgeInsets.all(5),
                              child: ListTile(
                                onTap: () {
                                  // ใบขอเบิก
                                  if (_selected!.id.toString() != "2") {
                                    getWithdrawReqID(
                                        _withdrawReqHead[index].f_withReqID);
                                    Navigator.pop(context);
                                  }
                                },
                                title: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              'เลขที่ใบขอเบิก : ${_withdrawReqHead[index].f_withReqID}',
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          45),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              'วันที่ขอเบิก : ${_withdrawReqHead[index].f_withReqDate == '' ? '' : DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(_withdrawReqHead[index].f_withReqDate))}',
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          45),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              'ผู้เบิกสินค้า : ${_withdrawReqHead[index].f_withReqWithdrawer}',
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          45),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
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
                                // leading: Icon(
                                //   Icons.analytics_outlined,
                                //   size: 60,
                                //   color: Color.fromRGBO(148, 0, 211, 1),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 10,
                          child: Text(
                            '${_withdrawReqHead.length} Records.',
                            style: const TextStyle(
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

  Future<bool?> showMessageAlert_deleteitem() {
    return showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("ต้องการลบหรือไม่?"),
          content: const Text("กดลบรายการนี้จะถูกลบออกในทันที"),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text(
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

  Future<void> showMessageAlert() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert!!"),
          content: const Text("NOT FOUND THIS ID"),
          actions: <Widget>[
            TextButton(
              child: const Text("NOT FOUND"),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _txtdocumentID.clear();
                    _txtdocumentDate.clear();
                    _txtdocumentRef.clear();
                    _txtdocumentRefDate.clear();
                    _txtuserWithdraw.clear();
                    _txtRemark.clear();
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getWithdrawReqDetail(String id) async {
    String url = "$server/api/withdrawReqDetail/$id";
    final response = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(response.body);
    print(jsonResponce['data']);

    List<WithdrawReqDetail> temp = (jsonResponce['data'] as List)
        .map((itemWord) => WithdrawReqDetail.fromJson(itemWord))
        .toList();

    if (mounted) {
      setState(() {
        _withdrawReqDetail.clear();
        _withdrawReqDetail.addAll(temp);
        sumValue();

        if (_withdrawReqDetail.isNotEmpty) {
          productCount = _withdrawReqDetail.length;
        }
      });
    }
  }

  Future<void> getProduct(String id, String wareID) async {
    String encodedId = Uri.encodeComponent(id.replaceAll("'", ""));
    String warehouseID = Uri.encodeComponent(wareID);
    String url = "$server/api/product/'$encodedId'/'$warehouseID'";
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
            if (_productlist[product].QTY < _productlist[product].QTY_all) {
              _productlist[product].QTY = _productlist[product].QTY + 1;
              if (mounted) {
                setState(
                  () {
                    _txtBarcode.clear();
                    sumValue();
                  },
                );
              }
            } else {
              _txtBarcode.clear();
              const snackBar = SnackBar(
                content: Text('สินค้าในคลังไม่เพียงพอ'),
                duration: Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          } else {
            _txtBarcode.clear();
            const snackBar = SnackBar(
              content: Text('สินค้าในคลังไม่เพียงพอ'),
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          _productlist[product].QTY = _productlist[product].QTY + 1;

          if (mounted) {
            setState(
              () {
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
              _txtBarcode.clear();
              sumValue();
              productCount = _productlist.length;
            },
          );
        }
      }
    } else {
      _txtBarcode.clear();
      const snackBar = SnackBar(
        content: Text('ไม่พบรายการสินค้า หรือจำนวนสินค้าไม่เพียงพอ'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> getProductRequestCheck(String id) async {
    int product =
        _withdrawReqDetail.indexWhere((element) => element.f_Barcode == id);
    if (product != -1) {
      if (_setting_nd == "0") {
        if (_withdrawReqDetail[product].QTY_Count <
            _withdrawReqDetail[product].QTY_all) {
          if (_withdrawReqDetail[product].QTY_Count <
              _withdrawReqDetail[product].f_withReqQty) {
            _withdrawReqDetail[product].QTY_Count =
                _withdrawReqDetail[product].QTY_Count + 1;
            if (mounted) {
              setState(
                () {
                  _txtBarcode.clear();
                  sumValue();
                },
              );
            }
          } else {
            const snackBar = SnackBar(
              content: Text('สแกนครบแล้ว'),
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          _txtBarcode.clear();
          const snackBar = SnackBar(
            content: Text('สินค้าในคลังไม่เพียงพอ'),
            duration: Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        if (_withdrawReqDetail[product].QTY_Count <
            _withdrawReqDetail[product].f_withReqQty) {
          _withdrawReqDetail[product].QTY_Count =
              _withdrawReqDetail[product].QTY_Count + 1;
          if (mounted) {
            setState(
              () {
                _txtBarcode.clear();
                sumValue();
              },
            );
          }
        } else {
          const snackBar = SnackBar(
            content: Text('สแกนครบแล้ว'),
            duration: Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } else {
      _txtBarcode.clear();
      const snackBar = SnackBar(
        content: Text('ไม่พบรายการสินค้า'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // Future<void> getProduct(String id) async {
  //   String url = server + "/api/product/'${id}'";
  //   final response = await http
  //       .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

  //   final jsonResponce = json.decode(response.body);
  //   // print(jsonResponce['data']);

  //   List<Product> temp = (jsonResponce['data'] as List)
  //       .map((itemWord) => Product.fromJson(itemWord))
  //       .toList();

  //   setState(() {
  //     _productlist.addAll(temp);
  //     _txtBarcode.clear();
  //   });
  // }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;

    // _withdrawReqHead.clear();
    // _withdrawReqDetail.clear();

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

      // _txtSearchDocument.clear();
      // // getWithdrawReqID(barcodeScanRes);
      // _txtSearchDocument.text = barcodeScanRes;

      // _txtSearchDocument.text.trim();

      // var data = {
      //   'f_withReqID': _txtSearchDocument.text.toString(),
      //   'f_dateStart': '',
      //   'f_dateEnd': '',
      //   'f_withReqStatus': _selected!.id
      // };

      // if (data.length > 0) {
      //   getWithDrawReqHistoryByID(data);
      // }

      _showButton
          ? getProduct(barcodeScanRes, _selectedItem!.f_wareID)
          : getProductRequestCheck(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
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
          style: TextStyle(
            fontSize: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width / 45
                : 16,
            fontFamily: 'Sarabun',
            color: Colors.black,
          ),
          isExpanded: true,
          value: _selectedItem,
          items: _dropdownMenuItems,
          onChanged: (value) {
            _productlist.clear();
            sumValue();
            productCount = _productlist.length;

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
        child: DropdownButton<WithdrawReqHead>(
          style: TextStyle(
            fontSize: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width / 40
                : 16,
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
        child: DropdownButton<Customer>(
            style: TextStyle(
              fontSize: Responsive.isMobile(context)
                  ? MediaQuery.of(context).size.width / 45
                  : 16,
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
            }),
      ),
    );
  }

  Container _buildDropdownCustomerHistory() {
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
        child: DropdownButton<WithdrawReqHead>(
          style: TextStyle(
            fontSize: Responsive.isMobile(context) ? 9 : 16.0,
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

  @override
  Widget build(BuildContext context) {
    FocusNode myFocusNode = FocusNode();
    int count = 0;
    String dropdownValue = 'One';

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

                    getProduct(barcode, _selectedItem!.f_wareID);
                  }
                  // setState(() {
                  //   _barcode = barcode;
                  // });
                },
                useKeyDownEvent: Platform.isWindows,
                child: Scaffold(
                  // resizeToAvoidBottomInset: false,
                  backgroundColor: Colors.grey[200],
                  drawer: Drawer(
                    child: MenuDrawer(),
                  ),
                  appBar: AppBar(
                    iconTheme: const IconThemeData(
                      color: Color.fromRGBO(187, 56, 27, 1),
                    ),
                    title: Text(
                      'Withdraw ( เบิกออกสินค้า )',
                      style: TextStyle(
                        color: const Color.fromRGBO(187, 56, 27, 1),
                        fontSize: Responsive.isMobile(context) ? 15 : 24,
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
                                  const WithdrawPage(),
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
                          _txtSearchDocument_history.clear();
                          // _txtSearchDocument.text = '';
                          getWithdrawAll();
                        },
                        icon: Icon(
                          Icons.description_sharp,
                          size: Responsive.isMobile(context) ? 20 : 24,
                        ),
                      ),
                    ],
                  ),
                  body: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildMobile(context),
                  // Responsive.isMobile(context)
                  //     ? _buildMobile(context)
                  //     : _buildTablet(context),
                  bottomNavigationBar: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        // height: _NewDoc && _showButtonSave
                        //     ? MediaQuery.of(context).size.height * 0.2
                        //     : MediaQuery.of(context).size.height * 0.15,
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
                            SizedBox(
                              // height: 30,
                              width:
                                  MediaQuery.of(context).size.width, //* 0.40,
                              // color: Color.fromRGBO(255, 130, 68, 1),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 8),
                                child: Text(
                                  'ผู้เบิกสินค้า ${_txtuserWithdraw.text}',
                                  style: TextStyle(
                                      color:
                                          const Color.fromRGBO(187, 56, 27, 1),
                                      fontSize: Responsive.isMobile(context)
                                          ? 12
                                          : 18),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20, top: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: Responsive.isMobile(context) ? 3 : 6,
                                    child: Text(
                                      // 'Total ${_productlist.length!= 0 ? _productlist.length : 0} list.',
                                      'Total ${productCount != 0 ? productCount : 0} list.',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'Total ${SumValue != 0 ? SumValue : 0} pcs.',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            (_NewDoc &&
                                    (_showButtonSave ||
                                        (SumValue >= 1 &&
                                            SumCountValue == SumValue))
                                ? (productCount >= 1
                                    ? _buildButtonSave()
                                    : const SizedBox.shrink())
                                : const SizedBox.shrink())
                          ],
                        ),
                      ),
                    ],
                  ),
                )));
  }

  Widget _buildTablet(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
          width: MediaQuery.of(context).size.width,
          height: _NewDoc
              ? MediaQuery.of(context).size.height * 0.24
              : MediaQuery.of(context).size.height * 0.18,
          decoration: const BoxDecoration(
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
                        color: const Color.fromRGBO(187, 56, 27, 1),
                        child: const Center(
                          child: Text(
                            'เลขที่เอกสารใบเบิก',
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
                        color: Colors.black,
                        margin: const EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          readOnly: true,
                          style: const TextStyle(
                            color: Color.fromRGBO(187, 56, 27, 1),
                            backgroundColor: Colors.black,
                          ),
                          controller: _txtdocumentID,
                          decoration: const InputDecoration(
                            // hintText: 'เลขที่เอกสารใบเบิก',
                            // labelStyle: TextStyle(fontSize: mediumText),
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
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: const Color.fromRGBO(187, 56, 27, 1),
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
                        width: MediaQuery.of(context).size.width * 1,
                        height: 40,
                        color: Colors.black,
                        margin: const EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          enabled: _showButton,
                          style: const TextStyle(
                            color: Color.fromRGBO(187, 56, 27, 1),
                            backgroundColor: Colors.black,
                            // fontSize: 9,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: const Color.fromRGBO(187, 56, 27, 1),
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
                          // readOnly: true,
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
                        color: const Color.fromRGBO(187, 56, 27, 1),
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
                          // readOnly: true,
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
                                      DateFormat('dd-MM-yyyy HH:mm:ss')
                                          .format(selectedDate);
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

                      // Container(
                      //   width: MediaQuery.of(context).size.width * 0.28,
                      //   height: 40,
                      //   color: Colors.white,
                      //   margin: EdgeInsets.only(bottom: 5),
                      //   child: TextFormField(
                      //     readOnly: true,
                      //     onTap: () {},
                      //     controller: _txtdocumentRefDate,
                      //     decoration: InputDecoration(
                      //       // labelText: 'วันที่เอกสารอ้างอิง',
                      //       labelStyle: TextStyle(fontSize: mediumText),
                      //       border: OutlineInputBorder(),
                      //       errorBorder: OutlineInputBorder(
                      //         borderSide:
                      //             BorderSide(color: Colors.red, width: 5),
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      // SizedBox(
                      //   width: 10,
                      // ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: const Color.fromRGBO(187, 56, 27, 1),
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
                      _NewDoc
                          ? _showButton
                              ? _buildDropdownInventory()
                              : Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.28,
                                  height: 40,
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    // readOnly: true,
                                    controller: _txtwareName,
                                    decoration: const InputDecoration(
                                      // labelText: 'เอกสารอ้างอิง',
                                      labelStyle:
                                          TextStyle(fontSize: mediumText),
                                      border: OutlineInputBorder(),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red, width: 5),
                                      ),
                                    ),
                                  ),
                                )
                          : Container(
                              width: MediaQuery.of(context).size.width * 0.28,
                              height: 40,
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 5),
                              child: TextFormField(
                                // readOnly: true,
                                controller: _txtwareName,
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
                        color: const Color.fromRGBO(187, 56, 27, 1),
                        child: const Center(
                          child: Text(
                            'ผู้รับ/ลูกค้า',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 1,
                      ),
                      _showButton
                          ? _buildDropdownCustomer()
                          : Container(
                              width: MediaQuery.of(context).size.width * 0.28,
                              height: 40,
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 5),
                              child: TextFormField(
                                // readOnly: true,
                                controller: _txtcustomerName,
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
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: const Color.fromRGBO(187, 56, 27, 1),
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
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: 40,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          // readOnly: true,
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
          height: 20,
          color: const Color.fromRGBO(187, 56, 27, 1),
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
                    cursorColor: const Color.fromRGBO(187, 56, 27, 1),
                    maxLines: 1,
                    style:
                        const TextStyle(color: Color.fromRGBO(187, 56, 27, 1)),
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
                          color: _showButton
                              ? const Color.fromRGBO(187, 56, 27, 1)
                              : Colors.grey,
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
          height: 15,
        ),
        // _NewDoc ? _buildWithdrawReq() : _buildWithdrawHistory()

        _NewDoc ? _buildProduct() : _buildWithdrawHistory()
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: (_NewDoc &&
                (_showButtonSave ||
                    (SumValue >= 1 && SumCountValue == SumValue))
            ? (productCount >= 1
                ? MediaQuery.of(context).size.height * 0.73
                : MediaQuery.of(context).size.height * 0.8)
            : MediaQuery.of(context).size.height * 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.only(top: 0, left: 10, right: 5, bottom: 0),
              width: MediaQuery.of(context).size.width,
              // height: _NewDoc
              //     ? MediaQuery.of(context).size.height * 0.22
              //     : MediaQuery.of(context).size.height * 0.22,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Text(
                            "เลขที่เอกสารขอเบิก",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 50),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Container(
                              //   height: 30,
                              //   width: MediaQuery.of(context).size.width/7,
                              //   color: Color.fromRGBO(148, 0, 211, 1),
                              //   child: Align(
                              //     child: Text(
                              //       'เลขที่เอกสารขอเบิก',
                              //       textAlign: TextAlign.center,
                              //       style: TextStyle(
                              //         color: Colors.white,
                              //         fontSize: MediaQuery.of(context).size.width/45,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(
                                width: 1,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                height: MediaQuery.of(context).size.height / 34,
                                // color: Colors.black,
                                margin: const EdgeInsets.only(bottom: 5),
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  readOnly: true,
                                  style: TextStyle(
                                    color: Colors.red,
                                    // color: Color.fromRGBO(148, 0, 211, 1),
                                    // backgroundColor: Colors.black,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 50,
                                  ),
                                  controller: _txtSearchDocument,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12.0),
                                    hintText: '< --------- เลือก --------- >',
                                    // labelText: 'เลขที่เอกสารขอเบิก',
                                    // labelStyle: TextStyle(fontSize: MediaQuery.of(context).size.width/45),
                                    hintStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                65),

                                    border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10))),
                                    errorBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   width: 10,
                              // ),
                              Container(
                                width: MediaQuery.of(context).size.width / 9,
                                height: MediaQuery.of(context).size.height / 34,
                                decoration: BoxDecoration(
                                  color: _NewDoc
                                      ? const Color.fromRGBO(148, 0, 211, 1)
                                      : Colors.grey,
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  // color: Color.fromRGBO(148, 0, 211, 1),
                                ),
                                child: Center(
                                  child: IconButton(
                                    onPressed: () {
                                      // Mobile
                                      if (_NewDoc) getWithdrawReqAll();
                                    },
                                    padding: const EdgeInsets.all(0),
                                    icon: Text(
                                      "เลือก",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              70,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: const Color.fromRGBO(187, 56, 27, 1),
                            child: Align(
                              child: Text(
                                'เลขที่เอกสารใบเบิก',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 65,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3.67,
                            height: MediaQuery.of(context).size.height / 34,
                            color: Colors.black,
                            margin: const EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              readOnly: true,
                              style: TextStyle(
                                color: Colors.white,
                                // backgroundColor: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width / 50,
                              ),
                              controller: _txtdocumentID,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.0), // ปรับ padding แนวตั้ง
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
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: const Color.fromRGBO(187, 56, 27, 1),
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
                          const SizedBox(
                            width: 1,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3.25,
                            height: MediaQuery.of(context).size.height / 34,
                            color: Colors.black,
                            // margin: EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              readOnly: true,
                              onTap: () {},
                              controller: _txtdocumentDate,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 50,
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
                                hintText: "วันที่บันทึก",
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: const Color.fromRGBO(187, 56, 27, 1),
                            child: Center(
                              child: Text(
                                'เอกสารอ้างอิง',
                                textAlign: TextAlign.center,
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
                            width: MediaQuery.of(context).size.width / 3.67,
                            height: MediaQuery.of(context).size.height / 34,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 50,
                              ),
                              readOnly: !_NewDoc,
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
                            width: 5,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: const Color.fromRGBO(187, 56, 27, 1),
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
                            width: MediaQuery.of(context).size.width / 3.25,
                            height: MediaQuery.of(context).size.height / 34,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              readOnly: true,
                              onTap: () async {
                                if (_NewDoc) {
                                  await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2021),
                                    lastDate: DateTime(2099),
                                  ).then(
                                    (selectedDate) {
                                      if (selectedDate != null) {
                                        _txtdocumentRefDate.text =
                                            DateFormat('dd-MM-yyyy')
                                                .format(selectedDate);
                                      }
                                    },
                                  );
                                }
                                ;
                              },
                              controller: _txtdocumentRefDate,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 50,
                              ),
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
                                hintText: "กรุณาเลือกวัน",
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
                          const SizedBox(
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
                            color: const Color.fromRGBO(187, 56, 27, 1),
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
                          const SizedBox(
                            width: 1,
                          ),
                          _NewDoc
                              ? _showButton
                                  ? _buildDropdownInventory()
                                  : Container(
                                      width: MediaQuery.of(context).size.width /
                                          3.67,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              34,
                                      color: Colors.white,
                                      margin: const EdgeInsets.only(bottom: 5),
                                      child: TextFormField(
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              50,
                                        ),
                                        readOnly: true,
                                        controller: _txtwareName,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12.0),
                                          hintText: 'คลังสินค้า',
                                          labelStyle:
                                              TextStyle(fontSize: mediumText),
                                          border: OutlineInputBorder(),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 5),
                                          ),
                                        ),
                                      ),
                                    )
                              : Container(
                                  width:
                                      MediaQuery.of(context).size.width / 3.67,
                                  height:
                                      MediaQuery.of(context).size.height / 34,
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              50,
                                    ),
                                    readOnly: true,
                                    controller: _txtwareName,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      hintText: 'คลังสินค้า',
                                      labelStyle:
                                          TextStyle(fontSize: mediumText),
                                      border: OutlineInputBorder(),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red, width: 5),
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 34,
                            width: MediaQuery.of(context).size.width / 7,
                            color: const Color.fromRGBO(187, 56, 27, 1),
                            child: Center(
                              child: Text(
                                'ผู้เบิกสินค้า',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 1,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3.25,
                            height: MediaQuery.of(context).size.height / 34,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 50,
                              ),
                              readOnly: true,
                              controller: _txtuserWithdraw,
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12.0),
                                hintText: 'ผู้รับเข้าสินค้า',
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
                              height: MediaQuery.of(context).size.height / 34,
                              width: MediaQuery.of(context).size.width / 7,
                              color: const Color.fromRGBO(187, 56, 27, 1),
                              child: Center(
                                child: Text(
                                  'ผู้รับ/ลูกค้า',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              50),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 1,
                            ),
                            _showButton
                                ? _buildDropdownCustomer()
                                : Container(
                                    width: MediaQuery.of(context).size.width /
                                        3.67,
                                    height:
                                        MediaQuery.of(context).size.height / 34,
                                    color: Colors.white,
                                    margin: const EdgeInsets.only(bottom: 5),
                                    child: TextFormField(
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                50,
                                      ),
                                      readOnly: true,
                                      controller: _txtcustomerName,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12.0),
                                        hintText: 'ผู้รับ/ลูกค้า',
                                        labelStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                50),
                                        border: const OutlineInputBorder(),
                                        errorBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.red, width: 5),
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(
                              width: 5,
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 34,
                              width: MediaQuery.of(context).size.width / 7,
                              color: const Color.fromRGBO(187, 56, 27, 1),
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
                            const SizedBox(
                              width: 1,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 3.25,
                              height: MediaQuery.of(context).size.height / 34,
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 5),
                              child: TextFormField(
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50,
                                ),
                                readOnly: !_NewDoc,
                                controller: _txtRemark,
                                decoration: const InputDecoration(
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
                          ]),
                    ],
                  ),
                ),
              ),
            ),

            _NewDoc
                ? Stack(children: [
                    Positioned(
                      child: Container(
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
                                  0, 20), // changes position of shadow
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
                                    : _showButton
                                        ? getProduct(value.toString(),
                                            _selectedItem!.f_wareID)
                                        : getProductRequestCheck(
                                            value.toString()),
                              },
                              enabled: true,
                              controller: _txtBarcode,
                              cursorColor: const Color.fromRGBO(187, 56, 27, 1),
                              maxLines: 1,
                              style: const TextStyle(
                                  color: Color.fromRGBO(187, 56, 27, 1)),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: const OutlineInputBorder(
                                    //Colors.transparent คือ สีใ
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.transparent)),
                                disabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30.0)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Colors.transparent,
                                    )),
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
                                  // padding: new EdgeInsets.all(0.0),
                                  onPressed: () => scanBarcodeNormal(),

                                  icon: const Icon(
                                    Icons.qr_code_scanner,
                                    color: Color.fromRGBO(187, 56, 27, 1),
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
                      ),
                    )
                  ])
                : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 30,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: const Offset(
                                0, 20), // changes position of shadow
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20))),
                    // color: Color.fromRGBO(187, 56, 27, 1),
                  ),

            // SizedBox(
            //   height: 15,
            // ),
            // _buildProduct() : _buildWithdrawHistory()
            _NewDoc
                ? (_txtSearchDocument.text != ''
                    ? _buildWithdrawReq()
                    : _buildProduct())
                : _buildWithdrawHistory()
          ],
        ),
      ),
    );
  }

  Expanded _buildProduct() {
    return Expanded(
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
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'รหัสสินค้า : ${_productlist[index].f_prodID}',
                          style: TextStyle(
                              color: Colors.amber[900],
                              fontSize: Responsive.isMobile(context) ? 9 : 12),
                        ),
                        IconButton(
                          onPressed: () async {
                            final shouldDelete =
                                await showMessageAlert_deleteitem();
                            if (shouldDelete != null) {
                              if (shouldDelete) {
                                if (mounted) {
                                  setState(() {
                                    productCount = productCount - 1;
                                    SumValue =
                                        SumValue - _productlist[index].QTY;
                                    SumCountValue = SumValue;
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
                    const SizedBox(
                      height: 1,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ชื่อสินค้า : ${_productlist[index].f_prodName}',
                          style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 9 : 12,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
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
                                            productCount = productCount - 1;
                                            SumValue = SumValue -
                                                _productlist[index].QTY;
                                            SumCountValue = SumValue;
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
                                          if (_productlist.isNotEmpty) {
                                            if (_productlist[index].QTY >= 2) {
                                              _productlist[index].QTY =
                                                  _productlist[index].QTY - 1;
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
                                height:
                                    MediaQuery.of(context).size.width * 0.09,
                                width: MediaQuery.of(context).size.width * 0.09,
                                decoration: const BoxDecoration(
                                    // color: Colors.white
                                    ),
                                //color: Colors.red,
                                child: Center(
                                  child: Text(
                                    '${_productlist[index].QTY}',
                                    style: TextStyle(
                                      color: Colors.amber[900],
                                      fontSize: Responsive.isMobile(context)
                                          ? MediaQuery.of(context).size.width /
                                              30
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
                                          keyboardType: TextInputType.number,
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
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    buttons: [
                                      DialogButton(
                                        color: Colors.green,
                                        onPressed: () {
                                          int num = int.parse(_txtCount.text);
                                          if (num >= 1) {
                                            if (_setting_nd == "1") {
                                              if (num <=
                                                  _productlist[index].QTY_all) {
                                                _productlist[index].QTY =
                                                    int.parse(_txtCount.text);
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
                                icon: const Icon(Icons.add),
                                color: Colors.white,
                                alignment: Alignment.center,
                                iconSize: 15,
                              ),
                            ),
                          ],
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
                width: 50,
                height: 50,
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
    );
  }

  Row _buildButtonSave() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 10, bottom: 10),
              child: ElevatedButton(
                onPressed: () async {
                  _NewDoc = false;
                  _showButtonSave = false;
                  await getWithdrawID();

                  String _withDate = "";
                  String _withRefDate = "";

                  if (_txtdocumentDate.text.toString() != '') {
                    // _withDate = DateFormat("dd-MM-yyyy")
                    _withDate = DateFormat("dd-MM-yyyy HH:mm:ss")
                        .parse(_txtdocumentDate.text.toString())
                        .toString();
                  }

                  if (_txtdocumentRefDate.text.toString() != '') {
                    _withRefDate = DateFormat("dd-MM-yyyy")
                        .parse(_txtdocumentRefDate.text.toString())
                        .toString();
                  }

                  String customer;
                  if (_selectedItemCustomer != null) {
                    customer = _selectedItemCustomer!.f_cusID;
                  } else {
                    customer = "";
                  }

                  var value = {
                    'f_withID':
                        _txtdocumentID.text.toString(), // เลขที่เอกสารใบเบิก
                    'f_withDate': _withDate, // วันที่เอกสารใบเบิก
                    'f_withRemark': _txtRemark.text.toString(), // Remark
                    'f_withStatus': 1, //สถานะเอกสาร
                    'f_withWithdrawer':
                        _txtuserWithdraw.text.toString(), // ผู้เบิกสินค้า
                    'f_withReferance':
                        _txtdocumentRef.text.toString(), //เอกสารอ้างอิง
                    'f_withReferanceDate': _withRefDate, //วันที่เอกสารอ้่างอิง
                    'f_withTo':
                        customer, //_selectedItemCustomer!.f_cusID , // ผู้รับสินค้า
                    'f_wareID': _showButton
                        ? _selectedItem!.f_wareID
                        : _wareID, // คลังสินค้า
                    'f_withReq': _txtSearchDocument.text != ''
                        ? _txtSearchDocument.text
                        : "", // เอกสารขอเบิก
                    'f_isArrive': 1, // รูปแบบการจัดส่ง
                    'f_arriveDate': "" // วันที่ส่งของ
                  };

                  //  print(value);
                  insertWithdrawHead(value);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(187, 56, 27, 1),
                    foregroundColor: Colors.white),
                child: const Text('Confirm'),
              )),
        ),
      ],
    );
  }

  Expanded _buildWithdrawHistory() {
    return Expanded(
      child: ListView.builder(
        itemCount: getCountProductHistory(),
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
                          'รหัสสินค้า : ${_withdrawDetailHistory[index].f_prodID}',
                          style: TextStyle(
                              color: Colors.amber[900],
                              fontSize: Responsive.isMobile(context) ? 9 : 12),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.green,
                            child: Text(
                              '${_withdrawDetailHistory[index].f_withQty}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.isMobile(context) ? 9 : 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ชื่อสินค้า : ${_withdrawDetailHistory[index].f_prodName}',
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 9 : 10),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        // Container(
                        //   // color: Colors.red,
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.end,
                        //     children: [
                        //       SizedBox(
                        //         width: 5,
                        //       ),
                        //     ],
                        //   ),
                        // ),
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
    );
  }

  Expanded _buildWithdrawReq() {
    return Expanded(
      child: ListView.builder(
        itemCount: getCountProduct(),
        itemBuilder: (BuildContext context, int index) {
          return Card(
            elevation: 6,
            // margin: EdgeInsets.all(10),
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
                          'รหัสสินค้า : ${_withdrawReqDetail[index].f_prodID}',
                          // 'รหัสสินค้า : ${_withdrawReqDetail[index].f_prodID}',
                          style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 9 : 10,
                            color: Colors.red,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.green,
                            child: Text(
                              '${_withdrawReqDetail[index].QTY_Count}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ชื่อสินค้า : ${_withdrawReqDetail[index].f_prodName}',
                          style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 9 : 10,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        // Container(
                        //   // color: Colors.red,
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.end,
                        //     children: [
                        //       SizedBox(
                        //         width: 10,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ขอเบิก : ${_withdrawReqDetail[index].f_withReqQty}',
                          style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 9 : 10,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
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
    );
  }

  int getCountProduct() {
    int amount = 0;
    for (var _product in (_txtSearchDocument.text != ''
        ? _withdrawReqDetail
        : _productlist)) {
      // this._withdrawReqDetail.forEach((_product) {
      amount++;
    }

    return amount;
  }

  int getCountProductHistory() {
    int amount = 0;
    for (var _product in _withdrawDetailHistory) {
      amount++;
    }

    return amount;
  }

  Future<void> sumValue() async {
    SumValue = 0;
    SumCountValue = 0;

    for (int i = 0;
        i <
            (_txtSearchDocument.text != ''
                ? _withdrawReqDetail.length
                : _productlist.length);
        i++) {
      SumValue = SumValue +
          (_txtSearchDocument.text != ''
              ? _withdrawReqDetail[i].f_withReqQty
              : _productlist[i].QTY);
      SumCountValue = SumCountValue +
          (_txtSearchDocument.text != ''
              ? _withdrawReqDetail[i].QTY_Count
              : _productlist[i].QTY);
    }
  }

  Future<void> sumValueHistory() async {
    SumValue = 0;
    SumCountValue = 0;
    for (int i = 0; i < _withdrawDetailHistory.length; i++) {
      SumValue = SumValue + _withdrawDetailHistory[i].f_withQty;
    }
    SumCountValue = SumValue;
  }
}

class _Triangle extends StatelessWidget {
  const _Triangle({
    this.color = Colors.white,
  });
  final Color color;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _ShapesPainter(color),
        child: SizedBox(
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
