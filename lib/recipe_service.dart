import 'dart:convert'; // Mengimpor pustaka untuk mengonversi data JSON
import 'package:http/http.dart' as http; // Mengimpor pustaka HTTP untuk melakukan permintaan jaringan

class RecipeService {
  // Kelas RecipeService untuk mengambil data resep dari API
  static Future<List<Map<String, dynamic>>> fetchDesserts() async {
    // Fungsi statis untuk mengambil daftar resep dessert
    final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert'); // URL API untuk mendapatkan resep dessert
    final response = await http.get(url); // Melakukan permintaan GET ke URL

    if (response.statusCode == 200) {
      // Memeriksa apakah permintaan berhasil (status code 200)
      final data = json.decode(response.body); // Mengonversi respons JSON menjadi objek Dart
      final List recipes = data['meals']; // Mengambil daftar resep dari data
      return recipes.cast<Map<String, dynamic>>(); // Mengembalikan daftar resep sebagai List<Map<String, dynamic>>
    } else {
      throw Exception('Gagal memuat data resep'); // Menangani error jika permintaan gagal
    }
  }
}