import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/";

  static Future<List<Ppt>> fetchModels(int class_id) async {
    final url = Uri.parse(baseUrl + "ppt/?class_class=$class_id");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('call ppt fetchModels');
      print('Response body: ${response.body}'); // 查看原始 JSON 字串
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((model) => Ppt.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load models');
    }
  }

  static Future<http.Response> createPpt(String name, String path, int class_id) async {
    final response = await http.post(
      Uri.parse(baseUrl + "ppt/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'ppt_name': name,
        'ppt_path': path,
        'class_class': class_id.toString(),
      }),
    );

    if (response.statusCode == 201) {
      // print(response.body);
      return response;
    } else {
      throw Exception('Failed to create file');
    }
  }

  static Future<http.Response> deletePpt(int file_id) async {
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

  static Future<http.Response> editPpt(Ppt ppt) async {
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

class Ppt {
  final int ppt_id;
  String ppt_name;
  String ppt_path;
  final int class_id;
  
  Ppt({required this.ppt_id, required this.ppt_name, required this.ppt_path,required this.class_id});

  factory Ppt.fromJson(Map<String, dynamic> json) {
    return Ppt(
      ppt_id: json['ppt_id'] as int,
      ppt_name: json['ppt_name'],
      ppt_path: json['ppt_path'],
      class_id: json['class_class'],
    );
  }
}
