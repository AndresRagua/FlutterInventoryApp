import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gestion_inventario_app/models/category.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _loading = false;

  List<Category> get categories => _categories;
  bool get loading => _loading;

  Future<List<Category>> fetchCategories() async {
    _loading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('http://localhost/gestion_inventario/public/index.php/api/categories'));

      if (response.statusCode == 200) {
        final List<dynamic> categoryJson = json.decode(response.body)['data'];
        _categories = categoryJson.map((json) => Category.fromJson(json)).toList();
        return _categories;
      } else {
        throw Exception('Error al cargar las categorías');
      }
    } catch (error) {
      print('Error al cargar categorías: $error');
      return [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
