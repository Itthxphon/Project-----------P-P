class WithdrawReqDetail {
  String f_withReqID = "";
  String f_prodID = "";
  int f_withReqQty = 0;
  int f_index = 0;
  String f_prodName = "";
  String f_Barcode = "";
  int QTY_all = 0;
  int QTY_Count = 0;

  WithdrawReqDetail(
      {required this.f_withReqID,
      required this.f_prodID,
      required this.f_withReqQty,
      required this.f_index,
      required this.f_prodName,
      required this.f_Barcode,
      required this.QTY_all,
      required this.QTY_Count});

  factory WithdrawReqDetail.fromJson(Map<String, dynamic> json) {
    return WithdrawReqDetail(
      f_withReqID: json['f_withReqID'],
      f_prodID: json['f_prodID'],
      f_withReqQty: json['f_withReqQty'],
      f_index: json['f_index'] == null ? 0 : json['f_index'],
      f_prodName: json['f_prodName'],
      f_Barcode: json['f_Barcode'] == null ? '' : json['f_Barcode'],
      QTY_all: json['QTY'] == null ? 0 : json['QTY'],
      QTY_Count: 0,
    );
  }
}
