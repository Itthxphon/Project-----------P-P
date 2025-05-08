// import 'dart:convert';
//
// import 'package:Nippostock/config/constant.dart';
// import 'package:Nippostock/models/inventory.dart';
// import 'package:Nippostock/models/supplier.dart';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:Nippostock/models/product.dart';
// import 'package:http/http.dart' as http;
//
// import 'package:intl/intl.dart';
// import 'dart:convert' as convert;
//
// class ReceivePageTest extends StatefulWidget {
//   ReceivePageTest({Key? key}) : super(key: key);
//
//   @override
//   _ReceivePageTestState createState() => _ReceivePageTestState();
// }
//
// class _ReceivePageTestState extends State<ReceivePageTest> {
//   @override
//   void initState() {
//     super.initState();
//
//     getReceiveID();
//     getSupplier();
//     getInventory();
//   }
//
//   final _txtBarcode = TextEditingController();
//   int Count = 0;
//   int SumValue = 0;
//   List<Product> _productlist = [];
//
//   final GlobalKey<FormState> _formKey = GlobalKey();
//   dynamic inventory = 0;
//
//   final _txtdocumentID = TextEditingController();
//   final _txtdocumentDate = TextEditingController();
//   final _txtdocumentRef = TextEditingController();
//   final _txtdocumentRefDate = TextEditingController();
//   final _txtuserReceive = TextEditingController();
//   final _txtRemark = TextEditingController();
//
//   List<Product> count = [];
//
//   List<DropdownMenuItem<Inventory>> _dropdownMenuItems = [];
//   Inventory? _selectedItem;
//
//   List<DropdownMenuItem<Supplier>> _dropdownMenuItemSupplier = [];
//   Supplier? _selectSupplier;
//
//   List<DropdownMenuItem<Inventory>> buildDropDownMenuItems(List listItems) {
//     List<DropdownMenuItem<Inventory>> items = [];
//     for (int i = 0; i <= listItems.length - 1; i++) {
//       Inventory listItem = listItems[i];
//       items.add(
//         DropdownMenuItem(
//           child: Text(listItem.f_wareName),
//           value: listItem,
//         ),
//       );
//     }
//     return items;
//   }
//
//   List<DropdownMenuItem<Supplier>> buildDropDownSupplier(List listItems) {
//     List<DropdownMenuItem<Supplier>> items = [];
//     for (int i = 0; i <= listItems.length - 1; i++) {
//       Supplier listItem = listItems[i];
//       items.add(
//         DropdownMenuItem(
//           child: SizedBox(
//             child: Text(
//               listItem.f_supName,
//             ),
//           ),
//           value: listItem,
//         ),
//       );
//     }
//     return items;
//   }
//
//   Future<void> getSupplier() async {
//     String url = server + "/api/supplier";
//     final responce = await http
//         .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
//
//     final jsonResponce = json.decode(responce.body);
//     List<Supplier> temp = (jsonResponce['data'] as List)
//         .map((item) => Supplier.fromJson(item))
//         .toList();
//
//     _dropdownMenuItemSupplier = buildDropDownSupplier(temp);
//     _selectSupplier = _dropdownMenuItemSupplier[0].value as Supplier;
//   }
//
//   Future<void> getInventory() async {
//     String url = server + "/api/inventory";
//     final responce = await http
//         .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
//
//     // final Map<String, dynamic> inventory = convert.jsonDecode(responce.body);
//     // _inventory = inventory['data'];
//
//     // print(_inventory);
//
//     // _dropdownMenuItems = buildDropDownMenuItems(_inventory);
//     // _selectedItem = _dropdownMenuItems[0].value as Inventory;
//
//     // setState(() {
//     //   _inventory.addAll(inventory['data']);
//     // });
//
//     final jsonResponce = json.decode(responce.body);
//     List<Inventory> temp = (jsonResponce['data'] as List)
//         .map((itemWord) => Inventory.fromJson(itemWord))
//         .toList();
//
//     _dropdownMenuItems = buildDropDownMenuItems(temp);
//     _selectedItem = _dropdownMenuItems[0].value as Inventory;
//   }
//
//   Future<void> insertReceiveDetail(Map<dynamic, dynamic> values) async {
//     print(values);
//     String url = server + "/api/receivedetail";
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {"Content-Type": "application/json"},
//       body: convert.jsonEncode(
//         {
//           'f_recvID': values['f_recvID'],
//           'f_prodID': values['f_prodID'],
//           'f_recvQty': values['f_recvQty'],
//           'f_recvCost': values['f_recvCost'],
//         },
//       ),
//     );
//
//     if (response.statusCode == 200) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: new Text("Alert!!"),
//             content: new Text("Save success!"),
//             actions: <Widget>[
//               new TextButton(
//                 child: new Text("OK"),
//                 onPressed: () {
//                   // setState(() {
//                   //   _productlist.clear();
//                   // });
//                   Navigator.of(context).pop();
//
//                   // Navigator.pushReplacement(
//                   //   context,
//                   //   MaterialPageRoute(
//                   //     builder: (BuildContext context) => ReceivePage(),
//                   //   ),
//                   // );
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//     ;
//   }
//
//   Future<void> insertReceiveHead(Map<String, dynamic> values) async {
//     print(values);
//     String url = server + "/api/receive";
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {"Content-Type": "application/json"},
//       body: convert.jsonEncode(
//         {
//           'f_recvID': values['f_recvID'],
//           'f_recvdate': values['f_recvdate'],
//           'f_recvRemark': values['f_recvRemark'],
//           'f_recvStatus': values['f_recvStatus'],
//           'f_recvReceiver': values['f_recvReceiver'],
//           'f_recvReferance': values['f_recvReferance'],
//           'f_recvReferanceDate': values['f_recvReferanceDate'],
//           'f_wareID': values['f_wareID'],
//           'f_supID': values['f_supID']
//         },
//       ),
//     );
//
//     //if (response.statusCode == 200) {
//     // final jsonResponce = json.decode(response.body);
//     // print(jsonResponce);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: new Text("Alert!!"),
//           content: new Text("Save success!"),
//           actions: <Widget>[
//             new ElevatedButton(
//               child: new Text("OK"),
//               onPressed: () {
//                 setState(() {
//                   _txtdocumentID.clear();
//                   _txtdocumentDate.clear();
//                   _txtdocumentRef.clear();
//                   _txtdocumentRefDate.clear();
//                   _txtuserReceive.clear();
//                   _txtRemark.clear();
//                 });
//
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (BuildContext context) => ReceivePageTest(),
//                   ),
//                 );
//                 //  Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//     //}
//     //;
//   }
//
//   Future<void> getReceiveID() async {
//     String url = server + "/api/receive/";
//     final responce = await http
//         .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
//
//     final jsonResponce = json.decode(responce.body);
//     var temp = jsonResponce['data'];
//
//     Map<String, dynamic> ID = temp[0];
//
//     String documentID = ID.values.first;
//     String RR = "RR";
//     String year = (DateTime.now().year).toString();
//
//     int month = DateTime.now().month;
//     var _formatmonth = NumberFormat('00', 'en-Us');
//     String _monthString = _formatmonth.format(month);
//
//     int number = int.parse((documentID.substring(8, 13)));
//     number = number + 1;
//     var _formatnumber = NumberFormat('00000', 'en_Us');
//     String _numberString = _formatnumber.format(number);
//
//     String _documentID = RR + year + _monthString + _numberString;
//
//     setState(() {
//       _txtdocumentID.text = _documentID;
//
//       DateTime now = DateTime.now();
//       _txtdocumentDate.text =
//           '${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}';
//     });
//   }
//
//   Future<void> getProduct(String id) async {
//     String encodedId = Uri.encodeComponent(id);
//     String url = server + "/api/product/'$encodedId'";
//     final response = await http
//         .get(Uri.parse(url), headers: {"Content-Type": "application/json"});
//
//     final jsonResponce = json.decode(response.body);
//     // print(jsonResponce['data']);
//
//     List<Product> temp = (jsonResponce['data'] as List)
//         .map((itemWord) => Product.fromJson(itemWord))
//         .toList();
//
//     int product = _productlist.indexWhere((element) => element.f_prodID == id);
//
//     if (product != -1) {
//       _productlist[product].f_count = _productlist[product].f_count + 1;
//       setState(
//         () {
//           _txtBarcode.clear();
//           sumValue();
//         },
//       );
//     } else {
//       setState(
//         () {
//           _productlist.addAll(temp);
//           _txtBarcode.clear();
//           sumValue();
//         },
//       );
//     }
//   }
//
//   Future<void> sumValue() async {
//     SumValue = 0;
//     for (int i = 0; i < _productlist.length; i++) {
//       SumValue = SumValue + _productlist[i].f_count;
//     }
//   }
//
//   Future<void> scanBarcodeNormal() async {
//     String barcodeScanRes;
//
//     try {
//       barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
//           '#ff6666', 'Cancel', true, ScanMode.BARCODE);
//
//       getProduct(barcodeScanRes);
//     } on PlatformException {
//       barcodeScanRes = 'Failed to get platform version.';
//     }
//     if (!mounted) return;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.grey[200],
//         appBar: AppBar(
//           iconTheme: IconThemeData(
//             color: Colors.green,
//           ),
//           title: Text(
//             'Receive',
//             style: TextStyle(
//               color: Colors.green,
//             ),
//           ),
//           backgroundColor: Colors.white,
//           elevation: 0,
//           actions: [
//             IconButton(
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (BuildContext context) => ReceivePageTest(),
//                   ),
//                 );
//               },
//               icon: Icon(Icons.addchart),
//             ),
//             SizedBox(
//               width: 10,
//             ),
//             IconButton(
//               onPressed: () {},
//               icon: Icon(Icons.description_sharp),
//             ),
//           ],
//         ),
//         body: ListView(
//           //mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Container(
//               padding:
//                   EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
//               width: MediaQuery.of(context).size.width,
//               //height: MediaQuery.of(context).size.height * 0.13,
//               height: MediaQuery.of(context).size.height * 0.2,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 10, right: 10),
//                   child: Column(
//                     children: [
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             height: 40,
//                             width: 120,
//                             color: Colors.green,
//                             child: Center(
//                               child: Text(
//                                 'เลขที่เอกสาร',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 1,
//                           ),
//                           Container(
//                             width: 230,
//                             // height: 40,
//                             color: Colors.black,
//                             margin: EdgeInsets.only(bottom: 5),
//                             child: TextFormField(
//                               readOnly: true,
//                               style: TextStyle(
//                                   color: Colors.yellow,
//                                   backgroundColor: Colors.black),
//                               controller: _txtdocumentID,
//                               decoration: InputDecoration(
//                                 // labelText: 'เลขที่เอกสาร',
//                                 // labelStyle: TextStyle(
//                                 //   fontSize: mediumText,
//                                 // ),
//                                 border: OutlineInputBorder(),
//                                 errorBorder: OutlineInputBorder(
//                                   borderSide:
//                                       BorderSide(color: Colors.red, width: 5),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 10,
//                           ),
//                           Container(
//                             height: 40,
//                             width: 120,
//                             color: Colors.green,
//                             child: Center(
//                               child: Text(
//                                 'วันที่บันทึก',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 1,
//                           ),
//                           Container(
//                             width: 230,
//                             height: 40,
//                             color: Colors.black,
//                             margin: EdgeInsets.only(bottom: 5),
//                             child: TextFormField(
//                               style: TextStyle(
//                                   color: Colors.yellow,
//                                   backgroundColor: Colors.black),
//                               readOnly: true,
//                               onTap: () async {
//                                 await showDatePicker(
//                                   context: context,
//                                   initialDate: DateTime.now(),
//                                   firstDate: DateTime(2015),
//                                   lastDate: DateTime(2025),
//                                 ).then((selectedDate) {
//                                   if (selectedDate != null) {
//                                     // DateTime now = DateTime.now();
//                                     // _txtdocumentDate.text =
//                                     //     '${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}';
//
//                                   }
//                                 });
//                                 // FocusScope.of(context)
//                                 //     .requestFocus(new FocusNode());
//                               },
//                               controller: _txtdocumentDate,
//                               decoration: InputDecoration(
//                                 // labelText: 'วันที่บันทึก',
//                                 labelStyle: TextStyle(fontSize: mediumText),
//                                 border: OutlineInputBorder(),
//                                 errorBorder: OutlineInputBorder(
//                                   borderSide:
//                                       BorderSide(color: Colors.red, width: 5),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 10,
//                           ),
//                         ],
//                       ),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             height: 40,
//                             width: 120,
//                             color: Colors.green,
//                             child: Center(
//                               child: Text(
//                                 'เอกสารอ้างอิง',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 1,
//                           ),
//                           Container(
//                             width: 230,
//                             height: 40,
//                             color: Colors.white,
//                             margin: EdgeInsets.only(bottom: 5),
//                             child: TextFormField(
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   // showMessageAlert(
//                                   //     "Alert ", "Please insert document ref !");
//                                 }
//                                 return null;
//                               },
//                               controller: _txtdocumentRef,
//                               decoration: InputDecoration(
//                                 // labelText: 'เอกสารอ้างอิง',
//                                 labelStyle: TextStyle(fontSize: mediumText),
//                                 border: OutlineInputBorder(),
//                                 errorBorder: OutlineInputBorder(
//                                   borderSide:
//                                       BorderSide(color: Colors.red, width: 5),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 10,
//                           ),
//                           Container(
//                             height: 40,
//                             width: 120,
//                             color: Colors.green,
//                             child: Center(
//                               child: Text(
//                                 'วันที่เอกสารอ้างอิง',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 1,
//                           ),
//                           Container(
//                             width: 230,
//                             height: 40,
//                             // margin: EdgeInsets.only(bottom: 10),
//                             margin: EdgeInsets.only(bottom: 5),
//                             color: Colors.white,
//                             // margin: EdgeInsets.only(bottom: 5),
//                             child: TextFormField(
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'please insert data';
//                                   // showMessageAlert(
//                                   //     "Alert ", "Please insert Date Ref !");
//
//                                 }
//                                 return null;
//                               },
//                               readOnly: true,
//                               onTap: () async {
//                                 await showDatePicker(
//                                   context: context,
//                                   initialDate: DateTime.now(),
//                                   firstDate: DateTime(2021),
//                                   lastDate: DateTime(2031),
//                                 ).then(
//                                   (selectedDate) {
//                                     if (selectedDate != null) {
//                                       _txtdocumentRefDate.text =
//                                           '${DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate)}';
//                                     }
//                                   },
//                                 );
//                               },
//                               controller: _txtdocumentRefDate,
//                               decoration: InputDecoration(
//                                 // labelText: 'วันที่เอกสารอ้างอิง',
//                                 // constraints: BoxConstraints.expand(),
//                                 // contentPadding:
//                                 //     EdgeInsets.symmetric(vertical: 12),
//                                 labelStyle: TextStyle(fontSize: mediumText),
//                                 border: OutlineInputBorder(),
//                                 errorBorder: OutlineInputBorder(
//                                   borderSide:
//                                       BorderSide(color: Colors.red, width: 1),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             height: 40,
//                             width: 120,
//                             color: Colors.green,
//                             child: Center(
//                               child: Text(
//                                 'คลังสินค้า',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 1,
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(5.0),
//                               ),
//                               border: Border.all(
//                                 color: Colors.grey,
//                                 width: 1,
//                               ),
//                               color: Colors.white,
//                             ),
//                             width: 230,
//                             height: 40,
//                             margin: EdgeInsets.only(bottom: 5),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<Inventory>(
//                                 isExpanded: true,
//                                 value: _selectedItem,
//                                 items: _dropdownMenuItems,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _selectedItem = value;
//                                   });
//                                 },
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 10,
//                           ),
//                           Container(
//                             height: 40,
//                             width: 120,
//                             color: Colors.green,
//                             child: Center(
//                               child: Text(
//                                 'ผู้ผลิต/ผู้ขาย',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 1,
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(5.0),
//                               ),
//                               border: Border.all(
//                                 color: Colors.grey,
//                                 width: 1,
//                               ),
//                               color: Colors.white,
//                             ),
//                             width: 230,
//                             height: 40,
//                             margin: EdgeInsets.only(bottom: 5),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<Supplier>(
//                                 isExpanded: true,
//                                 value: _selectSupplier,
//                                 items: _dropdownMenuItemSupplier,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _selectSupplier = value;
//                                   });
//                                 },
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             height: 40,
//                             width: 120,
//                             color: Colors.green,
//                             child: Center(
//                               child: Text(
//                                 'ผู้รับเข้าสินค้า',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 1,
//                           ),
//                           Container(
//                             width: 230,
//                             height: 40,
//                             color: Colors.white,
//                             margin: EdgeInsets.only(bottom: 5),
//                             child: TextFormField(
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   // showMessageAlert("Alert ",
//                                   //     "Please insert user receiver !");
//                                 }
//                                 return null;
//                               },
//                               controller: _txtuserReceive,
//                               decoration: InputDecoration(
//                                 //labelText: 'ผู้รับเข้าสินค้า',
//                                 labelStyle: TextStyle(fontSize: mediumText),
//                                 border: OutlineInputBorder(),
//                                 errorBorder: OutlineInputBorder(
//                                   borderSide:
//                                       BorderSide(color: Colors.red, width: 5),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 10,
//                           ),
//                           Container(
//                             height: 40,
//                             width: 120,
//                             color: Colors.green,
//                             child: Center(
//                               child: Text(
//                                 'หมายเหตุ',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 1,
//                           ),
//                           Container(
//                             width: 230,
//                             height: 40,
//                             color: Colors.white,
//                             margin: EdgeInsets.only(bottom: 5),
//                             child: TextFormField(
//                               controller: _txtRemark,
//                               decoration: InputDecoration(
//                                 //labelText: 'หมายเหตุ',
//                                 labelStyle: TextStyle(fontSize: mediumText),
//                                 border: OutlineInputBorder(),
//                                 errorBorder: OutlineInputBorder(
//                                   borderSide:
//                                       BorderSide(color: Colors.red, width: 5),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               width: MediaQuery.of(context).size.width,
//               height: 20,
//               color: Colors.green,
//             ),
//             Stack(
//               children: [
//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.height * 0.08,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(30),
//                       bottomRight: Radius.circular(30),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 5,
//                         blurRadius: 15,
//                         offset: Offset(0, 3), // changes position of shadow
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.only(
//                         left: 20, right: 20, top: 10, bottom: 20),
//                     child: Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                           color: Colors.grey[200],
//                           borderRadius: BorderRadius.circular(30)),
//                       child: TextField(
//                         // readOnly: true,
//
//                         controller: _txtBarcode,
//                         cursorColor: Colors.amber[900],
//                         maxLines: 1,
//                         style: TextStyle(color: Colors.amber[900]),
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                   width: 1, color: Colors.transparent)),
//                           disabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                   width: 1, color: Colors.transparent)),
//                           enabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                   width: 1, color: Colors.transparent)),
//                           errorBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                   width: 1, color: Colors.transparent)),
//                           focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                   width: 1, color: Colors.transparent)),
//                           focusedErrorBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                   width: 1, color: Colors.transparent)),
//                           suffixIcon: IconButton(
//                             //onPressed: () => scanBarcodeNormal(),
//                             onPressed: () => scanBarcodeNormal(),
//                             icon: Icon(
//                               Icons.qr_code_scanner,
//                               color: Colors.amber[900],
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(
//                               vertical: 25, horizontal: 10),
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             SizedBox(
//               height: 15,
//             ),
//             Expanded(
//               child: Container(
//                 child: ListView.builder(
//                   itemCount: getCountProduct(),
//                   itemBuilder: (BuildContext context, int index) {
//                     return Card(
//                       elevation: 6,
//                       margin: EdgeInsets.all(10),
//                       child: ListTile(
//                         onTap: () {},
//                         title: Padding(
//                           padding: const EdgeInsets.only(left: 8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     _productlist[index].f_prodID,
//                                     style: TextStyle(
//                                         color: Colors.amber[900], fontSize: 12),
//                                   ),
//                                   IconButton(
//                                       onPressed: () {
//                                         // print('remove');
//                                         _productlist.remove(index);
//                                         setState(() {
//                                           print(_productlist);
//                                         });
//                                       },
//                                       icon: Icon(
//                                         Icons.close,
//                                         color: Colors.amber[900],
//                                         size: 15,
//                                       ))
//                                 ],
//                               ),
//                               Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     '${_productlist[index].f_prodName}',
//                                     style: TextStyle(fontSize: 10),
//                                   ),
//                                   SizedBox(
//                                     height: 30,
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   Container(
//                                     // color: Colors.red,
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         CircleAvatar(
//                                           radius: 15,
//                                           backgroundColor: Colors.red,
//                                           child: IconButton(
//                                             onPressed: () {
//                                               setState(
//                                                 () {
//                                                   // print("--");
//
//                                                   if (_productlist[index]
//                                                           .f_count ==
//                                                       0) {
//                                                     _productlist[index]
//                                                         .f_count = 0;
//                                                   } else {
//                                                     _productlist[index]
//                                                             .f_count =
//                                                         _productlist[index]
//                                                                 .f_count -
//                                                             1;
//                                                   }
//
//                                                   sumValue();
//                                                 },
//                                               );
//                                             },
//                                             icon: Icon(Icons.remove),
//                                             color: Colors.white,
//                                             alignment: Alignment.center,
//                                             iconSize: 15,
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 10,
//                                         ),
//                                         Text(
//                                           '${_productlist[index].f_count}',
//                                           style: TextStyle(
//                                               color: Colors.amber[900],
//                                               fontSize: 12),
//                                         ),
//                                         SizedBox(
//                                           width: 10,
//                                         ),
//                                         CircleAvatar(
//                                           radius: 15,
//                                           backgroundColor: Colors.green,
//                                           child: IconButton(
//                                             onPressed: () {
//                                               setState(
//                                                 () {
//                                                   // print("++");
//                                                   _productlist[index].f_count =
//                                                       _productlist[index]
//                                                               .f_count +
//                                                           1;
//
//                                                   sumValue();
//                                                 },
//                                               );
//                                             },
//                                             icon: Icon(Icons.add),
//                                             color: Colors.white,
//                                             alignment: Alignment.center,
//                                             iconSize: 15,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   )
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                         leading: Container(
//                           width: 100,
//                           height: 100,
//                           decoration: BoxDecoration(
//                               color: Colors.amber[100],
//                               boxShadow: [
//                                 BoxShadow(
//                                   blurRadius: 15,
//                                   color: Colors.grey.withOpacity(0.1),
//                                   offset: Offset(0, 3),
//                                 )
//                               ]),
//                         ),
//                         // trailing: Icon(
//                         //   Icons.close,
//                         //   color: Colors.amber[900],
//                         // ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//         bottomNavigationBar: Container(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height * 0.15,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   blurRadius: 15,
//                   spreadRadius: 5,
//                   offset: Offset(0, 3)),
//             ],
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: EdgeInsets.only(left: 20, top: 10),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       flex: 4,
//                       child: Text(
//                         'Total ${_productlist.length} list.',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Text(
//                         'Total  ${SumValue}  pcs.',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     flex: 1,
//                     child: Padding(
//                       padding: EdgeInsets.only(
//                           left: 20, right: 20, top: 10, bottom: 10),
//                       child: ElevatedButton(
//                         onPressed: () {
//                           if (_formKey.currentState!.validate()) {
//                             var value = {
//                               'f_recvID': _txtdocumentID.text.toString(),
//                               'f_recvdate': _txtdocumentDate.text.toString(),
//                               'f_recvRemark': _txtRemark.text.toString(),
//                               'f_recvStatus': 1,
//                               'f_recvReceiver': _txtuserReceive.text.toString(),
//                               'f_recvReferance':
//                                   _txtdocumentRef.text.toString(),
//                               'f_recvReferanceDate':
//                                   _txtdocumentRefDate.text.toString(),
//                               'f_wareID': _selectedItem!.f_wareID,
//                               'f_supID': _selectSupplier!.f_supID
//                             };
//
//                             insertReceiveHead(value);
//                             ///////// insert detail /////////////////////
//
//                             for (int i = 0; i < _productlist.length; i++) {
//                               // print(i);
//                               var product = {};
//                               product.clear();
//
//                               product = {
//                                 'f_recvID': _txtdocumentID.text.toString(),
//                                 'f_prodID': _productlist[i].f_prodID,
//                                 'f_recvQty': _productlist[i].f_count,
//                                 'f_recvCost': _productlist[i].f_costprice
//                               };
//                               insertReceiveDetail(product);
//                             }
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                         ),
//                         child: Text('Confirm'),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   int getCountProduct() {
//     int amount = 0;
//     this._productlist.forEach((_product) {
//       amount++;
//     });
//
//     return amount;
//   }
//
//   Future<void> showMessageAlert(String title, String content) async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: new Text(title),
//           content: new Text(content),
//           actions: <Widget>[
//             new TextButton(
//               child: new Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
