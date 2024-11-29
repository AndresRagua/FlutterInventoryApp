class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  // Factory constructor para crear una categoría desde JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}
