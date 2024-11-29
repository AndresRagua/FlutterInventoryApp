import 'dart:convert'; // Para convertir JSON a objetos
import 'package:flutter/material.dart';
import 'package:gestion_inventario_app/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:gestion_inventario_app/models/product.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = []; // Lista para almacenar las categorías
  bool _loading = false;
  bool _loadingCategories =
      false; // Variable para saber si estamos cargando las categorías
  final String apiUrl =
      'http://localhost/gestion_inventario/public/index.php/api/products';

  List<Product> get products => _products;
  List<Category> get categories =>
      _categories; // Getter para obtener las categorías
  bool get loading => _loading;
  bool get loadingCategories =>
      _loadingCategories; // Getter para saber si estamos cargando categorías

  // Métodos para las estadísticas
  int get totalProducts => _products.length;

  int get lowStockProducts =>
      _products.where((product) => product.stock <= 5).length;

  int get totalStock =>
      _products.fold(0, (sum, product) => sum + product.stock);

  double get averagePrice {
    if (_products.isEmpty) return 0.0;
    return _products.fold(0.0, (sum, product) => sum + product.price) /
        _products.length;
  }

  // Método para obtener las categorías
  Future<void> fetchCategories() async {
    _loadingCategories = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(
          'http://localhost/gestion_inventario/public/index.php/api/categories'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(
            'Respuesta de las categorías: $responseData'); // Agregar este print para verificar la respuesta

        if (responseData['status'] == 'success') {
          final List<dynamic> categoryJson = responseData['data'];
          _categories =
              categoryJson.map((json) => Category.fromJson(json)).toList();
        } else {
          throw Exception('Error al cargar las categorías');
        }
      } else {
        throw Exception('Error al cargar categorías');
      }
    } catch (error) {
      print('Error al cargar categorías: $error');
    } finally {
      _loadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts() async {
    _loading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(
          'http://localhost/gestion_inventario/public/index.php/api/products'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(
            'Respuesta de la API: $responseData'); // Agregar este print para verificar la respuesta

        if (responseData['status'] == 'success') {
          final List<dynamic> productJson = responseData['data'];
          _products =
              productJson.map((json) => Product.fromJson(json)).toList();
        } else {
          throw Exception('Error en la respuesta de la API');
        }
      } else {
        throw Exception('Error al cargar productos');
      }
    } catch (error) {
      print('Error al cargar productos: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(String name, String description, double price,
      int stock, int? categoryId) async {
    final url = Uri.parse(
        'http://localhost/gestion_inventario/public/index.php/api/product');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category_id': categoryId,
        }),
      );

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, recargamos los productos
        fetchProducts();
        return true;
      } else {
        print('Error: ${response.body}');
        throw Exception('Error al agregar el producto');
      }
    } catch (error) {
      print('Error al agregar el producto: $error');
      return false;
    }
  }

  Future<bool> updateProduct(int id, String name, String description,
      double price, int stock, int? categoryId) async {
    final url = Uri.parse(
        'http://localhost/gestion_inventario/public/index.php/api/product/$id');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json', // Enviar como JSON
        },
        body: json.encode({
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category_id': categoryId, // Enviar category_id
        }),
      );

      if (response.statusCode == 200) {
        fetchProducts();
        return true;
      } else {
        print('Error: ${response.body}');
        throw Exception('Error al editar el producto');
      }
    } catch (error) {
      print('Error al editar el producto: $error');
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    final url = Uri.parse(
        'http://localhost/gestion_inventario/public/index.php/api/product/$id');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        fetchProducts();
        return true;
      } else {
        throw Exception('Error al eliminar el producto');
      }
    } catch (error) {
      print('Error al eliminar el producto: $error');
      return false;
    }
  }
}
