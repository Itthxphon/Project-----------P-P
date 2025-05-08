import 'package:Nippostock/config/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyDataWidget extends StatelessWidget {
  const EmptyDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/no_data.svg',
            width: 120,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "ไม่มีข้อมูล",
              style: TextStyle(color: textColorBlack, fontSize: mediumText),
            ),
          )
        ],
      ),
    );
  }
}
