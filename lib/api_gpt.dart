import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/";

  static Future<List<Map<String, dynamic>>> fetchModels(int pptword_page, int ppt_ppt) async {
    print("fetch page $pptword_page in ppt $ppt_ppt");
    final url = Uri.parse(baseUrl + "gpt/?pptword_page=$pptword_page&ppt_ppt=$ppt_ppt");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> jsonResponse = List<Map<String, dynamic>>.from(json.decode(response.body));
      return jsonResponse;
    } else {
      throw Exception('Failed to load models');
    }
  }


  static Future<String> sendMessage(String message, int PttWord_page, int ppt_id) async {
    print("send message to gpt ...");
    final response = await http.post(
      Uri.parse(baseUrl + "gpt/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'message': message,
        'pptword_page': PttWord_page.toString(),
        'ppt_ppt': ppt_id.toString(),
      }),
    );

    if (response.statusCode == 200) {
      // 解析回應的 JSON 並返回 "message" 欄位的值
      final Map<String, dynamic> responseJson = json.decode(response.body);
      return responseJson['message'] as String;
    } else {
      throw Exception('Failed to receive GPT response');
    }
  }
}

