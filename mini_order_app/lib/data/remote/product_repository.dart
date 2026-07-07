import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductRepository {
  static const _url = 'https://fakestoreapi.com/products';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch products: ${response.statusCode}');
    }
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
