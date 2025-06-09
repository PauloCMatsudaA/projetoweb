import 'dart:convert';
import 'package:http/http.dart' as http;

class AdviceService {
  static Future<String> getAdvice() async {
    final url = Uri.parse('https://api.adviceslip.com/advice');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['slip']['advice'];
    } else {
      throw Exception('Falha ao carregar conselho');
    }
  }
}
