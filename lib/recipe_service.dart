import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeService {
  static Future<List<Map<String, dynamic>>> fetchDesserts() async {
    final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List recipes = data['meals'];
      return recipes.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Gagal memuat data resep');
    }
  }
}
