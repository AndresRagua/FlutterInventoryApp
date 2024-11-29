import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestion_inventario_app/models/category.dart';  // Asegúrate de crear este modelo
import 'package:gestion_inventario_app/models/product.dart';

class ApiService {
  static const String baseUrl = 'http://localhost/gestion_inventario/public/index.php/api';

  // Método para obtener todos los productos
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los productos');
    }
  }

  // Método para obtener todas las categorías
  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las categorías');
    }
  }
}
