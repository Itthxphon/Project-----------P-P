import 'package:Nippostock/models/withdrawDetail.dart';
import 'package:Nippostock/models/withdrawHead.dart';
import 'package:Nippostock/widgets/responsive.dart';
import 'package:flutter/material.dart';
import 'menu_drawer.dart';

class ConfirmSendingPage extends StatefulWidget {
  const ConfirmSendingPage({Key? key}) : super(key: key);

  @override
  _ConfirmSendingPageState createState() => _ConfirmSendingPageState();
}

class _ConfirmSendingPageState extends State<ConfirmSendingPage> {
  List<WithDrawHead> _withdrawHeadHistory = [];
  List<WithDrawDetail> _withdrawDetailHistory = [];

  Future<void> getJobShipping() async {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        drawer: new Drawer(
          child: MenuDrawer(),
        ),
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: Colors.purple,
              size: Responsive.isMobile(context) ? 20 : 24),
          title: Text(
            'Delivery Finish ( ปิดงาน )',
            style: TextStyle(
              color: Colors.purple,
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
                    builder: (BuildContext context) => ConfirmSendingPage(),
                  ),
                );
              },
              icon: Icon(
                Icons.addchart,
                color: Colors.purple,
                size: Responsive.isMobile(context) ? 20 : 24,
              ),
            ),
            SizedBox(
              width: Responsive.isMobile(context) ? 1 : 10,
            ),
            IconButton(
              onPressed: () {
                // _txtSearchDocument.text = '';
                // getWithdrawAll(1);
                //   getWithDrawHByShipSuccess();
              },
              icon: Icon(
                Icons.description_sharp,
                size: Responsive.isMobile(context) ? 20 : 24,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                  itemCount: 10,
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Text(
                                  //   'รหัสสินค้า : ${_withdrawDetail[vindex].f_prodID}',
                                  //   style: TextStyle(
                                  //       color: Colors.amber[900], fontSize: 12),
                                  // ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ชื่อสินค้า : ',
                                    //'ชื่อสินค้า : ${_withdrawDetail[vindex].f_prodName}',
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
        ),
        //  Responsive.isMobile(context)
        //         ? _buildMobile(context)
        //         : _buildTablet(context),
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.05,
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
                        '',
                        //  'Total ${productCount != 0 ? productCount : 0} list.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Total',
                        //'Total ${SumValue != 0 ? SumValue : 0} pcs.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
              // checkSuccess ? _buildButtonSave() : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
