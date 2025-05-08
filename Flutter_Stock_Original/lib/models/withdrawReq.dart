class WithdrawReqHead {
  String f_withReqID = "";
  String f_withReqDate = "";
  String f_withReqRemark = "";
  int f_withReqStatus = 0;
  String f_withReqWithdrawer = "";
  String f_withReqReferance = "";
  String f_withReqReferanceDate = "";
  String f_withReqTo = "";
  String f_wareID = "";
  int f_needDelivery = 0;
  String f_wareName = "";
  String f_cusName = "";

  WithdrawReqHead(
      {required this.f_withReqID,
      required this.f_withReqDate,
      required this.f_withReqRemark,
      required this.f_withReqStatus,
      required this.f_withReqWithdrawer,
      required this.f_withReqReferance,
      required this.f_withReqReferanceDate,
      required this.f_withReqTo,
      required this.f_wareID,
      required this.f_needDelivery,
      required this.f_wareName,
      required this.f_cusName});

  factory WithdrawReqHead.fromJson(Map<String, dynamic> json) {
    return WithdrawReqHead(
        f_withReqID: json['f_withReqID'],
        f_withReqDate: json['f_withReqDate'],
        f_withReqRemark: json['f_withReqRemark'],
        f_withReqStatus: json['f_withReqStatus'],
        f_withReqWithdrawer: json['f_withReqWithdrawer'],
        f_withReqReferance: json['f_withReqReferance'],
        f_withReqReferanceDate: json['f_withReqReferanceDate'] == null
            ? ''
            : json['f_withReqReferanceDate'],
        f_withReqTo: json['f_withReqTo'],
        f_wareID: json['f_wareID'],
        f_needDelivery: json['f_needDelivery'],
        f_wareName: json['f_wareName'] == null ? '' : json['f_wareName'],
        f_cusName: json['f_cusName'] == null ? '' : json['f_cusName']);
  }
}
