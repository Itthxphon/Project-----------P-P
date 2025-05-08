class Customer {
  String f_cusID;
  String f_cusName;
  String f_cusDetail;
  int f_cusStatus;
  int f_cusNo;

  Customer(
      {required this.f_cusID,
      required this.f_cusName,
      required this.f_cusDetail,
      required this.f_cusStatus,
      required this.f_cusNo});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
        f_cusID: json['f_cusID'],
        f_cusName: json['f_cusName'],
        f_cusDetail: json['f_cusDetail'],
        f_cusStatus: json['f_cusStatus'],
        f_cusNo: json['f_cusNo'] == null ? 0 : json['f_cusNo']);
  }
}
