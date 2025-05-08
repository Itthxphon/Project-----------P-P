// ignore_for_file: non_constant_identifier_names

class Car {
  String F_carID;
  String F_carRegistration;
  String F_carDetail;
  int F_carStatus;

  Car(
      {required this.F_carID,
      required this.F_carRegistration,
      required this.F_carDetail,
      required this.F_carStatus});

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
        F_carID: json['F_carID'],
        F_carRegistration: json['F_carRegistration'],
        F_carDetail: json['F_carDetail'],
        F_carStatus: json['F_carStatus']);
  }
}
