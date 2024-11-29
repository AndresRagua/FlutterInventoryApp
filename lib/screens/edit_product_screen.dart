import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestion_inventario_app/providers/product_provider.dart';
import 'package:gestion_inventario_app/providers/category_provider.dart'; // Importamos el CategoryProvider
import 'package:gestion_inventario_app/models/product.dart';
import 'package:gestion_inventario_app/models/category.dart'; // Importamos el modelo de Category

class EditProductScreen extends StatefulWidget {
  final Product product;
  EditProductScreen({required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late double _price;
  late int _stock;
  int? _categoryId; // Nueva variable para la categoría seleccionada

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _description = widget.product.description;
    _price = widget.product.price;
    _stock = widget.product.stock;
    _categoryId = widget.product.category_id; // Establecemos la categoría actual del producto
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del producto
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Nombre requerido' : null,
                onSaved: (value) => _name = value!,
              ),
              // Descripción del producto
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Descripción'),
                onSaved: (value) => _description = value!,
              ),
              // Precio del producto
              TextFormField(
                initialValue: _price.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Precio'),
                onSaved: (value) => _price = double.parse(value!),
              ),
              // Stock del producto
              TextFormField(
                initialValue: _stock.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Stock'),
                onSaved: (value) => _stock = int.parse(value!),
              ),
              SizedBox(height: 16),
              // Dropdown para seleccionar la categoría
              Text('Categoría'),
              FutureBuilder<List<Category>>(
                future: Provider.of<CategoryProvider>(context, listen: false).fetchCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error al cargar las categorías');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No hay categorías disponibles');
                  } else {
                    List<Category> categories = snapshot.data!;
                    return DropdownButtonFormField<int>(
                      value: _categoryId,
                      decoration: InputDecoration(labelText: 'Seleccionar Categoría'),
                      items: categories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _categoryId = value;
                        });
                      },
                      validator: (value) => value == null ? 'Categoría requerida' : null,
                    );
                  }
                },
              ),
              SizedBox(height: 16),
              // Botón para guardar los cambios
              ElevatedButton(
                onPressed: _editProduct,
                child: Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      bool success = await Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(widget.product.id, _name, _description, _price, _stock, _categoryId);

      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al editar el producto')));
      }
    }
  }
}
