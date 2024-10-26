import 'package:flutter/material.dart';
import 'package:frontend_parcial2/database/databasehelper.dart';
import 'package:frontend_parcial2/models/models.dart';
import 'package:frontend_parcial2/pages/home/venta_screen.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;

  ProductoFormScreen({this.producto});

  @override
  _ProductoFormScreenState createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nombreController = TextEditingController();
  TextEditingController idCategoriaController = TextEditingController();
  TextEditingController precioVentaController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.producto != null) {
      nombreController.text = widget.producto!.nombre;
      idCategoriaController.text = widget.producto!.idCategoria.toString();
      precioVentaController.text = widget.producto!.precioVenta.toString();
    }
  }

  void _saveProducto() async {
    if (_formKey.currentState!.validate()) {
      if (widget.producto == null) {
        await dbHelper.insertProducto(Producto(
          nombre: nombreController.text,
          idCategoria: int.parse(idCategoriaController.text),
          precioVenta: double.parse(precioVentaController.text),
        ));
      } else {
        await dbHelper.updateProducto(Producto(
          id: widget.producto!.id,
          nombre: nombreController.text,
          idCategoria: int.parse(idCategoriaController.text),
          precioVenta: double.parse(precioVentaController.text),
        ));
      }
      // Navegar a la pantalla de inicio y remover la pantalla actual
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return const HomeScreen(index: 3);
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
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del producto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: idCategoriaController,
                decoration: InputDecoration(labelText: 'ID Categoría'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el ID de categoría';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: precioVentaController,
                decoration: InputDecoration(labelText: 'Precio de Venta'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el precio de venta';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProducto,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
