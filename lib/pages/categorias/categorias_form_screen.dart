import 'package:flutter/material.dart';
import 'package:frontend_parcial2/config/constantes.dart';
import 'package:frontend_parcial2/database/databasehelper.dart';
import 'package:frontend_parcial2/models/models.dart';
import 'package:frontend_parcial2/pages/home/home_screen.dart';

class CategoriaFormScreen extends StatefulWidget {
  final Categoria? proveedor;

  CategoriaFormScreen({this.proveedor});

  @override
  _CategoriaFormScreenState createState() => _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends State<CategoriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nombreController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.proveedor != null) {
      nombreController.text = widget.proveedor!.nombre;
    }
  }

  void _saveProveedor() async {
    if (_formKey.currentState!.validate()) {
      if (widget.proveedor == null) {
        await dbHelper.insertCategoria(Categoria(
          nombre: nombreController.text,
        ));
      } else {
        await dbHelper.updateCategoria(Categoria(
          id: widget.proveedor!.id,
          nombre: nombreController.text,
        ));
      }
      // Navegar a la pantalla de inicio y remover la pantalla actual
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return const HomeScreen(index: categoriasIndex);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.proveedor == null ? 'Nueva Categoria' : 'Editar Categoria'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              // TextFormField(
              //   controller: idCategoriaController,
              //   decoration: InputDecoration(labelText: 'ID Categoría'),
              //   keyboardType: TextInputType.number,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Por favor ingresa el ID de categoría';
              //     }
              //     return null;
              //   },
              // ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProveedor,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
