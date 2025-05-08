import 'package:Nippostock/config/constant.dart';
import 'package:Nippostock/widgets/layout_service.dart';
import 'package:flutter/material.dart';

class FormButtonWidget extends StatelessWidget {
  final Function onClickCancel;
  final Function onClickSubmit;

  FormButtonWidget({required this.onClickCancel, required this.onClickSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: LayoutService.getBorderAllRadius(context),
      alignment: Alignment.center,
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(
          top: 5, bottom: LayoutService.isPhoneOrPortrait(context) ? 0 : 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: InkWell(
              //  onTap: onClickCancel,
              child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: kPrimaryColor, width: 1),
                    borderRadius: BorderRadius.circular(3)),
                child: Text("ยกเลิก",
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: mediumText,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              // onTap: onClickSubmit,
              child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: kPrimaryColor,
                    border: Border.all(color: kPrimaryColor, width: 1),
                    borderRadius: BorderRadius.circular(3)),
                child: Text("บันทึก",
                    style: TextStyle(
                        color: textColorWhite,
                        fontSize: mediumText,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
