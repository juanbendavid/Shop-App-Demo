import 'package:flutter/material.dart';
import 'package:frontend_parcial2/database/databasehelper.dart';
import 'package:frontend_parcial2/models/models.dart';

class ConsultaVentaDetallesScreen extends StatelessWidget {
  final int idVenta;
  const ConsultaVentaDetallesScreen({super.key, required this.idVenta});

  @override
  Widget build(BuildContext context) {
    DatabaseHelper dbHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Venta'),
      ),
      body: FutureBuilder<List<DetalleVenta>>(
        future: dbHelper.getDetallesVenta(idVenta),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay detalles para esta venta.'));
          }

          final detalles = snapshot.data!;

          return ListView.builder(
            itemCount: detalles.length,
            itemBuilder: (context, index) {
              final detalle = detalles[index];
              return FutureBuilder<Producto>(
                future: dbHelper.getProductoFromId(detalle.idProducto),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    final producto = snapshot.data!;
                    return ListTile(
                      title: Text(producto.nombre),
                      subtitle: Text('Cantidad: ${detalle.cantidad}, Precio: \$${detalle.precio}'),
                    );
                  }
                  return const ListTile(
                    title: Text('Cargando producto...'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
