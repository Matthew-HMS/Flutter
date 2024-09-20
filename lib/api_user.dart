import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/";

  static Future<http.Response> fetchModels(int user_id) async {
    final response = await http.get(Uri.parse(baseUrl + "login/update/?user_id=$user_id"));

    if (response.statusCode == 200) {
      // print('Response body: ${response.body}'); // 查看原始 JSON 字串
      print('call user fetchModels');
      print('Response body: ${response.body}');
      return response;
    } else {
      throw Exception('Failed to load models');
    }
  }

  static Future<http.Response> user_login(String user_account, String user_pw) async {
    print('login user ...');
    final response = await http.post(
      Uri.parse(baseUrl + "login/login/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_account': user_account,
        'user_pw': user_pw, 
      }),
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      return response;
    } else {
      print('Response body: ${response.body}');
      throw Exception('Failed to login user');
    }
  }

  static Future<http.Response> user_register(String user_account, String user_pw, String user_name) async {
    print('register user ...');
    final response = await http.post(
      Uri.parse(baseUrl + "login/register/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_account': user_account,
        'user_pw': user_pw, 
        'user_name': user_name,
      }),
    );

    if (response.statusCode == 201) {
      print('Response body: ${response.body}');
      return response;
    } else {
      print('Response body: ${response.body}');
      throw Exception('Failed to register user');
    }
  }

  static Future<http.Response> user_update(int user_id, String user_name, String user_account, String user_old_pw, String user_new_pw) async {
    print('update user ...');
    final response = await http.post(
      Uri.parse(baseUrl + "login/update/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': user_id.toString(),
        'user_name': user_name,
        'user_account': user_account,
        'user_old_pw': user_old_pw, 
        'user_new_pw': user_new_pw,
      }),
    );

    final responseBody  = utf8.decode(response.bodyBytes);
    final decodedJson = jsonDecode(responseBody);
    final message = decodedJson['message'];
    // print('Message: $message');

    if (response.statusCode == 200) {
      print('Response body: $message ');
      return response;
    } else {
      print('Response body: $message');
      throw Exception('$message');
    }
  }

  

}
