import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/";

  static Future<String> sendMessage(int class_id, String message, int PttWord_page, int ppt_id) async {
    print("sending message ...");
    final response = await http.post(
      Uri.parse(baseUrl + "gpt/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'class_class': class_id.toString(),
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

