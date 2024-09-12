import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/";

  // static Future<List<Course>> user_login() async {
  //   final response = await http.get(Uri.parse(baseUrl + "classes/"));

  //   if (response.statusCode == 200) {
  //     // print('Response body: ${response.body}'); // 查看原始 JSON 字串
  //     print('call class fetchModels');
  //     List jsonResponse = json.decode(response.body);
  //     return jsonResponse.map((model) => Course.fromJson(model)).toList();
  //   } else {
  //     throw Exception('Failed to load models');
  //   }
  // }

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

  // static Future<http.Response> deleteCourse(int class_id) async {
  //   print('delete class ...');
  //   final response = await http.delete(
  //     Uri.parse(baseUrl + "classes/"),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'class_id': class_id.toString(),        
  //     }),
  //   );

  //   if (response.statusCode == 204) {
  //     print('Response body: ${response.body}');
  //     return response;
  //   } else {
  //     throw Exception('Failed to delete class');
  //   }
  // }

  // static Future<http.Response> editCourse(Course course) async {
  //   print('edit class ...');
  //   final response = await http.patch(
  //     Uri.parse(baseUrl + "classes/"),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       'class_id': course.class_id.toString(),
  //       'class_name': course.name,
  //       'user_user': course.user_id.toString(),
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     print('Response body: ${response.body}');
  //     return response;
  //   } else {
  //     throw Exception('Failed to update class');
  //   }
  // }

}
