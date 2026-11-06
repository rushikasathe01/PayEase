import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendTest {
  static Future<void> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/health'),
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        print('✅ PAYEASE BACKEND CONNECTED');
      } else {
        print('❌ BACKEND RESPONSE NOT SUCCESSFUL');
      }
    } catch (e) {
      print('❌ BACKEND CONNECTION ERROR: $e');
    }
  }
}