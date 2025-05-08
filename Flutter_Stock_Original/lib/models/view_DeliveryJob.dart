// ignore_for_file: non_constant_identifier_names, camel_case_types
class View_DeliveryJob {
  String F_docJobDeliveryID;
  String F_docDeliveryID;
  String F_docDeliveryDate;
  String F_deliveryDateSchdule;
  int F_docDeliveryStatus;
  String F_withID;
  int F_deliveryStep;
  String F_deliveryDate;
  int F_docJobStatus;
  String F_carID;
  String F_carRegistration;
  String F_carDetail;
  int F_carStatus;

  View_DeliveryJob(
      {required this.F_docJobDeliveryID,
      required this.F_docDeliveryID,
      required this.F_docDeliveryDate,
      required this.F_deliveryDateSchdule,
      required this.F_docDeliveryStatus,
      required this.F_withID,
      required this.F_deliveryStep,
      required this.F_deliveryDate,
      required this.F_docJobStatus,
      required this.F_carID,
      required this.F_carRegistration,
      required this.F_carDetail,
      required this.F_carStatus});

  factory View_DeliveryJob.fromJson(Map<String, dynamic> json) {
    return View_DeliveryJob(
        F_docJobDeliveryID: json['F_docJobDeliveryID'],
        F_docDeliveryID: json['F_docDeliveryID'],
        F_docDeliveryDate: json['F_docDeliveryDate'] ?? '',
        F_deliveryDateSchdule: json['F_deliveryDateSchdule'],
        F_docDeliveryStatus: json['F_docDeliveryStatus'],
        F_withID: json['F_withID'],
        F_deliveryStep: json['F_deliveryStep'],
        F_deliveryDate: json['F_deliveryDate'] ?? '',
        F_docJobStatus: json['F_docJobStatus'],
        F_carID: json['F_carID'],
        F_carRegistration: json['F_carRegistration'],
        F_carDetail: json['F_carDetail'],
        F_carStatus: json['F_carStatus']);
  }
}
