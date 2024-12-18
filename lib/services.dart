import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dictionary_model.dart';

class APIservices {
  static String baseUrl = "https://api.dictionaryapi.dev/api/v2/entries/en/";

  static Future<DictionaryModel?> fetchData(String word) async {
    Uri url = Uri.parse("$baseUrl$word");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DictionaryModel.fromJson(data[0]);
      } else {
        throw Exception("Failed to load meaning for $word");
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
