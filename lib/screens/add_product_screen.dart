import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestion_inventario_app/providers/product_provider.dart'; // Importar el provider
import 'package:gestion_inventario_app/models/category.dart'; // Importar el modelo de categorías

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  double _price = 0.0;
  int _stock = 0;
  int? _categoryId; // Para almacenar el ID de la categoría seleccionada

  // Controladores de texto
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Llamar al método fetchCategories para cargar las categorías cuando se inicialice la pantalla
    Provider.of<ProductProvider>(context, listen: false).fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos las categorías desde el provider
    final categories = Provider.of<ProductProvider>(context).categories;
    final loadingCategories = Provider.of<ProductProvider>(context).loadingCategories;

    return Scaffold(
      appBar: AppBar(title: Text('Agregar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nombre del Producto', style: TextStyle(fontSize: 16)),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(hintText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 16),
              Text('Descripción', style: TextStyle(fontSize: 16)),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(hintText: 'Descripción'),
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 16),
              Text('Precio', style: TextStyle(fontSize: 16)),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(hintText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El precio es obligatorio';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = double.parse(value!);
                },
              ),
              SizedBox(height: 16),
              Text('Stock', style: TextStyle(fontSize: 16)),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(hintText: 'Stock'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _stock = int.parse(value!);
                },
              ),
              SizedBox(height: 16),
              // Dropdown para seleccionar la categoría
              Text('Categoría', style: TextStyle(fontSize: 16)),
              loadingCategories
                  ? CircularProgressIndicator() // Mostrar indicador de carga mientras cargan las categorías
                  : DropdownButtonFormField<int>(
                      value: _categoryId,
                      hint: Text('Selecciona una categoría'),
                      items: categories.map((Category category) {
                        return DropdownMenuItem<int>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _categoryId = value; // Almacenar el ID de la categoría seleccionada
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'La categoría es obligatoria';
                        }
                        return null;
                      },
                    ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addProduct,
                child: Text('Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para agregar el producto
  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Llamamos al método de ProductProvider para agregar el producto
      bool success = await Provider.of<ProductProvider>(context, listen: false)
          .addProduct(_name, _description, _price, _stock, _categoryId);

      if (success) {
        // Si el producto se agrega correctamente, volvemos a la pantalla principal
        Navigator.pop(context);
      } else {
        // Si ocurre un error, mostramos un mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hubo un error al agregar el producto')),
        );
      }
    }
  }
}
