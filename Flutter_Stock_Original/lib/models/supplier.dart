
class Supplier {
  String f_supID;
  String f_supName;
  String f_supDetail;
  int f_supStatus;

  Supplier(
      {required this.f_supID,
      required this.f_supName,
      required this.f_supDetail,
      required this.f_supStatus});

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
        f_supID: json['f_supID'],
        f_supName: json['f_supName'],
        f_supDetail: json['f_supDetail'],
        f_supStatus: json['f_supStatus']);
  }
}
