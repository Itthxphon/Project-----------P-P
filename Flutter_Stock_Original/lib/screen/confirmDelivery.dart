// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';

import 'package:Nippostock/config/constant.dart';
import 'package:Nippostock/models/car.dart';
import 'package:Nippostock/models/jobwithdetail.dart';
import 'package:Nippostock/models/statusCheck.dart';
import 'package:Nippostock/models/view_DeliveryJob.dart';
import 'package:Nippostock/models/withdrawDetail.dart';
import 'package:Nippostock/models/withdrawHead.dart';
import 'package:Nippostock/widgets/custom_tab_bar.dart';
import 'package:Nippostock/widgets/responsive.dart';
import 'package:flutter/material.dart';
import 'package:Nippostock/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:convert' as convert;
import 'menu_drawer.dart';
import 'dart:math' as math;
import 'package:toggle_switch/toggle_switch.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ConfirmDeliveryPage extends StatefulWidget {
  ConfirmDeliveryPage({Key? key}) : super(key: key);

  @override
  _ConfirmDeliveryPage createState() => _ConfirmDeliveryPage();
}

class _ConfirmDeliveryPage extends State<ConfirmDeliveryPage> {
  @override
  void initState() {
    super.initState();
    getCar();
  }

  String _captionAppBar = 'Delivery Check ( จัดของขึ้นรถ )';
  var _captionAppBarColor = menuColorPink;
  bool _statusLeadingAppBar = true;

  int _selectedIndex = 0;
  final _txtBarcode = TextEditingController();
  int Count = 0;
  int SumValue = 0;
  List<Product> _productlist = [];
  List<WithDrawHead> _withdrawHead = [];
  List<WithDrawDetail> _withdrawDetail = [];

  ///////////////////////////////////////////
  List<View_DeliveryJob> _jobDelivery = [];
  List<View_DeliveryJob> _jobDeliverySuccess = [];
  List<JobDelivery_WithDetail> _jobDeliveryWithDetail = [];

  /////////////////////////////////////////////
  int productCount = 0;
  final GlobalKey<FormState> _formKey = GlobalKey();

  List<DropdownMenuItem<Car>> _dropdownMenuItems = [];
  Car? _selectedItem;

  List<DropdownMenuItem<WithDrawHead>> _dropdownMenuItemsHistory = [];
  WithDrawHead? _selectedItemHistory;
  bool _showButton = true;
  String withReq = "";

  bool _showIndicator = true;

  final _txtdocumentJobID = TextEditingController();
  final _txtdocumentJobDate = TextEditingController();
  final _txtdocumentWithdrawID = TextEditingController();
  final _txtwithWithdrawer = TextEditingController();
  final _txtRemark = TextEditingController();
  final _txtcarRegistration = TextEditingController();
  final _txtSearchdocumentJobID = TextEditingController();
  final _txtWareHouseName = TextEditingController();
  bool checkSuccess = false;

  final _txtSearchDateStart = TextEditingController();
  final _txtSearchDateEnd = TextEditingController();

  StatusCheck? _selected;
  StatusCheck? _selectedHistory;

  final List<IconData> _icons = [
    MdiIcons.fileDocument,
    MdiIcons.carEstate,
    Icons.beenhere,
  ];

  List<StatusCheck> statuscheck = <StatusCheck>[
    const StatusCheck(0, 'Waiting'),
    const StatusCheck(1, 'Success')
  ];

  List<StatusCheck> statuscheckHistory = <StatusCheck>[
    const StatusCheck(1, 'Success'),
  ];

  Future<void> getCar() async {
    String url = server + "/api/getCar";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(responce.body);
    List<Car> temp = (jsonResponce['data'] as List)
        .map((itemWord) => Car.fromJson(itemWord))
        .toList();

    _dropdownMenuItems = buildDropDownMenuItems(temp);
    if (_dropdownMenuItems.length > 0) {
      _selectedItem = _dropdownMenuItems[0].value as Car;
    }
  }

