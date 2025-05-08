import 'package:Nippostock/config/constant.dart';
import 'package:flutter/material.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor = kPrimaryColor;
  final Widget title;
  final AppBar appBar;
  final List<Widget> widgets;
  final bool arrorBack;

  /// you can add more fields that meet your needs

  const BaseAppBar({
    required Key key,
    required this.title,
    required this.appBar,
    required this.widgets,
    required this.arrorBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //  automaticallyImplyLeading: arrorBack ?? true,
      centerTitle: true,
      // flexibleSpace: Container(
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       colors: [kSecondaryColor, kPrimaryColor],
      //       begin: Alignment.centerLeft,
      //       end: Alignment.centerRight,
      //     ),
      //   ),
      // ),
      title: title,
      backgroundColor: backgroundColor,
      actions: widgets,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}
