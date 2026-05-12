import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pbm_api/api_handler/shared.dart';

class SubmitHandler {
  final String name = "Mie Ayam";
  final double price = 10_000;
  final String description = "Psikolog mahal, makanya Tuhan nyiptain produk ini";
  final String githubUrl = "https://github.com/ThatPersonAyuma/PMB_API-Flutter";

  Future<bool> submitTask(String token) async {
    final url = Uri.parse('$BASE_URL/api/products/submit');

    final response = await http.post(
      url,
      headers: {
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
      // Simpan token menggunakan flutter_secure_storage
      // agar dapat digunakan pada request berikutnya
    } else {
      print('Gagal melakukan submit tugas: ${response.body}');
      return false;
    }
  }
}
