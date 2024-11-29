import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'screens/main_screen.dart';
import 'providers/category_provider.dart'; // Asegúrate de importar el CategoryProvider

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider( // Usamos MultiProvider para manejar múltiples proveedores
      providers: [
        ChangeNotifierProvider(create: (context) => ProductProvider()), // ProductProvider
        ChangeNotifierProvider(create: (context) => CategoryProvider()), // CategoryProvider
      ],
      child: MaterialApp(
        title: 'Gestión de Inventario',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MainScreen(),
      ),
    );
  }
}
