// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

class User {
  String f_userID = "";
  String f_username = "";
  String f_password = "";
  String f_group_user_id = "";
  int f_userStatus = 0;
  String f_fullname = "";

  List<User> _user = [];
  User({
    required this.f_userID,
    required this.f_username,
    required this.f_password,
    required this.f_group_user_id,
    required this.f_userStatus,
    required this.f_fullname,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      f_userID: json['f_userID'],
      f_username: json['f_username'],
      f_password: json['f_password'],
      f_group_user_id: json['f_group_user_id'],
      f_userStatus: json['f_userStatus'],
      f_fullname: json['f_fullname'],
    );
  }
}

class Setting {
  String f_wbrUse = "";
  String f_negativeDrawdown = "";

  List<Setting> _Setting = [];

  Setting({required this.f_wbrUse, required this.f_negativeDrawdown});
  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
        f_wbrUse: json['f_wbrUse'] == null ? "" : json['f_wbrUse'],
        f_negativeDrawdown: json['f_negativeDrawdown'] == null
            ? ""
            : json['f_negativeDrawdown']);
  }
}