  List<DropdownMenuItem<Car>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<Car>> items = [];
    for (int i = 0; i <= listItems.length - 1; i++) {
      Car listItem = listItems[i];
      items.add(
        DropdownMenuItem(
          child: Text(listItem.F_carRegistration),
          value: listItem,
        ),
      );
    }
    return items;
  }

  // ค้นหาเอกสารจัดของขึ้นรถจากแว่นขยาย
  Future<void> getJobFromView_Delivery() async {
    String url = server + "/api/deliveryJob/";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    final jsonResponce = json.decode(responce.body);

    List<View_DeliveryJob> temp = (jsonResponce['data'] as List)
        .map((item) => View_DeliveryJob.fromJson(item))
        .toList();

    setState(() {
      // DateTime _dateStart;
      // DateTime _dateEnd;
      // _dateStart = DateTime.now().subtract(Duration(days: 45));
      // _dateEnd = DateTime.now();

      // _txtSearchDateStart.text =
      //     '${DateFormat('dd-MM-yyyy').format(_dateStart)}';
      // _txtSearchDateEnd.text = '${DateFormat('dd-MM-yyyy').format(_dateEnd)}';

      _selectedItem = _dropdownMenuItems[0].value as Car;
      _txtSearchdocumentJobID.clear();
      _jobDelivery.clear();
      _jobDelivery.addAll(temp);
      _selected = statuscheck[0];

      showAlertgetView_DeliveryTablet();
      //todo
      // Responsive.isMobile(context)
      //     ? showAlertgetWithdrawMobile()
      //     : showAlertgetWithdrawTablet();
    });
  }

  Future<void> getJobFromView_Delivery_Success45() async {
    String url = server + "/api/deliveryJob/getJobSuccess/";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
    final jsonResponce = json.decode(responce.body);

    List<View_DeliveryJob> temp = (jsonResponce['data'] as List)
        .map((item) => View_DeliveryJob.fromJson(item))
        .toList();

    setState(() {
      _selectedItem = _dropdownMenuItems[0].value as Car;
      DateTime _dateStart;
      DateTime _dateEnd;
      _dateStart = DateTime.now().subtract(Duration(days: 45));
      _dateEnd = DateTime.now();

      _txtSearchDateStart.text =
          '${DateFormat('dd-MM-yyyy').format(_dateStart)}';
      _txtSearchDateEnd.text = '${DateFormat('dd-MM-yyyy').format(_dateEnd)}';

      _txtSearchdocumentJobID.clear();
      _jobDeliverySuccess.clear();
      _jobDeliverySuccess.addAll(temp);
      _selected = statuscheck[0];

      // showAlertgetView_DeliveryTablet_Success(context);
    });
  }

  // get job success button Load Data
  Future<void> getJobFromView_Delivery_Success(
      Map<dynamic, dynamic> values) async {
    String url = server + "/api/deliveryJob/getDataJobDeliverySuccess/";
    final responce = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {
          'F_docJobDeliveryID': values['F_docJobDeliveryID'].toString(),
          'f_dateStart': values['f_dateStart'].toString(),
          'f_dateEnd': values['f_dateEnd'].toString(),
          'F_carID': values['F_carID'].toString()
        },
      ),
    );
    final jsonResponce = json.decode(responce.body);

    List<View_DeliveryJob> temp = (jsonResponce['data'] as List)
        .map((item) => View_DeliveryJob.fromJson(item))
        .toList();

    setState(() {
      DateTime _dateStart;
      DateTime _dateEnd;
      _dateStart = DateTime.now().subtract(Duration(days: 45));
      _dateEnd = DateTime.now();

      _txtSearchDateStart.text =
          '${DateFormat('dd-MM-yyyy').format(_dateStart)}';
      _txtSearchDateEnd.text = '${DateFormat('dd-MM-yyyy').format(_dateEnd)}';

      _txtSearchdocumentJobID.clear();
      _jobDeliverySuccess.clear();
      _jobDeliverySuccess.addAll(temp);
      _selected = statuscheck[0];

      //   Navigator.pop(context);
      showAlertgetView_DeliveryTablet_Success(context);
    });
  }

  //getHistorySuccess/:id
  Future<void> getJobWithDetailHistory(String id) async {
    String url = server + "/api/jobwithdetail//getHistorySuccess/${id}";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(responce.body);
    List<JobDelivery_WithDetail> temp = (jsonResponce['data'] as List)
        .map((item) => JobDelivery_WithDetail.fromJson(item))
        .toList();

    setState(() {
      if (temp.length > 0) {
        int Count = 0;
        for (int i = 0; i < temp.length; i++) {
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

        _jobDeliveryWithDetail.clear();
        _jobDeliveryWithDetail.addAll(temp);

        productCount = _jobDeliveryWithDetail.length;
        sumValue();
        _txtdocumentJobID.text = _jobDeliveryWithDetail[0].F_docJobDeliveryID;

        _txtdocumentJobDate.text =
            _jobDeliveryWithDetail[0].F_docDeliveryDate == null
                ? ''
                : DateFormat('dd-MM-yyyy HH:mm:ss').format(
                    DateTime.parse(_jobDeliveryWithDetail[0].F_docDeliveryDate),
                  );

        _txtdocumentWithdrawID.text = _jobDeliveryWithDetail[0].F_withID;
        _txtwithWithdrawer.text = _jobDeliveryWithDetail[0].f_withWithdrawer;
        _txtRemark.text = _jobDeliveryWithDetail[0].f_withRemark;
        _txtcarRegistration.text = _jobDeliveryWithDetail[0].F_carRegistration;
        _txtWareHouseName.text = _jobDeliveryWithDetail[0].f_wareName;
      }
    });
  }

  Future<void> getJobWithDetail(String id) async {
    String url = server + "/api/jobwithdetail/${id}";
    final responce = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(responce.body);
    List<JobDelivery_WithDetail> temp = (jsonResponce['data'] as List)
        .map((item) => JobDelivery_WithDetail.fromJson(item))
        .toList();

    setState(() {
      if (temp.length > 0) {
        int Count = 0;
        for (int i = 0; i < temp.length; i++) {
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

        _jobDeliveryWithDetail.clear();
        _jobDeliveryWithDetail.addAll(temp);

        productCount = _jobDeliveryWithDetail.length;
        sumValue();
        _txtdocumentJobID.text = _jobDeliveryWithDetail[0].F_docJobDeliveryID;

        _txtdocumentJobDate.text =
            _jobDeliveryWithDetail[0].F_docDeliveryDate == null
                ? ''
                : DateFormat('dd-MM-yyyy HH:mm:ss').format(
                    DateTime.parse(_jobDeliveryWithDetail[0].F_docDeliveryDate),
                  );

        _txtdocumentWithdrawID.text = _jobDeliveryWithDetail[0].F_withID;
        _txtwithWithdrawer.text = _jobDeliveryWithDetail[0].f_withWithdrawer;
        _txtRemark.text = _jobDeliveryWithDetail[0].f_withRemark;
        _txtcarRegistration.text = _jobDeliveryWithDetail[0].F_carRegistration;
        _txtWareHouseName.text = _jobDeliveryWithDetail[0].f_wareName;
      }
    });
  }

  Future<void> getJobFromView_DeliveryByID(
      String F_docJobDeliveryID, String F_carID) async {
    String url = server + "/api/deliveryJob/getbyID/";
    final responce = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {
          'F_docJobDeliveryID': F_docJobDeliveryID,
          'F_carID': F_carID,
        },
      ),
    );

    final jsonResponce = json.decode(responce.body);

    List<View_DeliveryJob> temp = (jsonResponce['data'] as List)
        .map((item) => View_DeliveryJob.fromJson(item))
        .toList();

    setState(() {
      _jobDelivery.clear();
      _jobDelivery.addAll(temp);
      _selected = statuscheck[0];
      Navigator.pop(context);
      showAlertgetView_DeliveryTablet();
    });
  }

  Future<void> updateDeliveryStep(String F_docJobDeliveryID) async {
    String url =
        server + "/api/deliveryJob/updateDeliveryStep/${F_docJobDeliveryID}";
    final responce = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: convert.jsonEncode(
        {
          'F_docJobDeliveryID': F_docJobDeliveryID,
        },
      ),
    );

    final jsonResponce = json.decode(responce.body);
  }

  // Load Data จากแว่นขยาย
  // Future<void> getWithDrawHistoryByID(Map<dynamic, dynamic> values) async {
  //   print(values);
  //   String url = server + "/api/withdraw/historyAllCheck/";
  //   final responce = await http.post(
  //     Uri.parse(url),
  //     headers: {"Content-Type": "application/json"},
  //     body: convert.jsonEncode(
  //       {
  //         'f_withID': values['f_withID'],
  //         'f_dateStart': values['f_dateStart'],
  //         'f_dateEnd': values['f_dateEnd'],
  //         'f_shippingCheck': values['f_shippingCheck']
  //       },
  //     ),
  //   );
  //   final jsonResponce = json.decode(responce.body);

  //   List<WithDrawHead> temp = (jsonResponce['data'] as List)
  //       .map((item) => WithDrawHead.fromJson(item))
  //       .toList();

  //   setState(() {
  //     _withdrawHead.clear();
  //     _withdrawHead.addAll(temp);
  //     Navigator.pop(context);
  //     Responsive.isMobile(context)
  //         ? showAlertgetWithdrawMobile()
  //         : showAlertgetView_DeliveryTablet();
  //   });
  // }

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
      showAlertgetWithdrawHistoryTablet();
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

      showAlertgetWithdrawHistoryTablet();
    });
  }

  _showStatusMobile(String _text) {
    String _content;
    if (_text == "1") {
      _content = "Success";
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

  _showStatusJobDelivery(int _text) {
    String _content;
    if (_text == 1) {
      _content = "Waiting";
    } else if (_text == 2) {
      _content = "Sending";
    } else {
      _content = "Success";
    }

    return Container(
      width: 80,
      height: 30,
      decoration: BoxDecoration(
        color: (() {
          if (_text == 1) {
            return Colors.cyan[400];
          } else if (_text == 2) {
            return Colors.orange;
          } else {
            return Colors.green;
          }
        }()),
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

  _showStatusTablet(String _text) {
    String _content;
    if (_text == "1") {
      _content = "Success";
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
                                'Delivery Check History ( ประวัติ เช็คของขึ้นรถ )',
                                style: TextStyle(
                                  color: menuColorPink,
                                ),
                              ),
                            ),
                            _Triangle(
                              color: menuColorPink,
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
                                color: menuColorPink,
                                margin: EdgeInsets.only(bottom: 5),
                                child: Center(
                                  child: Text(
                                    'เลขที่ JOB',
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
                                    controller: _txtSearchdocumentJobID,
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
                                        color: menuColorPink,
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: menuColorPink,
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
                                        color: menuColorPink,
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: menuColorPink,
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
                                    color: menuColorPink,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.only(left: 10),
                                margin: EdgeInsets.only(bottom: 5),
                                child: new DropdownButton<StatusCheck>(
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

                              // data = {
                              //   'f_withID':
                              //       _txtSearchDocument.text.toString() != ''
                              //           ? _txtSearchDocument.text.toString()
                              //           : '',
                              //   'f_dateStart': _dateStart,
                              //   'f_dateEnd': _dateEnd,
                              //   'f_shippingCheck': '1'
                              // };

                              // print(data);

                              if (data.length > 0) {
                                getWithDrawHistoryByIDAppbar(data);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: menuColorPink,
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
                                                'เลขที่เอกสารเช็คของ : ${_withdrawHead[index].f_withID}',
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
                                  color: menuColorPink,
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
  Future<void> showAlertgetView_DeliveryTablet() async {
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
                                ' JOB Delivery ( JOB ส่งของ )',
                                style: TextStyle(
                                  color: menuColorPink,
                                ),
                              ),
                            ),
                            _Triangle(
                              color: menuColorPink,
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
                                color: menuColorPink,
                                margin: EdgeInsets.only(bottom: 5),
                                child: Center(
                                  child: Text(
                                    'เลขที่ JOB',
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
                                    controller: _txtSearchdocumentJobID,
                                    decoration: InputDecoration(
                                      // labelText: 'ค้นหาเอกสาร',
                                      contentPadding: EdgeInsets.only(left: 10),
                                      labelStyle:
                                          TextStyle(fontSize: mediumText),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: menuColorPink,
                                          width: 2.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: menuColorPink,
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
                                width: 5,
                              ),
                              Container(
                                width: 110,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: menuColorPink,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.only(left: 10),
                                margin: EdgeInsets.only(bottom: 5),
                                child: new DropdownButton<Car>(
                                  underline: SizedBox.shrink(),
                                  style: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 9 : 16,
                                    fontFamily: 'Sarabun',
                                    color: Colors.black,
                                  ),
                                  isExpanded: true,
                                  value: _selectedItem,
                                  items: _dropdownMenuItems,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedItem = value;
                                    });
                                  },
                                ),
                              ),
                              // SizedBox(
                              //   width: 5,
                              // ),
                              // Container(
                              //   width: 110,
                              //   height: 40,
                              //   decoration: BoxDecoration(
                              //     border: Border.all(
                              //       color: menuColorPink,
                              //       width: 2,
                              //     ),
                              //     borderRadius: BorderRadius.circular(5),
                              //   ),
                              //   padding: EdgeInsets.only(left: 10),
                              //   margin: EdgeInsets.only(bottom: 5),
                              //   child: new DropdownButton<StatusCheck>(
                              //     underline: SizedBox.shrink(),
                              //     isExpanded: true,
                              //     value: _selected,
                              //     onChanged: (newValue) {
                              //       setState(() {
                              //         _selected = newValue;
                              //         // print(_selected!.id);
                              //       });
                              //     },
                              //     items: statuscheck.map(
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
                              getJobFromView_DeliveryByID(
                                _txtSearchdocumentJobID.text.toString(),
                                _selectedItem!.F_carID,
                              );
                              // var data = {};

                              // // data = {
                              // //   'f_withID':
                              // //       _txtSearchDocument.text.toString() != ''
                              // //           ? _txtSearchDocument.text.toString()
                              // //           : '',
                              // //   'f_dateStart': _dateStart,
                              // //   'f_dateEnd': _dateEnd,
                              // //   'f_shippingCheck': _selected!.id
                              // // };

                              // // ค้นหาจากแว่นขยาย
                              // if (data.length > 0) {
                              //   // todo

                              // }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: menuColorPink,
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
                          itemCount: _jobDelivery.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 6,
                              margin: EdgeInsets.all(10),
                              child: ListTile(
                                onTap: () {
                                  getJobWithDetail(
                                      _jobDelivery[index].F_docJobDeliveryID);

                                  checkSuccess = true;
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
                                                'เลขที่เอกสาร JOB : ${_jobDelivery[index].F_docJobDeliveryID}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'วันที่ส่งของ : ${_jobDelivery[index].F_deliveryDateSchdule == '' ? '' : DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(_jobDelivery[index].F_deliveryDateSchdule))}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'ทะเบียนรถ : ${_jobDelivery[index].F_carRegistration}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Container(
                                        child: Row(
                                          children: [
                                            _showStatusJobDelivery(
                                                _jobDelivery[index]
                                                    .F_deliveryStep),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Container(
                                              width: 80,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[400],
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Sending',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Container(
                                              width: 80,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[400],
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Success',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                leading: Icon(
                                  Icons.analytics_outlined,
                                  size: 60,
                                  color: menuColorPink,
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
                            '${_jobDelivery.length} Records.',
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

  Widget showAlertgetView_DeliveryTablet_Success(BuildContext context) {
    //  _txtSearchDocument.text = "";
    return Container(
      color: Colors.grey[200],
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(
                //     left: 20,
                //     top: 10,
                //   ),
                //   child: Row(
                //     children: [
                //       CircleAvatar(
                //         radius: 25,
                //         backgroundImage: AssetImage('images/POS.jpg'),
                //       ),
                //       SizedBox(
                //         width: 20,
                //       ),
                //       Expanded(
                //         flex: 4,
                //         child: Text(
                //           ' JOB Delivery History ( ประวัติ JOB ส่งของ  )',
                //           style: TextStyle(
                //             color: menuColorPink,
                //           ),
                //         ),
                //       ),
                //       _Triangle(
                //         color: menuColorPink,
                //       )
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    // height: MediaQuery.of(context).size.height * 0.10,
                    // width: MediaQuery.of(context).size.width - 60,
                    height: MediaQuery.of(context).size.height * 0.10,
                    width: MediaQuery.of(context).size.width,
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
                              color: Colors.orange,
                              margin: EdgeInsets.only(bottom: 5),
                              child: Center(
                                child: Text(
                                  'เลขที่ JOB',
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
                                  controller: _txtSearchdocumentJobID,
                                  decoration: InputDecoration(
                                    // labelText: 'ค้นหาเอกสาร',
                                    contentPadding: EdgeInsets.only(left: 10),
                                    labelStyle: TextStyle(fontSize: mediumText),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Colors.orange,
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: Colors.orange,
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
                              width: 20,
                            ),
                            Container(
                              width: 110,
                              height: 40,
                              margin: EdgeInsets.only(bottom: 5),
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
                                      color: Colors.orange,
                                      width: 2.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.orange,
                                      width: 2.0,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.red, width: 1),
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
                                      color: Colors.orange,
                                      width: 2.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.orange,
                                      width: 2.0,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.red, width: 1),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Container(
                              width: 110,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.only(left: 10),
                              margin: EdgeInsets.only(bottom: 5),
                              child: new DropdownButton<Car>(
                                underline: SizedBox.shrink(),
                                style: TextStyle(
                                  fontSize:
                                      Responsive.isMobile(context) ? 9 : 16,
                                  fontFamily: 'Sarabun',
                                  color: Colors.black,
                                ),
                                isExpanded: true,
                                value: _selectedItem,
                                items: _dropdownMenuItems,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedItem = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            // getJobFromView_DeliveryByID(
                            //   _txtSearchdocumentJobID.text.toString(),
                            //   _selectedItem!.F_carID,
                            // );
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
                              'F_docJobDeliveryID':
                                  _txtSearchdocumentJobID.text.toString() != ''
                                      ? _txtSearchdocumentJobID.text.toString()
                                      : '',
                              'f_dateStart': _dateStart,
                              'f_dateEnd': _dateEnd,
                              'F_carID': _selectedItem!.F_carID.toString()
                            };

                            // ค้นหาจากแว่นขยาย
                            if (data.length > 0) {
                              getJobFromView_Delivery_Success(data);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orange,
                            ),
                            width: MediaQuery.of(context).size.width,
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
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    //      width: MediaQuery.of(context).size.width - 60,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.7,
                    color: Colors.white,
                    child: ListView.builder(
                      itemCount: _jobDeliverySuccess.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          elevation: 6,
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            onTap: () {
                              getJobWithDetailHistory(_jobDeliverySuccess[index]
                                  .F_docJobDeliveryID);

                              checkSuccess = true;
                              setState(() {
                                _selectedIndex = 0;

                                _statusLeadingAppBar = true;
                                _captionAppBar =
                                    'Delivery Check ( จัดของขึ้นรถ )';
                                _captionAppBarColor = Colors.cyan;
                              });
                              // Navigator.pop(context);
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
                                            'เลขที่เอกสาร JOB : ${_jobDeliverySuccess[index].F_docJobDeliveryID}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            'วันที่ส่งของ : ${_jobDeliverySuccess[index].F_deliveryDateSchdule == '' ? '' : DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(_jobDeliverySuccess[index].F_deliveryDateSchdule))}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            'ทะเบียนรถ : ${_jobDeliverySuccess[index].F_carRegistration}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  _showStatusJobDelivery(
                                      _jobDeliverySuccess[index]
                                          .F_deliveryStep),
                                ],
                              ),
                            ),
                            leading: Icon(
                              Icons.analytics_outlined,
                              size: 60,
                              color: Colors.orange,
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
                      height: 50,
                      child: Text(
                        '${_jobDeliverySuccess.length} Records.',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
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
                  // _txtdocumentID.clear();
                  // _txtdocumentDate.clear();
                  // _txtdocumentRef.clear();
                  // _txtdocumentRefDate.clear();
                  // _txtuserWithdraw.clear();
                  // _txtRemark.clear();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Future<void> getWithdrawDetail(String id) async {
  //   String url = server + "/api/withdrawdetail/'${id}'";
  //   final response = await http
  //       .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

  //   final jsonResponce = json.decode(response.body);
  //   // print(jsonResponce['data']);

  //   List<WithDrawDetail> temp = (jsonResponce['data'] as List)
  //       .map((itemWord) => WithDrawDetail.fromJson(itemWord))
  //       .toList();

  //   setState(() {
  //     int Count = 0;
  //     for (int i = 0; i < temp.length; i++) {
  //       // print(' i = ${temp[i].f_Confirm.toString()} ');
  //       if (temp[i].f_Confirm == Null) {
  //         temp[i].checked = false;
  //       } else if (temp[i].f_Confirm == 1) {
  //         temp[i].checked = true;
  //         Count++;
  //       }
  //     }
  //     if (Count == temp.length) {
  //       checkSuccess = false;
  //     } else {
  //       checkSuccess = true;
  //     }

  //     _withdrawDetail.addAll(temp);
  //     sumValue();

  //     if (_withdrawDetail.length > 0) {
  //       productCount = _withdrawDetail.length;
  //     }
  //   });
  // }

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

  @override
  Widget build(BuildContext context) {
    // FocusNode myFocusNode = new FocusNode();
    // int count = 0;
    // String dropdownValue = 'One';

    final List<Widget> _screen = [
      _buildTablet(context),
      showAlertgetView_DeliveryTablet_Success(context),
      Scaffold(
        body: Center(
          child: Text('Success'),
        ),
      ),
    ];

    return DefaultTabController(
      length: _icons.length,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          drawer: new Drawer(
            child: MenuDrawer(),
          ),
          appBar: AppBar(
            //toolbarHeight: 50,
            automaticallyImplyLeading: _statusLeadingAppBar,

            iconTheme: IconThemeData(
                color: _captionAppBarColor,
                size: Responsive.isMobile(context) ? 20 : 24),
            title: Text(
              _captionAppBar,
              style: TextStyle(
                color: _captionAppBarColor,
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
                      builder: (BuildContext context) => ConfirmDeliveryPage(),
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
                  // getJobFromView_Delivery_Success45();
                },
                icon: Icon(
                  Icons.description_sharp,
                  size: Responsive.isMobile(context) ? 20 : 24,
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: _screen,
          ),
          bottomNavigationBar: _customTabBar(_icons),
        ),
      ),
    );
  }

  CustomTabBar _customTabBar(List<IconData> _icons) {
    return CustomTabBar(
      icons: _icons,
      selectedIndex: _selectedIndex,
      countStatus: [10, 10, 10],
      onTab: (index) => setState(() {
        _selectedIndex = index;
        if (index == 0) {
          _statusLeadingAppBar = true;
          _captionAppBar = 'Delivery Check ( จัดของขึ้นรถ )';
          _captionAppBarColor = Colors.cyan;
        } else if (index == 1) {
          _statusLeadingAppBar = false;
          _captionAppBar = 'Sending ( กำลังจัดส่ง )';
          _captionAppBarColor = Colors.orange;
          getJobFromView_Delivery_Success45();
        } else if (index == 2) {
          _statusLeadingAppBar = false;
          _captionAppBar = 'Success ( จัดส่งสำเร็จ )';
          _captionAppBarColor = Colors.green;
        }
        ;
      }),
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
                        color: menuColorPink,
                        child: Center(
                          child: Text(
                            'เลขที่ JOB',
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
                        child: TextFormField(
                          style: TextStyle(
                            color: menuColorPink,
                            fontSize: 14,
                          ),
                          readOnly: true,
                          controller: _txtdocumentJobID,
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
                      Container(
                        width: 50,
                        height: 40,
                        decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(10),
                            color: menuColorPink),
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              //todo
                              //getWithdrawAll(0);
                              getJobFromView_Delivery();
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
                        color: menuColorPink,
                        child: Center(
                          child: Text(
                            'วันที่สร้าง JOB ',
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
                          controller: _txtdocumentJobDate,
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
                        color: Color.fromRGBO(187, 56, 27, 1),
                        child: Center(
                          child: Text(
                            'เลขที่เอกสารใบเบิก',
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
                          style: TextStyle(
                            color: Color.fromRGBO(187, 56, 27, 1),
                          ),
                          readOnly: true,
                          controller: _txtdocumentWithdrawID,
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
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: menuColorPink,
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
                          controller: _txtwithWithdrawer,
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
                        color: menuColorPink,
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
                      Container(
                        width: MediaQuery.of(context).size.width * 0.28,
                        height: 40,
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          readOnly: true,
                          controller: _txtWareHouseName,
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
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.15,
                        color: menuColorPink,
                        child: Center(
                          child: Text(
                            'ทะเบียนรถยนต์',
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
                          controller: _txtcarRegistration,
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
                        color: menuColorPink,
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
          color: menuColorPink,
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
                                'รหัสสินค้า : ${_jobDeliveryWithDetail[vindex].f_prodID}',
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
                                  '${_jobDeliveryWithDetail[vindex].f_withQty}',
                                  'NO'
                                ],
                                initialLabelIndex:
                                    _jobDeliveryWithDetail[vindex].checked ==
                                            true
                                        ? 0
                                        : 1,
                                icons: [null, null],
                                onToggle: (index) {
                                  index == 0
                                      ? _jobDeliveryWithDetail[vindex].checked =
                                          true
                                      : _jobDeliveryWithDetail[vindex].checked =
                                          false;

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
                                'ชื่อสินค้า : ${_jobDeliveryWithDetail[vindex].f_prodName}',
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
        Container(
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
                for (int i = 0; i < _jobDeliveryWithDetail.length; i++) {
                  data = {
                    'f_withID': _txtdocumentWithdrawID.text.toString(),
                    'f_prodID': _jobDeliveryWithDetail[i].f_prodID.toString(),
                    'f_Confirm':
                        _jobDeliveryWithDetail[i].checked == true ? '1' : '0'
                  };
                  _confirmWithDraw(data);

                  if (_jobDeliveryWithDetail[i].checked == true) {
                    count++;
                  }
                } // end for

                if (count == _jobDeliveryWithDetail.length) {
                  var dataUpdateShip = {};
                  dataUpdateShip.clear();

                  dataUpdateShip = {
                    'f_withID': _txtdocumentWithdrawID.text.toString(),
                    'f_shippingCheck': "1"
                  };

                  _updateShipSuccess(dataUpdateShip);

                  // update delivery Step
                  updateDeliveryStep(_txtdocumentJobID.text.toString());

                  _onAlertButtonPressed(context);
                } else {
                  // _showDialog();
                  _onAlertButtonPressed(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: menuColorPink,
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
          onPressed: () => Navigator.pop(context),
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
    this._jobDeliveryWithDetail.forEach((_product) {
      amount++;
    });

    return amount;
  }

  Future<void> sumValue() async {
    SumValue = 0;
    for (int i = 0; i < _jobDeliveryWithDetail.length; i++) {
      SumValue = SumValue + _jobDeliveryWithDetail[i].f_withQty;
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
