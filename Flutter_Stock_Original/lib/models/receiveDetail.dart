class ReceiveDetail {
  String f_recvID = "";
  String f_prodID = "";
  int f_recvQty = 0;
  double f_recvCost = 0.00;
  String f_prodName = "";
  String f_wareName = "";
  String f_supName = "";

  ReceiveDetail(
      {required this.f_recvID,
      required this.f_prodID,
      required this.f_recvQty,
      required this.f_recvCost,
      required this.f_prodName,
      required this.f_supName,
      required this.f_wareName});

  factory ReceiveDetail.fromJson(Map<String, dynamic> json) {
    return ReceiveDetail(
        f_recvID: json['f_recvID'],
        f_prodID: json['f_prodID'],
        f_recvQty: json['f_recvQty'],
        f_recvCost:
            json['f_recvCost'] == null ? 0.00 : json['f_recvCost'].toDouble(),
        f_prodName: json['f_prodName'] == null ? '' : json['f_prodName'],
        f_wareName: json['f_wareName'] == null ? '' : json['f_wareName'],
        f_supName: json['f_supName'] == null ? '' : json['f_supName']);
  }
}
