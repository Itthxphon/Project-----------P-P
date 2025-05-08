// ignore_for_file: non_constant_identifier_names
class StockBalance {
  String f_prodID = "";
  String f_prodName = "";
  String f_cateID = "";
  String f_cateName = "";
  String f_prodRemark = "";
  num QTY = 0;
  int borrow_qty = 0;
  int f_max = 0;
  int f_min = 0;
  String f_prodCate = "";
  String f_unitNo = "";
  String f_unitName = "";
  String f_Barcode = "";
  var f_picImage;

  StockBalance(
      {required this.f_prodID,
      required this.f_prodName,
      required this.f_cateID,
      required this.f_cateName,
      required this.f_prodRemark,
      required this.QTY,
      required this.borrow_qty,
      required this.f_max,
      required this.f_min,
      required this.f_prodCate,
      required this.f_unitNo,
      required this.f_unitName,
      required this.f_Barcode,
      required this.f_picImage});

  factory StockBalance.fromJson(Map<String, dynamic> json) {
    return StockBalance(
        f_prodID: json['f_prodID'],
        f_prodName: json['f_prodName'],
        f_cateID: json['f_cateID'].toString(),
        f_cateName: json['f_cateName'],
        f_prodRemark: json['f_prodRemark'],
        QTY: json['QTY'],
        borrow_qty: json['borrow_qty'],
        f_max: json['f_max'],
        f_min: json['f_min'],
        f_prodCate: json['f_prodCate'].toString(),
        f_unitNo: json['f_unitNo'].toString(),
        f_unitName: json['f_unitName'].toString(),
        f_Barcode: json['f_Barcode'] ?? "",
        f_picImage: json['f_picImage'] ?? null);
  }
}
class Image_pd{
  String f_prodID;
  var image_pd;
  Image_pd({
    required this.f_prodID,
    required this.image_pd
  });
  factory Image_pd.fromJson(Map<String,dynamic>json){
    return Image_pd(
        f_prodID: json['f_prodID']==""?"":json['f_prodID'],
        image_pd: json['f_picImage']==null?null:json['f_picImage']);
  }
}
