// ignore_for_file: camel_case_types, non_constant_identifier_names

class JobDelivery_WithDetail {
  String F_withID;
  String f_withDate;
  String F_docDeliveryID;
  String F_docJobDeliveryID;
  String F_docDeliveryDate;
  String F_deliveryDateSchdule;
  String F_carRegistration;
  int F_docDeliveryStatus;
  int F_docJobStatus;
  int F_deliveryStep;
  String f_prodID;
  String f_prodName;
  int f_withQty;
  String f_index;
  int f_Confirm;
  String f_shippingCheck;
  String f_withWithdrawer;
  String f_wareID;
  String f_wareName;
  String f_withRemark;
  bool checked = false;

  JobDelivery_WithDetail(
      {required this.F_withID,
      required this.f_withDate,
      required this.F_docDeliveryID,
      required this.F_docJobDeliveryID,
      required this.F_docDeliveryDate,
      required this.F_deliveryDateSchdule,
      required this.F_carRegistration,
      required this.F_docDeliveryStatus,
      required this.F_docJobStatus,
      required this.F_deliveryStep,
      required this.f_prodID,
      required this.f_prodName,
      required this.f_withQty,
      required this.f_index,
      required this.f_Confirm,
      required this.f_shippingCheck,
      required this.f_withWithdrawer,
      required this.f_wareID,
      required this.f_wareName,
      required this.f_withRemark,
      required this.checked});

  factory JobDelivery_WithDetail.fromJson(Map<String, dynamic> json) {
    return JobDelivery_WithDetail(
        F_withID: json['F_withID'],
        f_withDate: json['f_withDate'],
        F_docDeliveryID: json['F_docDeliveryID'],
        F_docJobDeliveryID: json['F_docJobDeliveryID'],
        F_docDeliveryDate: json['F_docDeliveryDate'],
        F_deliveryDateSchdule: json['F_deliveryDateSchdule'],
        F_carRegistration: json['F_carRegistration'],
        F_docDeliveryStatus: json['F_docDeliveryStatus'],
        F_docJobStatus: json['F_docJobStatus'],
        F_deliveryStep: json['F_deliveryStep'],
        f_prodID: json['f_prodID'],
        f_prodName: json['f_prodName'],
        f_withQty: json['f_withQty'],
        f_index: json['f_index'] ?? '',
        f_Confirm: json['f_Confirm'] == null ? 0 : json['f_Confirm'],
        f_shippingCheck: json['f_shippingCheck'] == null
            ? ''
            : json['f_shippingCheck'].toString(),
        f_withWithdrawer: json['f_withWithdrawer'],
        f_wareID: json['f_wareID'],
        f_wareName: json['f_wareName'],
        f_withRemark: json['f_withRemark'],
        checked: false);
  }
}
