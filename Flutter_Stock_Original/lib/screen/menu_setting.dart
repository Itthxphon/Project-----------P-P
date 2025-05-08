import 'package:Nippostock/config/constant.dart';
import 'package:Nippostock/widgets/layout_service.dart';
import 'package:Nippostock/widgets/responsive.dart';
import 'package:flutter/material.dart';

class MenuSettingType {
  static const PROFILE = "profile";
  static const RECEIPT = "receipt";
  static const SALES = "sales";
  static const PRINTER = "printer";
}

class MenuSettingWidget extends StatelessWidget {
  final String activeMenu;
  final Function(String) onTap;

  MenuSettingWidget({required this.activeMenu, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color _getActiveColor() {
      if (Responsive.isMobile(context)) return Colors.white;
      return kPrimaryColor.withOpacity(0.1);
    }

    EdgeInsets _getMargin() {
      if (Responsive.isMobile(context)) return EdgeInsets.only(bottom: 2);
      return EdgeInsets.only(bottom: 2, right: 10, top: 5);
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Responsive.isMobile(context) ? kBackgroundColor : Colors.white,
          child: Column(
            children: [
              InkWell(
                onTap: () => onTap(MenuSettingType.PROFILE),
                child: Container(
                  decoration: BoxDecoration(
                      color: this.activeMenu == MenuSettingType.PROFILE
                          ? _getActiveColor()
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  margin: _getMargin(),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        child: Icon(Icons.storefront, color: menuColorGreen),
                      ),
                      Expanded(
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('ตั้งค่าโปรไฟล์',
                                  style: TextStyle(
                                      fontSize: bodyText,
                                      color: textColorBlack)))),
                      if (LayoutService.isPhoneOrPortrait(context))
                        IconButton(
                          icon: Icon(
                            Icons.keyboard_arrow_right,
                            color: textColorGrey,
                          ),
                          onPressed: () {},
                        ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () => onTap(MenuSettingType.RECEIPT),
                child: Container(
                  decoration: BoxDecoration(
                      color: this.activeMenu == MenuSettingType.RECEIPT
                          ? _getActiveColor()
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  margin: _getMargin(),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        child: Icon(Icons.receipt_long, color: menuColorPink),
                      ),
                      Expanded(
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('ตั้งค่าใบเสร็จ',
                                  style: TextStyle(
                                      fontSize: bodyText,
                                      color: textColorBlack)))),
                      if (LayoutService.isPhoneOrPortrait(context))
                        IconButton(
                          icon: Icon(
                            Icons.keyboard_arrow_right,
                            color: textColorGrey,
                          ),
                          onPressed: () {},
                        ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () => onTap(MenuSettingType.SALES),
                child: Container(
                  decoration: BoxDecoration(
                      color: this.activeMenu == MenuSettingType.SALES
                          ? _getActiveColor()
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  margin: _getMargin(),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        child:
                            Icon(Icons.shopping_basket, color: menuColorOrange),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ตั้งค่าการขาย',
                            style: TextStyle(
                                fontSize: bodyText, color: textColorBlack),
                          ),
                        ),
                      ),
                      if (LayoutService.isPhoneOrPortrait(context))
                        IconButton(
                          icon: Icon(
                            Icons.keyboard_arrow_right,
                            color: textColorGrey,
                          ),
                          onPressed: () {},
                        ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () => onTap(MenuSettingType.PRINTER),
                child: Container(
                  decoration: BoxDecoration(
                      color: this.activeMenu == MenuSettingType.PRINTER
                          ? _getActiveColor()
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  margin: _getMargin(),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        child: Icon(Icons.print, color: menuColorBlue),
                      ),
                      Expanded(
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('ตั้งค่าการพิมพ์',
                                  style: TextStyle(
                                      fontSize: bodyText,
                                      color: textColorBlack)))),
                      if (LayoutService.isPhoneOrPortrait(context))
                        IconButton(
                          icon: Icon(
                            Icons.keyboard_arrow_right,
                            color: textColorGrey,
                          ),
                          onPressed: () {},
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
