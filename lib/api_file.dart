import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/";

  static Future<List<File>> fetchModels() async {
    final response = await http.get(Uri.parse(baseUrl + "file/"));

    if (response.statusCode == 200) {
      // print('Response body: ${response.body}'); // 查看原始 JSON 字串
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((model) => File.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load models');
    }
  }

  static Future<http.Response> createFile(String name, String content) async {
    final response = await http.post(
      Uri.parse(baseUrl + "file/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'file_name': name,
        'file_content': content,
        'user_user': '1',//預設為 1
      }),
    );

    if (response.statusCode == 201) {
      // print(response.body);
      return response;
    } else {
      throw Exception('Failed to create file');
    }
  }

  static Future<http.Response> deleteFile(int file_id) async {
    final response = await http.delete(
      Uri.parse(baseUrl + "file/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'file_id': file_id.toString(),        
      }),
    );

    if (response.statusCode == 204) {
      // print(response.body);
      return response;
    } else {
      throw Exception('Failed to delete file');
    }
  }

  static Future<http.Response> editFile(File file) async {
    final response = await http.patch(
      Uri.parse(baseUrl + "file/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'file_id': file.file_id.toString(),
        'file_name': file.name,
        'file_content': file.content,
        'user_user': file.user_id.toString(),
      }),
    );

    if (response.statusCode == 200) {
      // print(response.body);
      return response;
    } else {
      throw Exception('Failed to update file');
    }
  }

}

class File {
  final int file_id;
  String name;
  String content;
  final int user_id;
  bool isStarred;
  
  File({required this.file_id, required this.name, required this.content,required this.user_id, this.isStarred = false});

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      file_id: json['file_id'] as int,
      name: json['file_name'],
      content: json['file_content'],
      user_id: 1,
      isStarred: false,

    );
  }
}
