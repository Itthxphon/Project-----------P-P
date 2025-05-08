import 'package:Nippostock/config/constant.dart';

import 'package:Nippostock/screen/menu_drawer.dart';

import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key, required this.username}) : super(key: key);
  final String username;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: new Drawer(
          child: MenuDrawer(),
        ),
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: Text('Main Menu'),
        ),
        body: Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/POS.jpg'),
                // image: AssetImage('images/logo_connect.png'),
                colorFilter: new ColorFilter.mode(
                    Colors.white.withOpacity(0.4), BlendMode.dstATop),
                fit: BoxFit.fill,
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // body: SingleChildScrollView(
        //   child: Column(
        //     children: [
        //       // Stack(
        //       //   children: [
        //       //     Container(
        //       //       width: MediaQuery.of(context).size.width,
        //       //       height: MediaQuery.of(context).size.height * 0.2,
        //       //       decoration: BoxDecoration(
        //       //         color: Colors.amber[900],
        //       //         borderRadius: BorderRadius.only(
        //       //           bottomLeft: Radius.circular(30),
        //       //           bottomRight: Radius.circular(30),
        //       //         ),
        //       //         boxShadow: [
        //       //           BoxShadow(
        //       //             color: Colors.grey.withOpacity(0.5),
        //       //             spreadRadius: 5,
        //       //             blurRadius: 15,
        //       //             offset: Offset(0, 3), // changes position of shadow
        //       //           ),
        //       //         ],
        //       //       ),
        //       //       child: Padding(
        //       //         padding: EdgeInsets.only(
        //       //             top: 20, left: 50, right: 50, bottom: 20),
        //       //         child: Row(
        //       //           mainAxisAlignment: MainAxisAlignment.center,
        //       //           children: [
        //       //             CircleAvatar(
        //       //               radius: 40.0,
        //       //               backgroundColor: Colors.white,
        //       //               child: CircleAvatar(
        //       //                 radius: 35.0,
        //       //                 backgroundColor: Colors.grey[200],
        //       //                 backgroundImage: AssetImage('images/POS.png'),
        //       //               ),
        //       //             ),
        //       //             SizedBox(
        //       //               width: 20,
        //       //             ),
        //       //             Column(
        //       //               mainAxisAlignment: MainAxisAlignment.center,
        //       //               children: [
        //       //                 Text(
        //       //                   "Hello ${username} ",
        //       //                   style: TextStyle(
        //       //                       color: Colors.white, fontSize: 20),
        //       //                 ),
        //       //                 Text(
        //       //                   "Welcome back !",
        //       //                   style: TextStyle(
        //       //                       color: Colors.white, fontSize: 20),
        //       //                 )
        //       //               ],
        //       //             ),
        //       //           ],
        //       //         ),
        //       //       ),
        //       //     )
        //       //   ],
        //       // ),
        //       SizedBox(
        //         height: 30,
        //       ),
        //       Column(
        //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //         children: [
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               Container(
        //                 width: MediaQuery.of(context).size.width * 0.4,
        //                 height: 250,
        //                 decoration: BoxDecoration(
        //                   borderRadius: BorderRadius.circular(25),
        //                 ),
        //                 child: Column(
        //                   mainAxisAlignment: MainAxisAlignment.center,
        //                   children: [
        //                     GestureDetector(
        //                       onTap: () {
        //                         Navigator.push(
        //                           context,
        //                           MaterialPageRoute(
        //                             builder: (context) => ReceivePage(),
        //                           ),
        //                         );
        //                       },
        //                       child: Container(
        //                         margin: EdgeInsets.only(
        //                             top: 10, left: 10, right: 10),
        //                         width: MediaQuery.of(context).size.width * 0.4,
        //                         height: 150,
        //                         decoration: BoxDecoration(
        //                           borderRadius: BorderRadius.only(
        //                             topLeft: Radius.circular(20),
        //                             topRight: Radius.circular(20),
        //                           ),
        //                           color: Colors.green[100],
        //                         ),
        //                         child: CircleAvatar(
        //                           radius: 40.0,
        //                           backgroundColor: Colors.green[100],
        //                           child: Image.asset(
        //                             'images/receive.png',
        //                             fit: BoxFit.cover,
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                     // Container(
        //                     //   margin: EdgeInsets.all(20.0),
        //                     //   width: 130,
        //                     //   height: 130,
        //                     //   decoration: BoxDecoration(
        //                     //     color: Colors.amber[50],
        //                     //     shape: BoxShape.circle,
        //                     //     boxShadow: [
        //                     //       BoxShadow(
        //                     //         color: Colors.grey.withOpacity(0.2),
        //                     //         spreadRadius: 5,
        //                     //         blurRadius: 15,
        //                     //         offset: Offset(0, 3),
        //                     //       )
        //                     //     ],
        //                     //   ),
        //                     //   child: GestureDetector(
        //                     //     onTap: () {
        //                     //       Navigator.push(
        //                     //         context,
        //                     //         MaterialPageRoute(
        //                     //           builder: (context) => ReceivePage(),
        //                     //         ),
        //                     //       );
        //                     //     },
        //                     //     child: CircleAvatar(
        //                     //       radius: 40.0,
        //                     //       backgroundColor: Colors.white,
        //                     //       child: Image.asset(
        //                     //         'images/receive.png',
        //                     //         fit: BoxFit.cover,
        //                     //       ),
        //                     //     ),
        //                     //   ),
        //                     // ),
        //                     Container(
        //                       margin: EdgeInsets.only(
        //                           left: 10, right: 10, bottom: 2),
        //                       width: MediaQuery.of(context).size.width * 0.4,
        //                       height: 50,
        //                       decoration: BoxDecoration(
        //                         borderRadius: BorderRadius.only(
        //                           bottomLeft: Radius.circular(10),
        //                           bottomRight: Radius.circular(10),
        //                         ),
        //                         color: Colors.green[50],
        //                       ),
        //                       child: Center(
        //                         child: Text(
        //                           'รับเข้า',
        //                           style: TextStyle(
        //                               fontSize: 20.0, color: Colors.black),
        //                         ),
        //                       ),
        //                     )
        //                   ],
        //                 ),
        //               ),
        //               SizedBox(
        //                 width: 30,
        //               ),
        //               Container(
        //                 width: MediaQuery.of(context).size.width * 0.4,
        //                 height: 250,
        //                 decoration: BoxDecoration(
        //                   borderRadius: BorderRadius.circular(25),
        //                 ),
        //                 child: Column(
        //                   mainAxisAlignment: MainAxisAlignment.center,
        //                   children: [
        //                     GestureDetector(
        //                       onTap: () {
        //                         Navigator.push(
        //                           context,
        //                           MaterialPageRoute(
        //                             builder: (context) => WithdrawPage(),
        //                           ),
        //                         );
        //                       },
        //                       child: Container(
        //                         margin: EdgeInsets.only(
        //                             top: 10, left: 10, right: 10),
        //                         width: MediaQuery.of(context).size.width * 0.4,
        //                         height: 150,
        //                         decoration: BoxDecoration(
        //                           borderRadius: BorderRadius.only(
        //                             topLeft: Radius.circular(20),
        //                             topRight: Radius.circular(20),
        //                           ),
        //                           color: Colors.amber[100],
        //                         ),
        //                         child: CircleAvatar(
        //                           radius: 40.0,
        //                           backgroundColor: Colors.amber[100],
        //                           child: Image.asset(
        //                             'images/withdraw.png',
        //                             fit: BoxFit.cover,
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                     Container(
        //                       margin: EdgeInsets.only(
        //                           left: 10, right: 10, bottom: 2),
        //                       width: MediaQuery.of(context).size.width * 0.4,
        //                       height: 50,
        //                       decoration: BoxDecoration(
        //                         borderRadius: BorderRadius.only(
        //                           bottomLeft: Radius.circular(10),
        //                           bottomRight: Radius.circular(10),
        //                         ),
        //                         color: Colors.amber[50],
        //                       ),
        //                       child: Center(
        //                         child: Text(
        //                           'เบิกออก',
        //                           style: TextStyle(
        //                               fontSize: 20.0, color: Colors.black),
        //                         ),
        //                       ),
        //                     )
        //                   ],
        //                 ),
        //               ),
        //               // Container(
        //               //   width: MediaQuery.of(context).size.width * 0.4,
        //               //   height: 250,
        //               //   decoration: BoxDecoration(
        //               //     color: Colors.orange[50],
        //               //     borderRadius: BorderRadius.circular(25),
        //               //   ),
        //               //   child: Column(
        //               //     mainAxisAlignment: MainAxisAlignment.center,
        //               //     children: [
        //               //       Container(
        //               //         margin: EdgeInsets.all(20.0),
        //               //         width: 70,
        //               //         height: 70,
        //               //         decoration: BoxDecoration(
        //               //             color: Colors.amber[50],
        //               //             shape: BoxShape.circle,
        //               //             boxShadow: [
        //               //               BoxShadow(
        //               //                 color: Colors.grey.withOpacity(0.2),
        //               //                 spreadRadius: 5,
        //               //                 blurRadius: 15,
        //               //                 offset: Offset(0, 3),
        //               //               )
        //               //             ]),
        //               //         child: GestureDetector(
        //               //           onTap: () {
        //               //             Navigator.push(
        //               //                 context,
        //               //                 MaterialPageRoute(
        //               //                     builder: (context) => WithdrawPage()));
        //               //           },
        //               //           child: CircleAvatar(
        //               //             radius: 40.0,
        //               //             backgroundColor: Colors.white,
        //               //             child: Image.asset(
        //               //               'images/withdraw.png',
        //               //               fit: BoxFit.cover,
        //               //             ),
        //               //           ),
        //               //         ),
        //               //       ),
        //               //       Text('เบิกออก')
        //               //     ],
        //               //   ),
        //               // ),
        //             ],
        //           ),
        //           // SizedBox(
        //           //   height: 30,
        //           // ),
        //           // Row(
        //           //   mainAxisAlignment: MainAxisAlignment.center,
        //           //   children: [
        //           //     Container(
        //           //       width: MediaQuery.of(context).size.width * 0.4,
        //           //       height: 150,
        //           //       decoration: BoxDecoration(
        //           //         color: Colors.purple[50],
        //           //         borderRadius: BorderRadius.circular(25),
        //           //       ),
        //           //       child: Column(
        //           //         children: [
        //           //           Container(
        //           //             margin: EdgeInsets.all(20.0),
        //           //             width: 70,
        //           //             height: 70,
        //           //             decoration: BoxDecoration(
        //           //                 color: Colors.amber[50],
        //           //                 shape: BoxShape.circle,
        //           //                 boxShadow: [
        //           //                   BoxShadow(
        //           //                     color: Colors.grey.withOpacity(0.2),
        //           //                     spreadRadius: 5,
        //           //                     blurRadius: 15,
        //           //                     offset: Offset(0, 3),
        //           //                   )
        //           //                 ]),
        //           //             child: GestureDetector(
        //           //               onTap: () {
        //           //                 Navigator.push(
        //           //                   context,
        //           //                   MaterialPageRoute(
        //           //                     builder: (context) => RequestBorrow(),
        //           //                   ),
        //           //                 );
        //           //               },
        //           //               child: CircleAvatar(
        //           //                 radius: 40.0,
        //           //                 backgroundColor: Colors.white,
        //           //                 child: Image.asset(
        //           //                   'images/borrow.png',
        //           //                   fit: BoxFit.contain,
        //           //                   height: 45,
        //           //                 ),
        //           //               ),
        //           //             ),
        //           //           ),
        //           //           Text('ขอยืม')
        //           //         ],
        //           //       ),
        //           //     ),
        //           //     SizedBox(
        //           //       width: 30,
        //           //     ),
        //           //     Container(
        //           //       width: MediaQuery.of(context).size.width * 0.4,
        //           //       height: 150,
        //           //       decoration: BoxDecoration(
        //           //         color: Colors.pink[50],
        //           //         borderRadius: BorderRadius.circular(25),
        //           //       ),
        //           //       child: Column(
        //           //         children: [
        //           //           Container(
        //           //             margin: EdgeInsets.all(20.0),
        //           //             width: 70,
        //           //             height: 70,
        //           //             decoration: BoxDecoration(
        //           //                 color: Colors.amber[50],
        //           //                 shape: BoxShape.circle,
        //           //                 boxShadow: [
        //           //                   BoxShadow(
        //           //                     color: Colors.grey.withOpacity(0.2),
        //           //                     spreadRadius: 5,
        //           //                     blurRadius: 15,
        //           //                     offset: Offset(0, 3),
        //           //                   )
        //           //                 ]),
        //           //             child: GestureDetector(
        //           //               onTap: () {
        //           //                 Navigator.push(
        //           //                     context,
        //           //                     MaterialPageRoute(
        //           //                         builder: (context) => RequestBorrow()));
        //           //               },
        //           //               child: CircleAvatar(
        //           //                 radius: 40.0,
        //           //                 backgroundColor: Colors.white,
        //           //                 child: Image.asset(
        //           //                   'images/requestborrow.png',
        //           //                   fit: BoxFit.fill,
        //           //                   height: 45,
        //           //                 ),
        //           //               ),
        //           //             ),
        //           //           ),
        //           //           Text('ขอเบิก')
        //           //         ],
        //           //       ),
        //           //     ),
        //           //   ],
        //           // ),
        //           SizedBox(
        //             height: 30,
        //           ),
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               Container(
        //                 width: MediaQuery.of(context).size.width * 0.4,
        //                 height: 250,
        //                 decoration: BoxDecoration(
        //                   borderRadius: BorderRadius.circular(25),
        //                 ),
        //                 child: Column(
        //                   mainAxisAlignment: MainAxisAlignment.center,
        //                   children: [
        //                     GestureDetector(
        //                       onTap: () {
        //                         Navigator.push(
        //                           context,
        //                           MaterialPageRoute(
        //                             builder: (context) => ConfirmWithdrawPage(),
        //                           ),
        //                         );
        //                       },
        //                       child: Container(
        //                         margin: EdgeInsets.only(
        //                             top: 10, left: 10, right: 10),
        //                         width: MediaQuery.of(context).size.width * 0.4,
        //                         height: 150,
        //                         decoration: BoxDecoration(
        //                           borderRadius: BorderRadius.only(
        //                             topLeft: Radius.circular(20),
        //                             topRight: Radius.circular(20),
        //                           ),
        //                           color: Colors.cyan[100],
        //                         ),
        //                         child: CircleAvatar(
        //                           radius: 40.0,
        //                           backgroundColor: Colors.cyan[100],
        //                           child: Image.asset(
        //                             'images/adjust.png',
        //                             fit: BoxFit.cover,
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                     Container(
        //                       margin: EdgeInsets.only(
        //                           left: 10, right: 10, bottom: 2),
        //                       width: MediaQuery.of(context).size.width * 0.4,
        //                       height: 50,
        //                       decoration: BoxDecoration(
        //                         borderRadius: BorderRadius.only(
        //                           bottomLeft: Radius.circular(10),
        //                           bottomRight: Radius.circular(10),
        //                         ),
        //                         color: Colors.cyan[50],
        //                       ),
        //                       child: Center(
        //                         child: Text(
        //                           'Confirm เบิกออก',
        //                           style: TextStyle(
        //                               fontSize: 20.0, color: Colors.black),
        //                         ),
        //                       ),
        //                     )
        //                   ],
        //                 ),
        //               ),
        //               SizedBox(
        //                 width: 30,
        //               ),
        //               Container(
        //                 width: MediaQuery.of(context).size.width * 0.4,
        //                 height: 250,
        //                 decoration: BoxDecoration(
        //                   borderRadius: BorderRadius.circular(25),
        //                 ),
        //                 child: Column(
        //                   mainAxisAlignment: MainAxisAlignment.center,
        //                   children: [
        //                     GestureDetector(
        //                       onTap: () {
        //                         Navigator.push(
        //                           context,
        //                           MaterialPageRoute(
        //                             builder: (context) => StockPage(),
        //                           ),
        //                         );
        //                       },
        //                       child: Container(
        //                         margin: EdgeInsets.only(
        //                             top: 10, left: 10, right: 10),
        //                         width: MediaQuery.of(context).size.width * 0.4,
        //                         height: 150,
        //                         decoration: BoxDecoration(
        //                           borderRadius: BorderRadius.only(
        //                             topLeft: Radius.circular(20),
        //                             topRight: Radius.circular(20),
        //                           ),
        //                           color: Colors.blue[100],
        //                         ),
        //                         child: CircleAvatar(
        //                           radius: 40.0,
        //                           backgroundColor: Colors.blue[100],
        //                           child: Image.asset(
        //                             'images/stock.png',
        //                             fit: BoxFit.cover,
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                     Container(
        //                       margin: EdgeInsets.only(
        //                           left: 10, right: 10, bottom: 2),
        //                       width: MediaQuery.of(context).size.width * 0.4,
        //                       height: 50,
        //                       decoration: BoxDecoration(
        //                         borderRadius: BorderRadius.only(
        //                           bottomLeft: Radius.circular(10),
        //                           bottomRight: Radius.circular(10),
        //                         ),
        //                         color: Colors.blue[50],
        //                       ),
        //                       child: Center(
        //                         child: Text(
        //                           'สต็อคคงเหลือ',
        //                           style: TextStyle(
        //                               fontSize: 20.0, color: Colors.black),
        //                         ),
        //                       ),
        //                     )
        //                   ],
        //                 ),
        //               ),
        //             ],
        //           ),
        //           // Row(
        //           //   mainAxisAlignment: MainAxisAlignment.start,
        //           //   children: [
        //           //     // Container(
        //           //     //   width: MediaQuery.of(context).size.width * 0.4,
        //           //     //   height: 250,
        //           //     //   decoration: BoxDecoration(
        //           //     //     color: Colors.amber[100],
        //           //     //     borderRadius: BorderRadius.circular(25),
        //           //     //   ),
        //           //     //   child: Column(
        //           //     //     mainAxisAlignment: MainAxisAlignment.center,
        //           //     //     children: [
        //           //     //       Container(
        //           //     //         margin: EdgeInsets.all(20.0),
        //           //     //         width: 70,
        //           //     //         height: 70,
        //           //     //         decoration: BoxDecoration(
        //           //     //             color: Colors.amber[50],
        //           //     //             shape: BoxShape.circle,
        //           //     //             boxShadow: [
        //           //     //               BoxShadow(
        //           //     //                 color: Colors.grey.withOpacity(0.2),
        //           //     //                 spreadRadius: 5,
        //           //     //                 blurRadius: 15,
        //           //     //                 offset: Offset(0, 3),
        //           //     //               )
        //           //     //             ]),
        //           //     //         child: GestureDetector(
        //           //     //           onTap: () {
        //           //     //             Navigator.push(
        //           //     //               context,
        //           //     //               MaterialPageRoute(
        //           //     //                 builder: (context) => ReceivePageTest(),
        //           //     //               ),
        //           //     //             );
        //           //     //             // Navigator.push(
        //           //     //             //   context,
        //           //     //             //   MaterialPageRoute(
        //           //     //             //     builder: (context) => PageGetUser(),
        //           //     //             //   ),
        //           //     //             // );
        //           //     //           },
        //           //     //           child: CircleAvatar(
        //           //     //             radius: 40.0,
        //           //     //             backgroundColor: Colors.white,
        //           //     //             child: Image.asset(
        //           //     //               'images/adjust.png',
        //           //     //               fit: BoxFit.contain,
        //           //     //               height: 45,
        //           //     //             ),
        //           //     //           ),
        //           //     //         ),
        //           //     //       ),
        //           //     //       Text('ปรับสต็อค')
        //           //     //     ],
        //           //     //   ),
        //           //     // ),
        //           //     SizedBox(
        //           //       width: 30,
        //           //     ),
        //           //     // Container(
        //           //     //   width: MediaQuery.of(context).size.width * 0.4,
        //           //     //   height: 250,
        //           //     //   decoration: BoxDecoration(
        //           //     //     color: Colors.cyan[50],
        //           //     //     borderRadius: BorderRadius.circular(25),
        //           //     //   ),
        //           //     //   child: Column(
        //           //     //     mainAxisAlignment: MainAxisAlignment.center,
        //           //     //     children: [
        //           //     //       Container(
        //           //     //         margin: EdgeInsets.all(20.0),
        //           //     //         width: 70,
        //           //     //         height: 70,
        //           //     //         decoration: BoxDecoration(
        //           //     //             color: Colors.amber[50],
        //           //     //             shape: BoxShape.circle,
        //           //     //             boxShadow: [
        //           //     //               BoxShadow(
        //           //     //                 color: Colors.grey.withOpacity(0.2),
        //           //     //                 spreadRadius: 5,
        //           //     //                 blurRadius: 15,
        //           //     //                 offset: Offset(0, 3),
        //           //     //               )
        //           //     //             ]),
        //           //     //         child: CircleAvatar(
        //           //     //           radius: 40.0,
        //           //     //           backgroundColor: Colors.white,
        //           //     //           child: Image.asset(
        //           //     //             'images/stock.png',
        //           //     //             fit: BoxFit.contain,
        //           //     //             height: 45,
        //           //     //           ),
        //           //     //         ),
        //           //     //       ),
        //           //     //       Text('จำนวนคงเหลือ')
        //           //     //     ],
        //           //     //   ),
        //           //     // ),
        //           //   ],
        //           // ),
        //           SizedBox(
        //             height: 30,
        //           ),
        //         ],
        //       )
        //     ],
        //   ),
        // ),
        // bottomNavigationBar: Container(
        //   width: MediaQuery.of(context).size.width,
        //   height: MediaQuery.of(context).size.height * 0.08,
        //   decoration: BoxDecoration(
        //     color: Colors.amber[900],
        //     boxShadow: [
        //       BoxShadow(
        //           color: Colors.grey.withOpacity(0.1),
        //           blurRadius: 15,
        //           spreadRadius: 5,
        //           offset: Offset(0, 3)),
        //     ],
        //     borderRadius: BorderRadius.only(
        //       topLeft: Radius.circular(20),
        //       topRight: Radius.circular(20),
        //     ),
        //   ),
        //   child: Center(
        //     child: Text(
        //       'Stock Online',
        //       style: TextStyle(
        //         color: Colors.white,
        //         fontSize: 25,
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
