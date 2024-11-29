class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final int category_id;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category_id
  });

  // Factory constructor para crear un Product desde JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.tryParse(json['price']) ?? 0.0, // Convertimos price de String a double
      stock: json['stock'],
      category_id: json['category_id']
    );
  }
}
