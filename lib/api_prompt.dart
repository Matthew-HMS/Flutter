import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/";

  static Future<List<Prompt>> fetchModels() async {
    final response = await http.get(Uri.parse(baseUrl + "prompt/"));

    if (response.statusCode == 200) {
      print('Response body: ${response.body}'); // 查看原始 JSON 字串
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((model) => Prompt.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load models');
    }
  }

  static Future<http.Response> createPrompt(String name, String content) async {
    final response = await http.post(
      Uri.parse(baseUrl + "prompt/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'prompt_name': name,
        'prompt_content': content,
        'user_user': '1',//預設為 1
      }),
    );

    if (response.statusCode == 201) {
      print(response.body);
      return response;
    } else {
      throw Exception('Failed to create prompt');
    }
  }

  static Future<http.Response> deletePrompt(int prompt_id) async {
    final response = await http.delete(
      Uri.parse(baseUrl + "prompt/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'prompt_id': prompt_id.toString(),        
      }),
    );

    if (response.statusCode == 204) {
      print(response.body);
      return response;
    } else {
      throw Exception('Failed to delete prompt');
    }
  }

  static Future<http.Response> editPrompt(Prompt prompt) async {
    final response = await http.patch(
      Uri.parse(baseUrl + "prompt/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'prompt_id': prompt.prompt_id.toString(),
        'prompt_name': prompt.name,
        'prompt_content': prompt.content,
        'user_user': prompt.user_id.toString(),
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return response;
    } else {
      throw Exception('Failed to update prompt');
    }
  }

}

class Prompt {
  final int prompt_id;
  String name;
  String content;
  final int user_id;
  bool isStarred;
  
  Prompt({required this.prompt_id, required this.name, required this.content,required this.user_id, this.isStarred = false});

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      prompt_id: json['prompt_id'] as int,
      name: json['prompt_name'],
      content: json['prompt_content'],
      user_id: 1,
      isStarred: false,

    );
  }
}
