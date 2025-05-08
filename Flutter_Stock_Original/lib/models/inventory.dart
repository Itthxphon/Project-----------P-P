// ignore_for_file: non_constant_identifier_names

class Inventory {
  String f_wareID;
  String f_wareName;
  String f_wareRemark;
  int f_wareStatus;
  String f_whID;

  Inventory(
      {required this.f_wareID,
      required this.f_wareName,
      required this.f_wareRemark,
      required this.f_wareStatus,
      required this.f_whID});

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
        f_wareID: json['f_wareID'],
        f_wareName: json['f_wareName'],
        f_wareRemark: json['f_wareRemark'],
        f_wareStatus: json['f_wareStatus'],
        f_whID: json['f_whID'] == null ? '' : json['f_whID'].toString());
  }
}
