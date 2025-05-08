

// Future<Product> _getProduct() async {
//   Map<String, dynamic> body = await getProduct("id");
//   return Product.fromJson(body);
// }

// class OnlineApiService {
//   Future<void> getProduct(String id) async {
//     String url = server + "/api/product/'${id}'";
//     final response = await http
//         .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

//     var jsonResponce = json.decode(response.body);
//     Map<String, dynamic> body = jsonResponce;
//     //print(jsonResponce['data']);

//     // List<Product> temp = (jsonResponce['data'] as List)
//     //     .map((itemWord) => Product.fromJson(itemWord))
//     //     .toList();
//     print(body);
//     //return Product.fromJson(body);
//   }
// }

// A function that converts a response body into a List<Photo>.
// List<User> parseUser(String responseBody) {
//   final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

//   return parsed.map<User>((json) => User.fromJson(json)).toList();
// }

//List<User>
// Future<String> fetchUser(int id) async {
//   String url = "http://172.16.200.181:3000/api/users/'${id}'";

//   final response = await http.get(Uri.parse(url));
//   var body = jsonDecode(response.body);
//   // Use the compute function to run parsePhotos in a separate isolate.
//   print(response.body);
//   return response.body;
// }

// Future<User> getUser(int id) async {
//   String url = "http://172.16.200.181:3000/api/users/'${id}'";
//   final response = await http
//       .get(Uri.parse(url), headers: {"Content-Type": "application/json"});

//   final jsonResponce = json.decode(response.body);
//   //Map<String, dynamic> _body = body['data'];

//   print(jsonResponce['data']);

//   List<User> temp = (jsonResponce['data'] as List)
//       .map((itemWord) => User.fromJson(itemWord))
//       .toList();

//   return temp;
//   // return User.fromJson(jsonResponce['data']);
// }
