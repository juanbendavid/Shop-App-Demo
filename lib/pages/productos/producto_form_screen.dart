import 'package:flutter/material.dart';
import 'package:frontend_parcial2/config/constantes.dart';
import 'package:frontend_parcial2/database/databasehelper.dart';
import 'package:frontend_parcial2/models/models.dart';
import 'package:frontend_parcial2/pages/home/home_screen.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;

  ProductoFormScreen({this.producto});

  @override
  _ProductoFormScreenState createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nombreController = TextEditingController();
  TextEditingController precioVentaController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper();

  List<Categoria> categorias = [];
  int? selectedCategoriaId;

  @override
  void initState() {
    super.initState();
    _loadCategorias();
    if (widget.producto != null) {
      nombreController.text = widget.producto!.nombre;
      precioVentaController.text = widget.producto!.precioVenta.toString();
      selectedCategoriaId = widget.producto!.idCategoria;
    }
  }

  void _loadCategorias() async {
    // Cargar las categorías desde la base de datos
    var data = await dbHelper.getCategorias();
    setState(() {
      categorias = data;
    });
  }

  void _saveProducto() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCategoriaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una categoría')),
        );
        return;
      }

      if (widget.producto == null) {
        await dbHelper.insertProducto(Producto(
          nombre: nombreController.text,
          idCategoria: selectedCategoriaId!,
          precioVenta: int.parse(precioVentaController.text),
        ));
      } else {
        await dbHelper.updateProducto(Producto(
          id: widget.producto!.id,
          nombre: nombreController.text,
          idCategoria: selectedCategoriaId!,
          precioVenta: int.parse(precioVentaController.text),
        ));
      }
      // Navegar a la pantalla de inicio y remover la pantalla actual
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return const HomeScreen(index: productosIndex);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.producto == null ? 'Nuevo Producto' : 'Editar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del producto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: selectedCategoriaId,
                hint: const Text('Selecciona una categoría'),
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categorias.map((Categoria categoria) {
                  return DropdownMenuItem<int>(
                    value: categoria.id,
                    child: Text(categoria.nombre),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    selectedCategoriaId = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: precioVentaController,
                decoration: const InputDecoration(labelText: 'Precio de Venta'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el precio de venta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProducto,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
