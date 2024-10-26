import 'package:flutter/material.dart';
import 'package:frontend_parcial2/database/databasehelper.dart';
import 'package:frontend_parcial2/models/models.dart';
import 'package:frontend_parcial2/pages/productos/producto_form_screen.dart';

class ProductosListScreen extends StatefulWidget {
  @override
  _ProductosListScreenState createState() => _ProductosListScreenState();
}

class _ProductosListScreenState extends State<ProductosListScreen> {
  List<Producto> productos = [];
  String filtroNombre = '';
  TextEditingController filtroNombreController = TextEditingController();
  TextEditingController filtroCategoriaController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _getProductos();
  }

  void _getProductos() async {
    var data = await dbHelper.getProductos(
      filtroNombre: filtroNombre,
    );
    setState(() {
      productos = data;
    });
  }

  void showForm([Producto? producto]) {
    // Navegar a la pantalla de creación/edición (CRUD)
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return ProductoFormScreen(producto: producto);
    })).then((value) {
      if (value == true) {
        _getProductos(); // Refrescar la lista al volver
      }
    });
  }

  void _deleteProducto(int id) async {
    await dbHelper.deleteProducto(id);
    _getProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => showForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: filtroNombreController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          filtroNombre = filtroNombreController.text;
                          _getProductos();
                        });
                      },
                    ),
                  ),
                ),
                // TextField(
                //   controller: filtroCategoriaController,
                //   decoration: InputDecoration(
                //     labelText: 'Buscar por ID de Categoría',
                //     suffixIcon: IconButton(
                //       icon: Icon(Icons.search),
                //       onPressed: () {
                //         setState(() {
                //           filtroCategoria = filtroCategoriaController.text;
                //           _getProductos();
                //         });
                //       },
                //     ),
                //   ),
                //   keyboardType: TextInputType.number,
                // ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                return ListTile(
                  title: Text(producto.nombre),
                  subtitle: Text('Categoría: ${producto.idCategoria} - Precio: \$${producto.precioVenta}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => showForm(producto),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteProducto(producto.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
