import 'package:Nippostock/config/constant.dart';
import 'package:Nippostock/models/user.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class PageGetUser extends StatefulWidget {
  PageGetUser({Key? key}) : super(key: key);

  @override
  _PageGetUserState createState() => _PageGetUserState();
}

class _PageGetUserState extends State<PageGetUser> {
  List<User> _user = [];

  final _txtBarcode = TextEditingController();
  int Count = 0;
  int SumValue = 0;

  Future<void> getUser(int id) async {
    String url = server + "/api/users/'${id}'";
    final response = await http
        .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

    final jsonResponce = json.decode(response.body);
    print(jsonResponce['data']);

    List<User> temp = (jsonResponce['data'] as List)
        .map((itemWord) => User.fromJson(itemWord))
        .toList();

    setState(() {
      _user.addAll(temp);
      _txtBarcode.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    FocusNode myFocusNode = new FocusNode();
    int count = 0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.amber[900],
          ),
          title: Text(
            'Get_User',
            style: TextStyle(color: Colors.amber[900]),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.1,
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
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 20),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(30)),
                      child: TextField(
                        controller: _txtBarcode,
                        cursorColor: Colors.amber[900],
                        maxLines: 1,
                        style: TextStyle(color: Colors.amber[900]),
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
                          suffixIcon: IconButton(
                            onPressed: () =>
                                getUser(int.parse(_txtBarcode.text)),
                            icon: Icon(
                              Icons.qr_code_scanner,
                              color: Colors.amber[900],
                            ),
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
              height: 15,
            ),
            Expanded(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _user[index].f_fullname,
                                    style: TextStyle(
                                        color: Colors.amber[900], fontSize: 12),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        // print('remove');
                                        // productlist.remove(index);
                                        // setState(() {
                                        //   _setData(index);
                                        // });
                                      },
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.amber[900],
                                        size: 15,
                                      ))
                                ],
                              ),
                              _setData(index)
                            ],
                          ),
                        ),
                        leading: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              color: Colors.amber[100],
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 15,
                                  color: Colors.grey.withOpacity(0.1),
                                  offset: Offset(0, 3),
                                )
                              ]),
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
            ),
          ],
        ),
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.15,
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
                      flex: 4,
                      child: Text(
                        'Total ${Count} pcs.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Total ${SumValue}.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          var xx = json.encode(_user);
                          print(xx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[900],
                        ),
                        child: Text('Confirm'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int getCountProduct() {
    int amount = 0;
    this._user.forEach((_product) {
      amount++;
    });

    return amount;
  }

  Widget _setData(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _user[index].f_username,
          style: TextStyle(fontSize: 10),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          _user[index].f_password,
          style: TextStyle(fontSize: 10),
        ),
        SizedBox(
          height: 10,
        ),
        // Text(
        //   '${_user[index].f_userStatus}',
        //   style: TextStyle(fontSize: 10),
        // ),
        // SizedBox(
        //   height: 10,
        // ),
        // Text(
        //   '${_user[index].f_userID}',
        //   style: TextStyle(fontSize: 10),
        // ),
      ],
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('title'),
//       ),
//       body: FutureBuilder<User>(
//         future: getUser(2),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return const Center(
//               child: Text('An error has occurred!'),
//             );
//           } else if (snapshot.hasData) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//             ;
//           } else {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
