import 'package:flutter/material.dart';
import 'package:frontend_parcial2/config/constantes.dart';
import 'package:frontend_parcial2/config/icons_mapping.dart';
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
  String? selectedIconName; // Para almacenar el nombre del ícono seleccionado
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.proveedor != null) {
      nombreController.text = widget.proveedor!.nombre;
      selectedIconName = widget.proveedor!.icono;
    }
  }

  void _saveProveedor() async {
    if (_formKey.currentState!.validate()) {
      if (selectedIconName == null || selectedIconName!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor selecciona un ícono')),
        );
        return;
      }

      if (widget.proveedor == null) {
        await dbHelper.insertCategoria(Categoria(
          nombre: nombreController.text,
          icono: selectedIconName!,
        ));
      } else {
        await dbHelper.updateCategoria(Categoria(
          id: widget.proveedor!.id,
          nombre: nombreController.text,
          icono: selectedIconName!,
        ));
      }

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
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedIconName,
                decoration: InputDecoration(labelText: 'Ícono'),
                items: IconsMapping.iconMap.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(entry.value),
                        SizedBox(width: 8),
                        Text(entry.key),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedIconName = value;
                  });
                },
              ),
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
