import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'shared.dart';

class AuthHandler {
  final tokenKey = "session token";
  final nameKey = 'username';
  final storage = const FlutterSecureStorage();
  const AuthHandler();
  Future<String?> login(String nim, String password) async {
    final url = Uri.parse('$BASE_URL/api/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'username': nim, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      String token = data['data']['token'];
      String name = data['data']['user']['name'];

      print('Login berhasil! Token: $token');
      this.storeToken(token);
      this.storeName(name);
      return token;
      // Simpan token menggunakan flutter_secure_storage
      // agar dapat digunakan pada request berikutnya
    } else {
      print('Login gagal: ${response.body}');
      return null;
    }
  }

  Future<String?> getName() async {
    String? username = await storage.read(key: nameKey);
    return username;
  }

  /// Check if user has already login, authentication token already exist
  /// return String of the token if already login, otherwise return null
  Future<String?> getToken() async {
    String? username = await storage.read(key: tokenKey);
    return username;
  }

  /// Store token in storage using flutter_secure_storage
  Future<void> storeToken(String value) async {
    await storage.write(key: tokenKey, value: value);
  }
  Future<void> storeName(String value) async {
    await storage.write(key: nameKey, value: value);
  }

  /// Delete token from storage
  Future<void> logOut() async {
    await storage.deleteAll();
  }
}
