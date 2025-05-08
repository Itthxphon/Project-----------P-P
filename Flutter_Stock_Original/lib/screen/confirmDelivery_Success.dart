import 'package:Nippostock/screen/menu_drawer.dart';
import 'package:Nippostock/widgets/responsive.dart';
import 'package:flutter/material.dart';

class ConfirmDeliverySuccessPage extends StatefulWidget {
  const ConfirmDeliverySuccessPage({Key? key}) : super(key: key);

  @override
  _ConfirmDeliverySuccessPageState createState() =>
      _ConfirmDeliverySuccessPageState();
}

class _ConfirmDeliverySuccessPageState
    extends State<ConfirmDeliverySuccessPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: new Drawer(
          child: MenuDrawer(),
        ),
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: Colors.purple,
              size: Responsive.isMobile(context) ? 20 : 24),
          title: Text(
            'Confirm Send ( ยืนยันจัดส่ง )',
            style: TextStyle(color: Colors.purple),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 9,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: Colors.green,
                      width: 200,
                      height: 70,
                      child: Text('$index'),
                    );
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  color: Colors.purple,
                  width: MediaQuery.of(context).size.width - 40,
                  height: MediaQuery.of(context).size.height * 0.2,
                )
              ],
            )),
      ),
    );
  }
}
