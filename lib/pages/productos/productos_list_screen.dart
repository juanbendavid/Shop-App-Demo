import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_parcial2/config/funciones.dart';
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

  void _getProductos({String? filtroNombre}) async {
    var data = await dbHelper.getProductos(
      filtroNombre: filtroNombre,
    );
    setState(() {
      productos = data;
    });
  }
  Future<String> _getCategoriaFromId(int id) async {
    var data = await dbHelper.getCategoriaFromId(id);
    return data.nombre;
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
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          filtroNombre = filtroNombreController.text;
                          _getProductos();
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filtroNombre = value;
                      _getProductos(filtroNombre: filtroNombre);
                    });
                  },
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
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      producto.imagen != null
                      ? Image.file(File(producto.imagen!), width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(producto.nombre, textAlign: TextAlign.start, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                          Text('Precio: Gs. ${formatNumber(producto.precioVenta)}'),
                          Text('Cantidad: ${producto.cantidadExistente}'),
                        ],
                      ),
                      const Spacer(),
                      Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => showForm(producto),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProducto(producto.id!),
                      ),
                    ],
                  ),
                    ],
                  ),
                  // subtitle: 
                  // trailing: 
                  
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
