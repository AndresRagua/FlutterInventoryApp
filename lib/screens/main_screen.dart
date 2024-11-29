import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestion_inventario_app/providers/product_provider.dart';
import 'package:gestion_inventario_app/models/product.dart';
import 'package:gestion_inventario_app/screens/add_product_screen.dart'; // Asegúrate de tener esta ruta correcta
import 'package:gestion_inventario_app/screens/edit_product_screen.dart'; // Asegúrate de tener esta ruta correcta

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar productos al iniciar la pantalla
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestión de Inventario')),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.loading) {
            return Center(child: CircularProgressIndicator());
          }

          // Si no hay productos
          if (productProvider.products.isEmpty) {
            return Center(child: Text('No se encontraron productos.'));
          }

          // Total de productos en stock
          int totalStock = productProvider.products.fold(0, (sum, item) => sum + item.stock);

          // Productos con stock bajo (por ejemplo, menos de 10 unidades)
          int lowStockCount = productProvider.products.where((product) => product.stock < 10).length;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de estadísticas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard('Total Productos', productProvider.products.length.toString(), Icons.shopping_cart),
                      _buildStatCard('Stock Total', totalStock.toString(), Icons.inventory),
                      _buildStatCard('Stock Bajo', lowStockCount.toString(), Icons.warning),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  // Lista de productos
                  Text('Lista de Productos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.products[index];
                      return _buildProductTile(product);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la pantalla de agregar producto
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Tarjeta para mostrar las estadísticas
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.blueAccent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            SizedBox(height: 10),
            Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 5),
            Text(value, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Card para mostrar cada producto
  Widget _buildProductTile(Product product) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stock: ${product.stock}', style: TextStyle(color: Colors.grey)),
            Text('Price: \$${product.price}', style: TextStyle(color: Colors.green)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Navegar a la pantalla de editar producto
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductScreen(product: product),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Eliminar el producto
                _deleteProduct(product.id);
              },
            ),
          ],
        ),
        onTap: () {
          // Aquí puedes agregar la lógica para navegar a la página de detalles del producto si la necesitas
        },
      ),
    );
  }

  // Método para eliminar el producto
  void _deleteProduct(int productId) async {
    final success = await Provider.of<ProductProvider>(context, listen: false).deleteProduct(productId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producto eliminado exitosamente')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar el producto')));
    }
  }
}
