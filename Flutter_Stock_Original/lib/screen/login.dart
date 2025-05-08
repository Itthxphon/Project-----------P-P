import 'dart:convert';

import 'package:Nippostock/models/user.dart';
import 'package:Nippostock/screen/mainmenu.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/constant.dart';
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  bool _showPassword = false;
  final String _appVersion = "";
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    //  getPackageInfo();
    super.initState();
  }

  // getPackageInfo() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   String version = packageInfo.version;
  //   String buildNumber = packageInfo.buildNumber;
  //   setState(() {
  //     _appVersion = 'version: $version build: $buildNumber';
  //   });
  // }

  // messageAlert(message) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return ErrorMessageAlert(message: message);
  //     },
  //   );
  // }

  // messageInformationAlert() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return InformationCashAlert();
  //     },
  //   );
  // }

  // signIn(String email, String password) async {
  //   FocusScope.of(context).unfocus();
  //   bool hasInternet = await DataConnectionChecker().hasConnection;

  //   if (hasInternet) {
  //     try {
  //       var apiService = new OnlineApiService((bool showLoading) {
  //         setState(() {
  //           _isLoading = showLoading;
  //         });
  //       });
  //       await apiService.signIn(email, password);
  //       final staticDataProvider =
  //           Provider.of<StaticDataProvider>(context, listen: false);
  //       staticDataProvider.user = await TokenService().getUser();
  //       await getMyShop();
  //       await getPrinter();
  //       OfflineService.fetchAll();
  //       print('Syncing orders...');
  //       OfflineService.syncOfflineOrders();
  //       messageInformationAlert();
  //     } on SocketException catch (e) {
  //       messageAlert(Dictionary.translate(e.toString()));
  //     } on NippoHttpException catch (e) {
  //       messageAlert(Dictionary.translate(e.toString()));
  //     }

  //     return;
  //   }

  //   OfflineTokenService tokenService = OfflineTokenService();
  //   if (await tokenService.getEmail() == '' ||
  //       await tokenService.getPassword() == '') {
  //     messageAlert(Dictionary.translate(
  //         'No offline account has been set. Cannot use offline mode.'));

  //     return;
  //   }

  //   final staticDataProvider =
  //       Provider.of<StaticDataProvider>(context, listen: false);
  //   staticDataProvider.user = await tokenService.getUser();

  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(
  //       builder: (BuildContext context) => CheckoutPage(),
  //     ),
  //     (route) => false,
  //   );
  // }

  // getMyShop() async {
  //   sharedPreferences = await SharedPreferences.getInstance();
  //   try {
  //     var apiService = new OnlineApiService((bool showLoading) {
  //       setState(() {
  //         _isLoading = showLoading;
  //       });
  //     });
  //     Shop shop = await apiService.getMyShop();
  //     setState(() {
  //       sharedPreferences.setString("shopName", shop.name);
  //       sharedPreferences.setString("shopCode", shop.code);
  //       sharedPreferences.setString("shopPhoneNumber", shop.contactPhoneNumber);
  //     });
  //   } on SocketException catch (e) {
  //     messageAlert(Dictionary.translate(e.toString()));
  //   } on NippoHttpException catch (e) {
  //     messageAlert(Dictionary.translate(e.toString()));
  //   } on TokenExpiredException catch (e) {
  //     if (e.toString() == "โทเค็นหมดอายุ") {
  //       signIn(_email.text, _password.text);
  //     } else {
  //       messageAlert(Dictionary.translate(e.toString()));
  //     }
  //   }
  // }

  // getPrinter() async {
  //   sharedPreferences = await SharedPreferences.getInstance();
  //   try {
  //     var apiService = new OnlineApiService((bool showLoading) {
  //       setState(() {
  //         _isLoading = showLoading;
  //       });
  //     });
  //     Printer printer = await apiService.getActivePrinter();
  //     setState(() {
  //       sharedPreferences.setString("printerIp", printer?.ip);
  //     });
  //   } on SocketException catch (e) {
  //     messageAlert(Dictionary.translate(e.toString()));
  //   } on NippoHttpException catch (e) {
  //     messageAlert(Dictionary.translate(e.toString()));
  //   } on TokenExpiredException catch (e) {
  //     if (e.toString() == "โทเค็นหมดอายุ") {
  //       signIn(_email.text, _password.text);
  //     } else {
  //       messageAlert(Dictionary.translate(e.toString()));
  //     }
  //   }
  // }

  Future<void> checkLogin() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    String url = "$server/api/users";
    final responce = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: convert.jsonEncode(
            {'username': _username.text, 'password': _password.text}));
    final jsonResponce = json.decode(responce.body);
    List<User> temp = (jsonResponce['data'] as List)
        .map((itemWorld) => User.fromJson(itemWorld))
        .toList();
    List<Setting> setting = (jsonResponce['setting'] as List)
        .map((itemWorld) => Setting.fromJson(itemWorld))
        .toList();

    final SharedPreferences prefs = await _prefs;

    if (temp.isNotEmpty) {
      if (mounted) {
        setState(() {
          prefs.setString("userID", temp[0].f_userID.toString());
          prefs.setString("userName", temp[0].f_username.toString());
          prefs.setString("fullName", temp[0].f_fullname.toString());
          prefs.setString("f_wbrUse", setting[0].f_wbrUse.toString());
          prefs.setString(
              "f_negativeDrawdown", setting[0].f_negativeDrawdown.toString());
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    MainMenu(username: temp[0].f_username),
              ),
              (route) => false);
        });
      }
    } else {
      _onAlertButtonPressed(context);
    }
  }

  Future<void> showMessageAlert(String title, String content) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loginContent();
  }

  _loginContent({bool online = true}) {
    Size size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                SizedBox(
                  height: size.height,
                  child: Stack(
                    children: [
                      Container(
                        height: size.height * 0.5,
                        decoration: const BoxDecoration(
                          color: kPrimaryColor,
                          // image: DecorationImage(
                          //     image: AssetImage('images/Main_Bg.png'),
                          //     fit: BoxFit.fill),
                        ),
                      ),
                      Positioned(
                        top: size.height * 0.1,
                        bottom: size.height * 0.1,
                        right: 0,
                        left: 0,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: size.width * 0.1,
                              right: size.width * 0.1,
                              bottom: kPadding_10),
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * 0.15),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    offset: const Offset(0, 10),
                                    blurRadius: 50,
                                    color: Colors.black.withOpacity(0.23))
                              ]),
                          child: Form(
                            key: _formKey,
                            child: ListView(
                              children: [
                                Container(
                                  height: orientation == Orientation.portrait
                                      ? size.width * 0.2
                                      : size.width * 0.1,
                                  decoration: const BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage('images/POS.jpg'),
                                          // image: AssetImage(
                                          //     'images/logo_connect.png'),
                                          fit: BoxFit.fitHeight)),
                                ),
                                if (online) ..._onlineFormFields(),
                                //  if (!online) ..._offlineFormFields(),
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  child: Text(
                                    _appVersion,
                                    style: const TextStyle(
                                        color: textColorBlack,
                                        fontSize: smallText),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // if (_isLoading) LoadingFullScreen()
          ],
        ),
      ),
    );
  }

  _onAlertButtonPressed(context) {
    Alert(
      context: context,
      type: AlertType.error,
      title: "Alert !",
      desc: "Username or Password incorrect !",
      buttons: [
        DialogButton(
          color: kPrimaryColor,
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  _onlineFormFields() {
    final orientation = MediaQuery.of(context).orientation;

    return [
      TextFormField(
        controller: _username,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Username',
          labelStyle: const TextStyle(fontSize: bodyText),
          suffixIcon: IconButton(
            color: kPrimaryColor,
            iconSize: 18,
            icon: const Icon(
              Icons.email,
            ),
            onPressed: () {},
          ),
        ),
      ),
      TextFormField(
        controller: _password,
        obscureText: !_showPassword,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: const TextStyle(fontSize: bodyText),
          suffixIcon: IconButton(
            iconSize: 18,
            icon: Icon(
              _showPassword ? Icons.remove_red_eye : Icons.visibility_off,
              color: _showPassword ? Colors.amber : Colors.grey,
            ),
            onPressed: () {
              setState(() => _showPassword = !_showPassword);
            },
          ),
        ),
        // validator: (value) {
        //   if (value.isEmpty) {
        //     return 'กรุณากรอกข้อมูลรหัสผ่าน';
        //   }
        //   return null;
        // },
      ),
      Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(vertical: kPadding_10),
        child: GestureDetector(
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
            // );
          },
          child: const Text(
            "ลืมรหัสผ่าน",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w200,
              color: kPrimaryColor,
            ),
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.only(
            top: orientation == Orientation.portrait ? 50 : kPadding_10),
        height: 45,
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(kPrimaryColor)),
          onPressed: () {
            if (_username.text == '' || _password.text == '') {
              _onAlertButtonPressed(context);
            } else {
              checkLogin();
            }
          },
          child: const Text(
            "เข้าสู่ระบบ",
            style: TextStyle(
                color: Colors.white,
                fontSize: mediumText,
                fontWeight: FontWeight.normal),
          ),
        ),
      ),
      // Container(
      //   height: 45,
      //   margin: EdgeInsets.symmetric(vertical: kPadding_10),
      //   child: RaisedButton(
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(3),
      //       side: BorderSide(
      //         color: Colors.amber,
      //       ),
      //     ),
      //     color: Colors.white,
      //     onPressed: () {
      //       // Navigator.push(
      //       //   context,
      //       //   MaterialPageRoute(builder: (context) => RegisterPage()),
      //       // );
      //     },
      //     child: Text(
      //       "ลงทะเบียน",
      //       style: TextStyle(
      //           color: Colors.amber[900],
      //           fontSize: bodyText,
      //           fontWeight: FontWeight.normal),
      //     ),
      //   ),
      // )
    ];
  }
}
