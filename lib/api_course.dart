import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/";

  static Future<List<Course>> fetchModels(int user_id) async {
    final response = await http.get(Uri.parse(baseUrl + "classes/?user_id=$user_id"));

    if (response.statusCode == 200) {
      // print('Response body: ${response.body}'); // 查看原始 JSON 字串
      print('call class fetchModels');
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((model) => Course.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load models');
    }
  }

  static Future<http.Response> createCourse(String name, String content, int user_id) async {
    print('create class ...');
    final response = await http.post(
      Uri.parse(baseUrl + "classes/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'class_name': name,
        'user_user': user_id.toString(), //預設為 1
      }),
    );

    if (response.statusCode == 201) {
      print('Response body: ${response.body}');
      return response;
    } else {
      throw Exception('Failed to create class');
    }
  }

  static Future<http.Response> deleteCourse(int class_id) async {
    print('delete class ...');
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
      print('Response body: ${response.body}');
      return response;
    } else {
      throw Exception('Failed to delete class');
    }
  }

  static Future<http.Response> editCourse(Course course) async {
    print('edit class ...');
    final response = await http.patch(
      Uri.parse(baseUrl + "classes/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'class_id': course.classId.toString(),
        'class_name': course.name,
        'user_user': course.userId.toString(),
      }),
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      return response;
    } else {
      throw Exception('Failed to update class');
    }
  }

}

class Course {
  final int classId;
  String name;
  final int userId;
  
  Course({required this.classId, required this.name, required this.userId});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      classId: json['class_id'] as int,
      name: json['class_name'] as String,
      userId: json['user_user'] as int, //預設為 1
    );
  }
}
