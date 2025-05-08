class WithDrawHead {
  String f_withID = "";
  String f_withDate = "";
  String f_withRemark = "";
  int f_withStatus = 0;
  String f_withWithdrawer = "";
  String f_withReferance = "";
  String f_withReferanceDate = "";
  String f_withTo = "";
  String f_wareID = "";
  String f_withReq = "";
  int f_isArrive = 0;
  String f_arriveDate = "";
  String f_wareName = "";
  String f_shippingCheck = "";
  int f_finishShipping = 0;
  String f_cusName = "";

  WithDrawHead(
      {required this.f_withID,
      required this.f_withDate,
      required this.f_withRemark,
      required this.f_withStatus,
      required this.f_withWithdrawer,
      required this.f_withReferance,
      required this.f_withReferanceDate,
      required this.f_withTo,
      required this.f_wareID,
      required this.f_withReq,
      required this.f_isArrive,
      required this.f_arriveDate,
      required this.f_wareName,
      required this.f_shippingCheck,
      required this.f_finishShipping,
      required this.f_cusName});

  factory WithDrawHead.fromJson(Map<String, dynamic> json) {
    return WithDrawHead(
        f_withID: json['f_withID'],
        f_withDate: json['f_withDate'],
        f_withRemark: json['f_withRemark'],
        f_withStatus: json['f_withStatus'] == null ? 0 : json['f_withStatus'],
        f_withWithdrawer: json['f_withWithdrawer'],
        f_withReferance: json['f_withReferance'],
        f_withReferanceDate: json['f_withReferanceDate'] == null
            ? ''
            : json['f_withReferanceDate'],
        f_withTo: json['f_withTo'],
        f_wareID: json['f_wareID'] == null ? '' : json['f_wareID'],
        f_withReq: json['f_withReq'] == null ? '' : json['f_withReq'],
        f_isArrive: json['f_isArrive'] == null ? 0 : json['f_isArrive'],
        f_arriveDate: json['f_arriveDate'] == null ? '' : json['f_arriveDate'],
        f_wareName: json['f_wareName'] == null ? '' : json['f_wareName'],
        f_shippingCheck: json['f_shippingCheck'] == null
            ? ''
            : json['f_shippingCheck'].toString(),
        f_finishShipping:
            json['f_finishShipping'] == null ? 0 : json['f_finishShipping'],
        f_cusName: json['f_cusName'] == null ? '' : json['f_cusName']);
  }
}
