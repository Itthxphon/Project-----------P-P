import 'package:Nippostock/config/constant.dart';
import 'package:Nippostock/screen/confirmDelivery.dart';
import 'package:Nippostock/screen/confirmSending.dart';
import 'package:Nippostock/screen/confirmWithdraw.dart';
import 'package:Nippostock/screen/login.dart';
import 'package:Nippostock/screen/mainmenu.dart';
import 'package:Nippostock/screen/receive.dart';

import 'package:Nippostock/screen/stock.dart';
import 'package:Nippostock/screen/withdraw.dart';
import 'package:Nippostock/screen/withdrawReq.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MenuDrawer extends StatefulWidget {
  final String menu;
  final bool offline;

  MenuDrawer({Key? key, this.menu = "", this.offline = false})
      : super(key: key);

  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  String? _name = "";
  String? _fullname = "";

  void initState() {
    super.initState();
    getDataPref();
  }

  getDataPref() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? name = prefs.getString("userName");
    String? fullname = prefs.getString("fullName");

    if (mounted) {
      setState(() {
        _name = name;
        _fullname = fullname;
      });
    }
  }

  _mainMenu() {
    return ListTile(
      leading: Icon(Icons.menu, color: Colors.blueGrey[900]),
      title: const Text('หน้าหลัก',
          style: TextStyle(
              color: textColorBlack,
              fontSize: bodyText,
              fontWeight: FontWeight.w600)),
      selected: widget.menu == "mainmenu",
      onTap: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MainMenu(
              username: '${_name}',
            ),
          ),
          (route) => false,
        );
      },
    );
  }

  _stockBalanceMenu() {
    return ListTile(
      leading: Icon(Icons.widgets, color: Colors.blue[900]),
      title: const Text('สต็อคคงเหลือ',
          style: TextStyle(
              color: textColorBlack,
              fontSize: bodyText,
              fontWeight: FontWeight.w600)),
      selected: widget.menu == "stockbalance",
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const StockPage(),
          ),
          (route) => false,
        );
      },
    );
  }

  _finishJobMenu() {
    return ListTile(
      leading: Icon(MdiIcons.mapMarkerRadiusOutline, color: Colors.purple),
      title: Text('ยืนยันจัดส่ง',
          style: TextStyle(
              color: Colors.purpleAccent[300],
              fontSize: bodyText,
              fontWeight: FontWeight.w600)),
      selected: widget.menu == "finishJob",
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const ConfirmSendingPage(),
          ),
          (route) => false,
        );
      },
    );
  }

  _confirmwithDrawMenu() {
    return ListTile(
      leading: Icon(Icons.directions_bus_filled_sharp, color: Colors.cyan[600]),
      title: const Text('เช็คของขึ้นรถ',
          style: TextStyle(
              color: textColorBlack,
              fontSize: bodyText,
              fontWeight: FontWeight.w600)),
      selected: widget.menu == "Confirmwithdraw",
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ConfirmWithdrawPage(),
          ),
          (route) => false,
        );
      },
    );
  }

  _confirmDelivery() {
    return ListTile(
      leading:
          const Icon(Icons.directions_bus_filled_sharp, color: menuColorPink),
      title: const Text('ขนส่งสินค้า',
          style: TextStyle(
              color: textColorBlack,
              fontSize: bodyText,
              fontWeight: FontWeight.w600)),
      selected: widget.menu == "ConfirmDelivery",
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ConfirmDeliveryPage(),
          ),
          (route) => false,
        );
      },
    );
  }

  _withDrawMenu() {
    return ListTile(
      leading: const Icon(Icons.outbox_outlined,
          color: Color.fromRGBO(187, 56, 27, 1)),
      title: const Text('เบิกออกสินค้า',
          style: TextStyle(
              color: textColorBlack,
              fontSize: bodyText,
              fontWeight: FontWeight.w600)),
      selected: widget.menu == "withdraw",
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => WithdrawPage(),
          ),
          (route) => false,
        );
      },
    );
  }

  _receiveMenu() {
    return ListTile(
      leading: const Icon(Icons.input_outlined, color: menuColorGreen),
      title: const Text('รับเข้าสินค้า',
          style: TextStyle(
              color: textColorBlack,
              fontSize: bodyText,
              fontWeight: FontWeight.w600)),
      selected: widget.menu == "receive",
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ReceivePage(),
          ),
          (route) => false,
        );
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => ReceivePage()),
        // );
      },
    );
  }

  _withReqMenu() {
    return ListTile(
      leading: const Icon(Icons.all_inbox_rounded,
          color: Color.fromRGBO(255, 130, 68, 1)),
      title: const Text(
        'ขอเบิกสินค้า',
        style: TextStyle(
          color: textColorBlack,
          fontSize: bodyText,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: widget.menu == "withdrawReq",
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => WithdrawReqPage(),
          ),
          (route) => false,
        );
      },
    );
  }

  _settingMenuItem() {
    return ListTile(
      leading: const Icon(Icons.settings, color: Colors.blueGrey),
      title: const Text('ตั้งค่า',
          style: TextStyle(
              color: textColorBlack,
              fontSize: bodyText,
              fontWeight: FontWeight.w600)),
      selected: widget.menu == "setting",
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => SettingPage()),
        // );
      },
    );
  }

  // Menu Connect

  _recheckProductMenu() {
    return ListTile(
      leading: Icon(Icons.wysiwyg, color: Colors.amber[400]),
      title: const Text(
        'ตรวจนับสินค้า',
        style: TextStyle(
          color: textColorBlack,
          fontSize: bodyText,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: widget.menu == "recheckProduct",
      onTap: () {
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => WithdrawReqPage(),
        //   ),
        //   (route) => false,
        // );
      },
    );
  }

  _requestProductMenu() {
    return ListTile(
      leading: Icon(Icons.wrap_text, color: Colors.amber[400]),
      title: const Text(
        'ขอเติมสินค้า',
        style: TextStyle(
          color: textColorBlack,
          fontSize: bodyText,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: widget.menu == "requestProduct",
      onTap: () {
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => WithdrawReqPage(),
        //   ),
        //   (route) => false,
        // );
      },
    );
  }

  _promotionMenu() {
    return ListTile(
      leading: Icon(Icons.art_track_rounded, color: Colors.amber[400]),
      title: const Text(
        'สินค้าโปรโมชั่น',
        style: TextStyle(
          color: textColorBlack,
          fontSize: bodyText,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: widget.menu == "promotion",
      onTap: () {
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => WithdrawReqPage(),
        //   ),
        //   (route) => false,
        // );
      },
    );
  }

  _productExpireMenu() {
    return ListTile(
      leading: Icon(Icons.access_time_outlined, color: Colors.amber[400]),
      title: const Text(
        'สินค้าใกล้หมดอายุ',
        style: TextStyle(
          color: textColorBlack,
          fontSize: bodyText,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: widget.menu == "productExpire",
      onTap: () {
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => WithdrawReqPage(),
        //   ),
        //   (route) => false,
        // );
      },
    );
  }

  _addNewProductMenu() {
    return ListTile(
      leading: const Icon(Icons.add_photo_alternate, color: Colors.green),
      title: const Text(
        'บันทึกสินค้าใหม่',
        style: TextStyle(
          color: textColorBlack,
          fontSize: bodyText,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: widget.menu == "addNewProduct",
      onTap: () {
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => WithdrawReqPage(),
        //   ),
        //   (route) => false,
        // );
      },
    );
  }

  _listRequestProductMenu() {
    return ListTile(
      leading: const Icon(Icons.real_estate_agent_rounded, color: Colors.green),
      title: const Text(
        'รายการ ร้องขอ',
        style: TextStyle(
          color: textColorBlack,
          fontSize: bodyText,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: widget.menu == "listRequestProduct",
      onTap: () {
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => WithdrawReqPage(),
        //   ),
        //   (route) => false,
        // );
      },
    );
  }

  _addPromotionProductMenu() {
    return ListTile(
      leading: const Icon(Icons.price_change_rounded, color: Colors.green),
      title: const Text(
        'เพิ่มโปรโมชั่น',
        style: TextStyle(
          color: textColorBlack,
          fontSize: bodyText,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: widget.menu == "addPromotionProduct",
      onTap: () {
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => WithdrawReqPage(),
        //   ),
        //   (route) => false,
        // );
      },
    );
  }

  _reportMenu() {
    return ListTile(
      leading: const Icon(Icons.receipt_long_outlined, color: Colors.green),
      title: const Text(
        'Report',
        style: TextStyle(
          color: textColorBlack,
          fontSize: bodyText,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: widget.menu == "report",
      onTap: () {
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => WithdrawReqPage(),
        //   ),
        //   (route) => false,
        // );
      },
    );
  }

  _helpMenu() {
    return ListTile(
      leading: const Icon(Icons.help_center, color: Colors.orange),
      title: const Text(
        'Help',
        style: TextStyle(
          color: textColorBlack,
          fontSize: bodyText,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: widget.menu == "help",
      onTap: () {
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => WithdrawReqPage(),
        //   ),
        //   (route) => false,
        // );
      },
    );
  }

  Widget _buildMenuNormal() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 50,
                margin: const EdgeInsets.symmetric(horizontal: kPadding_10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: textColorWhite.withOpacity(0.5),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: textColorWhite,
                  size: 24,
                ),
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User : ${_name.toString()}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: headerText,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Name : ${_fullname}',
                      style: const TextStyle(
                          color: textColorWhite,
                          fontSize: mediumText,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
            ],
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kSecondaryColor,
                kPrimaryColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.0],
            ),
          ),
        ),
        _mainMenu(),
        _receiveMenu(),
        _withReqMenu(),
        _withDrawMenu(),
        // _confirmwithDrawMenu(),
        // _confirmDelivery(),
        //   _finishJobMenu(),
        _stockBalanceMenu(),
        //   _settingMenuItem(),
        ListTile(
          leading: const Icon(Icons.exit_to_app, color: menuColorBlue),
          title: const Text(
            'ออกจากระบบ',
            style: TextStyle(
              color: textColorBlack,
              fontSize: bodyText,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const LoginPage(),
              ),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuConnect() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 50,
                margin: const EdgeInsets.symmetric(horizontal: kPadding_10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: textColorWhite.withOpacity(0.5),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: textColorWhite,
                  size: 24,
                ),
              ),
              Container(
                height: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User : ${_name.toString()}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: headerText,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Name : ${_fullname}',
                      style: const TextStyle(
                          color: textColorWhite,
                          fontSize: mediumText,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
            ],
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kSecondaryColor,
                kPrimaryColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.0],
            ),
          ),
        ),
        _recheckProductMenu(),
        _requestProductMenu(),
        _promotionMenu(),
        _productExpireMenu(),
        /////////////
        _addNewProductMenu(),
        _listRequestProductMenu(),
        _addPromotionProductMenu(),
        _reportMenu(),
        _helpMenu(),
        ////////////// setting
        _settingMenuItem(),
        ListTile(
          leading: const Icon(Icons.exit_to_app, color: menuColorBlue),
          title: const Text(
            'ออกจากระบบ',
            style: TextStyle(
              color: textColorBlack,
              fontSize: bodyText,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const LoginPage(),
              ),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildMenuNormal(),
    );
  }
}
