import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/";

  static Future<List<File>> fetchModels(int class_id) async {
    final url = Uri.parse(baseUrl + "file/?class_class=$class_id");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('call file fetchModels');
      // print('Response body: ${response.body}'); // 查看原始 JSON 字串
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((model) => File.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load models');
    }
  }

  static Future<http.Response> createFile(String name, String path, int class_id, String class_name) async {
    print('create other file ...');
    final response = await http.post(
      Uri.parse(baseUrl + "file/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'file_name': name,
        'file_path': path,
        'class_class': class_id.toString(),
        'class_name': class_name,
      }),
    );

    if (response.statusCode == 201) {
      print(response.body);
      return response;
    } else {
      throw Exception('Failed to create file');
    }
  }

  static Future<http.Response> deleteFile(int file_id) async {
    print('delete other file ...');
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
    print('edit other file ...');
    final response = await http.patch(
      Uri.parse(baseUrl + "file/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        // 'file_id': file.file_id.toString(),
        // 'file_name': file.name,
        // 'file_content': file.content,
        // 'user_user': file.user_id.toString(),
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
  String file_name;
  String file_path;
  final int class_id;
  
  File({required this.file_id, required this.file_name, required this.file_path,required this.class_id});

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      file_id: json['file_id'] as int,
      file_name: json['file_name'],
      file_path: json['file_path'],
      class_id: json['class_class'],
    );
  }
}
