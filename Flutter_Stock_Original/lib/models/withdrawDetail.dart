class WithDrawDetail {
  String f_withID = "";
  String f_prodID = "";
  int f_withQty = 0;
  int f_index = 0;
  int f_Confirm = 0;
  String f_prodName = "";
  bool checked = false;

  WithDrawDetail(
      {required this.f_withID,
      required this.f_prodID,
      required this.f_withQty,
      required this.f_index,
      required this.f_Confirm,
      required this.f_prodName,
      required this.checked});

  factory WithDrawDetail.fromJson(Map<String, dynamic> json) {
    return WithDrawDetail(
        f_withID: json['f_withID'],
        f_prodID: json['f_prodID'],
        f_withQty: json['f_withQty'],
        f_index: json['f_index'] == null ? 0 : json['f_index'],
        f_Confirm: json['f_Confirm'] == null ? 0 : json['f_Confirm'],
        f_prodName: json['f_prodName'],
        checked: false);
  }
}
