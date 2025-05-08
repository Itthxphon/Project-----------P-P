import 'package:Nippostock/config/constant.dart';
import 'package:flutter/material.dart';

class RichWidget extends StatelessWidget {
  final String text;
  final bool isRequired;

  RichWidget({required this.text, this.isRequired = true});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: bodyText,
          color: Colors.black,
          fontFamily: "Sarabun",
          fontWeight: FontWeight.w600,
        ),
        children: <TextSpan>[
          if (isRequired == true)
            TextSpan(
              text: '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: mediumText,
              ),
            )
        ],
      ),
    );
  }
}
