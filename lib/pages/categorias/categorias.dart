import 'package:flutter/material.dart';
import 'package:frontend_parcial2/database/databasehelper.dart';
import 'package:frontend_parcial2/models/models.dart';
import 'package:frontend_parcial2/pages/categorias/categorias_form_screen.dart';

class CategoriasListScreen extends StatefulWidget {
  @override
  _CategoriasListScreenState createState() => _CategoriasListScreenState();
}

class _CategoriasListScreenState extends State<CategoriasListScreen> {
  List<Categoria> proveedores = [];
  String filtroNombre = '';
  TextEditingController filtroController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _getProveedores();
  }

  void _getProveedores({String? filtroNombre}) async {
    var data = await dbHelper.getCategorias(filtroNombre: filtroNombre);
    setState(() {
      proveedores = data;
    });
  }

  void showForm([Categoria? proveedor]) {
    // Navegar a la pantalla de creación/edición (CRUD)
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return CategoriaFormScreen(proveedor: proveedor);
    })).then((value) {
      if (value == true) {
        _getProveedores(); // Refrescar la lista al volver
      }
    });
  }

  void _deleteProveedor(int id) async {
    await dbHelper.deleteCategoria(id);
    _getProveedores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: filtroController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      filtroNombre = filtroController.text;
                      _getProveedores(filtroNombre: filtroNombre);
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  filtroNombre = value;
                  _getProveedores(filtroNombre: filtroNombre);
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: proveedores.length,
              itemBuilder: (context, index) {
                final proveedor = proveedores[index];
                return ListTile(
                  title: Text(proveedor.nombre),
                  // subtitle: Text('Categoría: ${proveedor.idCategoria}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => showForm(proveedor),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteProveedor(proveedor.id!),
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
