// class Product {
//   String f_prodID = "";
//   String f_prodName = "";
//   String f_prodCate = "";
//   int f_unitNo = 0;
//   String f_prodRemark = "";
//   int f_prodStatus = 0;
//   double f_costprice = 0.0;
//   int f_max = 0;
//   int f_min = 0;
//   int f_minmaxStatus = 0;
//   Null f_picImage;
//   int f_serial = 0;
//   String f_brandID = "";
//   String f_DateRegister = "";
//   String f_Barcode = "";
//   int f_picStatus = 0;
//   String f_Package = "";
//   int f_Age = 0;
//   int f_count = 0;
//
//   Product(
//       {required this.f_prodID,
//       required this.f_prodName,
//       required this.f_prodCate,
//       required this.f_unitNo,
//       required this.f_prodRemark,
//       required this.f_prodStatus,
//       required this.f_costprice,
//       required this.f_max,
//       required this.f_min,
//       required this.f_minmaxStatus,
//       required this.f_picImage,
//       required this.f_serial,
//       required this.f_brandID,
//       required this.f_DateRegister,
//       required this.f_Barcode,
//       required this.f_picStatus,
//       required this.f_Package,
//       required this.f_Age,
//       required this.f_count});
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//         f_prodID: json['f_prodID'],
//         f_prodName: json['f_prodName'],
//         f_prodCate: json['f_prodCate'].toString(),
//         f_unitNo: json['f_unitNo'],
//         f_prodRemark: json['f_prodRemark'],
//         f_prodStatus: json['f_prodStatus'],
//         f_costprice: (json['f_costprice']).toDouble(),
//         f_max: json['f_max'],
//         f_min: json['f_min'],
//         f_minmaxStatus: json['f_minmaxStatus'],
//         f_picImage: null,
//         f_serial: json['f_serial'],
//         f_brandID: json['f_brandID'].toString(),
//         f_DateRegister:
//             json['f_DateRegister'] == null ? '' : json['f_DateRegister'],
//         f_Barcode: json['f_Barcode'] == null ? '' : json['f_Barcode'],
//         f_picStatus: json['f_picStatus'] == null ? 0 : json['f_picStatus'],
//         f_Package: json['f_Package'] == null ? '' : json['f_Package'],
//         f_Age: json['f_Age'] == null ? 0 : json['f_Age'],
//         f_count: 1);
//   }
// }

class Product {
  String f_prodID = "";
  String f_prodName = "";
  String f_cateID = "";
  String f_cateName = "";
  String f_cateRemark = "";
  int QTY_all = 0;
  int QTY = 0;
  int borrow_qty = 0;
  int f_max = 0;
  int f_min = 0;
  int f_minmaxStatus = 0;
  double f_costprice = 0;
  String f_prodCate = "";
  int f_unitNo = 0;
  String f_unitName = "";
  String f_wareID = "";
  String f_Barcode = "";

  Product({
    required this.f_prodID,
    required this.f_prodName,
    required this.f_cateID,
    required this.f_cateName,
    required this.f_cateRemark,
    required this.QTY_all,
    required this.QTY,
    required this.borrow_qty,
    required this.f_max,
    required this.f_min,
    required this.f_minmaxStatus,
    required this.f_costprice,
    required this.f_prodCate,
    required this.f_unitNo,
    required this.f_unitName,
    required this.f_wareID,
    required this.f_Barcode,
  });

  // f_prodID,
  // f_prodName,
  // f_cateID,
  // f_cateName,
  // f_cateRemark,
  // QTY,
  // borrow_qty,
  // f_max,
  // f_min,
  // f_minmaxStatus,
  // f_costprice,
  // f_prodCate,
  // f_unitNo,
  // f_unitName,
  // f_wareID,
  // f_Barcode,

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      f_prodID: json['f_prodID'].toString(),
      f_prodName: json['f_prodName'].toString(),
      f_cateID: json['f_cateID'].toString(),
      f_cateName: json['f_cateName'].toString(),
      f_cateRemark: json['f_cateRemark'] == null ? '' : json['f_cateRemark'],
      QTY_all: json['QTY'] == null ? 0 : json['QTY'],
      QTY: 1,
      borrow_qty: json['borrow_qty'] == null ? 0 : json['borrow_qty'],
      f_max: json['f_max'] == null ? 0 : json['f_max'],
      f_min: json['f_min'] == null ? 0 : json['f_min'],
      f_minmaxStatus: json['f_minmaxStatus'],
      f_costprice: json['f_costprice'].toDouble(),
      f_prodCate: json['f_prodCate'].toString(),
      f_unitNo: json['f_unitNo'],
      f_unitName: json['f_unitName'] == null ? '' : json['f_unitName'],
      f_wareID: json['f_wareID'].toString(),
      f_Barcode: json['f_Barcode'].toString(),
    );
  }
}
