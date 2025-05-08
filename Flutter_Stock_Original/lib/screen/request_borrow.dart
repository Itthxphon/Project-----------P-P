import 'package:flutter/material.dart';

class RequestBorrow extends StatefulWidget {
  const RequestBorrow({Key? key}) : super(key: key);

  @override
  _RequestBorrowState createState() => _RequestBorrowState();
}

class _RequestBorrowState extends State<RequestBorrow> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text('Request Borrow'),
          backgroundColor: Colors.amber[900],
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      // borderRadius: BorderRadius.only(
                      //   bottomLeft: Radius.circular(30),
                      //   bottomRight: Radius.circular(30),
                      // ),
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
                      padding: EdgeInsets.all(20),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(30)),
                        child: TextField(
                          cursorColor: Colors.white,
                          maxLines: 1,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            suffixIcon: Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 25, horizontal: 10),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
        bottomNavigationBar: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.2,
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
            )
          ],
        ),
      ),
    );
  }
}
