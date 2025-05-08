class Receive {
  String f_recvID = "";
  String f_recvDate = "";
  String f_recvRemark = "";
  int f_recvStatus = 0;
  String f_recvReceiver = "";
  String f_recvReferance = "";
  String f_recvReferanceDate = "";
  String f_wareID = "";
  String f_supID = "";
  String f_wareName = "";
  String f_supName = "";

  Receive(
      {required this.f_recvID,
      required this.f_recvDate,
      required this.f_recvRemark,
      required this.f_recvStatus,
      required this.f_recvReceiver,
      required this.f_recvReferance,
      required this.f_recvReferanceDate,
      required this.f_wareID,
      required this.f_supID,
      required this.f_supName,
      required this.f_wareName});

  factory Receive.fromJson(Map<String, dynamic> json) {
    return Receive(
        f_recvID: json['f_recvID'],
        f_recvDate: json['f_recvDate'] == null ? '' : json['f_recvDate'],
        f_recvRemark: json['f_recvRemark'],
        f_recvStatus: json['f_recvStatus'],
        f_recvReceiver: json['f_recvReceiver'],
        f_recvReferance: json['f_recvReferance'],
        f_recvReferanceDate: json['f_recvReferanceDate'] == null
            ? ''
            : json['f_recvReferanceDate'],
        f_wareID: json['f_wareID'] == null ? '' : json['f_wareID'],
        f_supID: json['f_supID'] == null ? '' : json['f_supID'],
        f_supName: json['f_supName'] == null ? '' : json['f_supName'],
        f_wareName: json['f_wareName'] == null ? '' : json['f_wareName']);
  }
}
