import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/";

  static Future<List<Course>> fetchModels() async {
    final response = await http.get(Uri.parse(baseUrl + "classes/"));

    if (response.statusCode == 200) {
      print('Response body: ${response.body}'); // 查看原始 JSON 字串
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((model) => Course.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load models');
    }
  }

  static Future<http.Response> createCourse(String name, String content) async {
    final response = await http.post(
      Uri.parse(baseUrl + "classes/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'class_name': name,
        'user_user': '1',//預設為 1
      }),
    );

    if (response.statusCode == 201) {
      print(response.body);
      return response;
    } else {
      throw Exception('Failed to create class');
    }
  }

  static Future<http.Response> deleteCourse(int class_id) async {
    final response = await http.delete(
      Uri.parse(baseUrl + "classes/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'class_id': class_id.toString(),        
      }),
    );

    if (response.statusCode == 204) {
      print(response.body);
      return response;
    } else {
      throw Exception('Failed to delete class');
    }
  }

  static Future<http.Response> editCourse(Course course) async {
    final response = await http.patch(
      Uri.parse(baseUrl + "classes/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'classes_id': course.class_id.toString(),
        'classes_name': course.name,
        'user_user': course.user_id.toString(),
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return response;
    } else {
      throw Exception('Failed to update class');
    }
  }

}

class Course {
  final int class_id;
  String name;
  final int user_id;
  
  Course({required this.class_id, required this.name, required this.user_id});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      class_id: json['classes_id'] as int,
      name: json['classes_name'],
      user_id: 1,
    );
  }
}
