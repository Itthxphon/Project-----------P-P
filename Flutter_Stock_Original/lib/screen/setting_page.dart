import 'package:Nippostock/config/constant.dart';
import 'package:Nippostock/printer/printersetting.dart';
import 'package:Nippostock/screen/stock.dart';
import 'package:flutter/material.dart';

import 'menu_drawer.dart';
import 'menu_setting.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _menu = MenuSettingType.PROFILE;

  _getLayoutSetting() {
    if (_menu == MenuSettingType.PROFILE) return StockPage();
    //if (_menu == MenuSettingType.RECEIPT) return StockPage();
    //if (_menu == MenuSettingType.SALES) return StockPage();
    if (_menu == MenuSettingType.PRINTER) return PrinterSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        child: Row(
          children: <Widget>[
            // menu ฝั่งซ้่ายมีการเรียกใช้ไฟล์ menu_Setting
            Expanded(
                flex: 2,
                child: Scaffold(
                  backgroundColor: kPrimaryColor,
                  appBar: AppBar(
                    title: Text(
                      "ตั้งค่า",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  drawer: new Drawer(
                    child: MenuDrawer(),
                  ),
                  body: MenuSettingWidget(
                    activeMenu: _menu,
                    onTap: (text) {
                      if (mounted) {
                        setState(() {
                          _menu = text;
                        });
                      }
                    },
                  ),
                )),

            // Container ฝั่งขวา
            Expanded(
              flex: 4,
              child: Material(
                child: Container(
                  margin: EdgeInsets.only(left: 2),
                  color: kBackgroundColor,
                  child: _getLayoutSetting(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // _appBar() {
  //   return BaseAppBar(
  //     title: Text("ตั้งค่า", style: TextStyle(color: Colors.white)),
  //     appBar: AppBar(),
  //   );
  // }
}
