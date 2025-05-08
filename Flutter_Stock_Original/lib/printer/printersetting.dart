import 'package:Nippostock/models/printer.dart';
import 'package:Nippostock/printer/add_printer.dart';
import 'package:Nippostock/widgets/layout_service.dart';
import 'package:flutter/material.dart';

class PrinterSetting extends StatefulWidget {
  const PrinterSetting({Key? key}) : super(key: key);

  @override
  _PrinterSettingState createState() => _PrinterSettingState();
}

class _PrinterSettingState extends State<PrinterSetting> {
  bool _isLoading = false;
  bool _networkloading = false;
  TextEditingController printerName = new TextEditingController();
  TextEditingController printerIp = new TextEditingController();
  // SharedPreferences _sharedPreferences ;
  List<Printer> _printers = [];
  // SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('ตั้งค่าการพิมพ์'),
            actions: [
              IconButton(
                onPressed: () async {
                  // const PaperSize paper = PaperSize.mm80;
                  // final profile = await CapabilityProfile.load();
                  // final printer = NetworkPrinter(paper, profile);
                  // sharedPreferences = await SharedPreferences.getInstance();
                  // String ipAddress = sharedPreferences.getString("printerIp");
                  // final PosPrintResult res =
                  //     await printer.connect(ipAddress, port: 9100);
                  // if (res == PosPrintResult.success) {
                  //   await testReceipt(printer);
                  //   printer.disconnect();
                  // }
                },
                icon: Icon(
                  Icons.print,
                  color: Colors.white,
                ),
              )
            ],
          ),
          // body: SafeArea(
          //     // child: Container(
          //     //   color: kBackgroundColor,
          //     //   child: _printers.isEmpty && !_isLoading
          //     //       ? EmptyDataWidget()
          //     //       : ListView.builder(
          //     //           padding: EdgeInsets.all(
          //     //               LayoutService.isPhoneOrPortrait(context) ? 0 : 10),
          //     //           itemCount: _printers.length,
          //     //           itemBuilder: (context, index) {
          //     //             return Slidable(
          //     //               actionPane: SlidableDrawerActionPane(),
          //     //               actionExtentRatio: 0.15,
          //     //               child: Container(
          //     //                 margin: EdgeInsets.only(bottom: 2),
          //     //                 decoration: _getBoxDecoration(index),
          //     //                 child: ListTile(
          //     //                   title: Text(_printers[index].name),
          //     //                   subtitle: Text("IP: ${_printers[index].ip}"),
          //     //                   trailing: Icon(
          //     //                     _getIconPrinter(index),
          //     //                     color: _printers[index].active
          //     //                         ? kPrimaryColor
          //     //                         : textColorGrey,
          //     //                   ),
          //     //                 ),
          //     //               ),
          //     //               secondaryActions: <Widget>[
          //     //                 IconSlideAction(
          //     //                     caption: 'ลบ',
          //     //                     icon: Icons.delete,
          //     //                     foregroundColor: Colors.white,
          //     //                     color: sSecondaryColor,
          //     //                     onTap: () =>
          //     //                         {} //_deletePrinter(_printers[index].id)},
          //     //                     ),
          //     //                 if (!_printers[index].active)
          //     //                   IconSlideAction(
          //     //                     caption: 'เชื่อมต่อ',
          //     //                     icon: Icons.wifi,
          //     //                     color: kPrimaryColor,
          //     //                     onTap: () {},
          //     //                     // onTap: () => _connectPrinter(_printers[index].id),
          //     //                   ),
          //     //               ],
          //     //             );
          //     //           }),
          //     // ),
          //     ),
        )
      ],
    );
  }

  _getIconPrinter(int index) {
    if (_printers[index].type == PrinterType.LAN) return Icons.cable;
    if (_printers[index].type == PrinterType.WIFI && _printers[index].active)
      return Icons.wifi;
    return Icons.wifi_off;
  }

  _getBoxDecoration(int index) {
    if (index == 0) return LayoutService.getBorderTopRadius(context);
    if (index + 1 == _printers.length)
      return LayoutService.getBorderBottomRadius(context);
    return BoxDecoration(color: Colors.white);
  }
}
