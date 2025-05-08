import 'package:Nippostock/config/constant.dart';
import 'package:Nippostock/printer/rich_widget.dart';
import 'package:Nippostock/services/form_button_widget.dart';
import 'package:Nippostock/widgets/layout_service.dart';
import 'package:flutter/material.dart';

class PrinterType {
  static const WIFI = "wireless";
  static const LAN = "lan";
}

class AddPrinterPage extends StatefulWidget {
  @override
  _AddPrinterPageState createState() => _AddPrinterPageState();
}

class _AddPrinterPageState extends State<AddPrinterPage> {
  final bool _isLoading = false;
  final String _printerType = PrinterType.WIFI;

  final TextEditingController _printerNameController =
      new TextEditingController();
  final TextEditingController _printerIpController =
      new TextEditingController();

  _addPrinter() async {
    FocusScope.of(context).unfocus();
    Map<String, dynamic> payload = {
      "name": _printerNameController.text,
      "ip": _printerIpController.text,
      "type": _printerType,
    };

    // try {
    //   OnlineApiService apiService = new OnlineApiService((bool showLoading) {
    //     setState(() {
    //       _isLoading = showLoading;
    //     });
    //   });
    //   await apiService.addPrinterSetting(payload);
    //   Navigator.pop(context, true);
    // } catch (e) {
    //   ExceptionHandler.handle(e, context, callBack: () => _addPrinter());
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('เพิ่มเครื่องพิมพ์'),
          ),
          body: SafeArea(
            child: Container(
              color: kBackgroundColor,
              child: Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.all(
                          LayoutService.isPhoneOrPortrait(context) ? 0 : 10),
                      child: Column(
                        children: [
                          Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              decoration:
                                  LayoutService.getBorderTopRadius(context),
                              margin: const EdgeInsets.only(bottom: 2),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(
                                          top: kPadding_10),
                                      child: RichWidget(
                                          text: "ชื่อเครื่องพิมพ์",
                                          isRequired: true)),
                                  TextField(
                                    controller: _printerNameController,
                                    style: const TextStyle(
                                        color: textColorBlack, fontSize: 16),
                                    cursorColor: textColorBlack,
                                    cursorHeight: 24,
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(0),
                                      hintText: 'เพิ่มชื่อเครื่องพิมพ์',
                                    ),
                                  )
                                ],
                              )),
                          Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 2),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(
                                          top: kPadding_10),
                                      child: RichWidget(
                                          text: "ไอพี (IP Address)",
                                          isRequired: true)),
                                  TextField(
                                    controller: _printerIpController,
                                    style: const TextStyle(
                                        color: textColorBlack, fontSize: 16),
                                    cursorColor: textColorBlack,
                                    cursorHeight: 24,
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(0),
                                      hintText: 'เพิ่มไอพี (IP Address)',
                                    ),
                                  )
                                ],
                              )),
                          Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              decoration:
                                  LayoutService.getBorderBottomRadius(context),
                              margin: const EdgeInsets.only(bottom: 2),
                              child: Column(
                                children: [
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(
                                          top: kPadding_10),
                                      child: RichWidget(
                                          text: "ประเภทการเชื่อมต่อ",
                                          isRequired: true)),
                                  const Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Row(
                                          children: [
                                            // Radio<String>(
                                            //   value: PrinterType.WIFI,
                                            //   groupValue: _printerType,
                                            //   onChanged: (String value) {
                                            //     setState(() {
                                            //       _printerType = value;
                                            //     });
                                            //   },
                                            // ),
                                            Text("เชื่อมต่อ WIFI")
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            // Radio<String>(
                                            //   value: PrinterType.LAN,
                                            //   groupValue: _printerType,
                                            //   onChanged: (String value) {
                                            //     setState(() {
                                            //       _printerType = value;
                                            //     });
                                            //   },
                                            // ),
                                            Text("เชื่อมต่อ LAN")
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )),
                        ],
                      ),
                    ),
                  )),
                  if (WidgetsBinding.instance.window.viewInsets.bottom <= 0.0)
                    Container(
                      margin: EdgeInsets.all(
                          LayoutService.isPhoneOrPortrait(context) ? 0 : 10),
                      child: FormButtonWidget(
                        onClickCancel: () => Navigator.pop(context),
                        onClickSubmit: () => _addPrinter(),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
        // if (_isLoading) LoadingFullScreen()
      ],
    );
  }
}
