import 'dart:convert';
import 'package:http/http.dart' as http;
import 'shared.dart';
import 'login.dart';

class Product {
  final int productId;
  final String name;
  final double price;
  final String description;

  Product({
    required this.productId,
    required this.name,
    required this.price,
    required this.description,
  });

  // Factory constructor untuk memetakan data JSON ke objek Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['id'],
      name: json['name'],
      price: double.parse(json['price']),
      description: json['description'],
    );
  }
}

class ProductHandler {
  final String token;

  const ProductHandler({required this.token});

  Future<List<Product>?> getDataProducts() async {
    print("Getting data");
    final url = Uri.parse('$BASE_URL/api/products');

    final response = await http.get(
      url,
      headers: {
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> productsJson = data['data']['products'];
      print(productsJson);
      List<Product> products = productsJson
          .map<Product>((json) => Product.fromJson(json))
          .toList();
      print(products);
      return products;
      // Simpan token menggunakan flutter_secure_storage
      // agar dapat digunakan pada request berikutnya
    } else {
      print('Login gagal: ${response.body}');
      return null;
    }
  }

  Future<bool> createProduct(String name, double price, String description) async {
    final url = Uri.parse('$BASE_URL/api/products');

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
      }),
    );
    if (response.statusCode == 201) {
      return true;
      // Simpan token menggunakan flutter_secure_storage
      // agar dapat digunakan pada request berikutnya
    } else {
      print('Gagal menambahkan product: ${response.body}');
      return false;
    }
  }
}
