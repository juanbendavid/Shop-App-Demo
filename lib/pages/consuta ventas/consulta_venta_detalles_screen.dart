import 'package:flutter/material.dart';
import 'package:frontend_parcial2/config/funciones.dart';
import 'package:frontend_parcial2/config/google_maps_direction.dart';
import 'package:frontend_parcial2/database/databasehelper.dart';
import 'package:frontend_parcial2/models/models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ConsultaVentasScreen extends StatefulWidget {
  @override
  _ConsultaVentasScreenState createState() => _ConsultaVentasScreenState();
}

class _ConsultaVentasScreenState extends State<ConsultaVentasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Dos pestañas
  }

  Future<List<Venta>> _fetchVentas(String tipoOperacion) async {
    final ventas = await dbHelper.getVentas();
    return ventas.where((venta) => venta.tipoOperacion == tipoOperacion).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas por Tipo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pickup'),
            Tab(text: 'Delivery'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVentasList('PICKUP'),
          _buildVentasList('DELIVERY'),
        ],
      ),
    );
  }

  Widget _buildVentasList(String tipoOperacion) {
    return FutureBuilder<List<Venta>>(
      future: _fetchVentas(tipoOperacion),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No hay ventas de tipo $tipoOperacion.',
              style: const TextStyle(fontSize: 16),
            ),
          );
        }

        final ventas = snapshot.data!;
        return ListView.builder(
          itemCount: ventas.length,
          itemBuilder: (context, index) {
            final venta = ventas[index];
            return ListTile(
              title: Text('Venta ID: ${venta.idVenta}'),
              subtitle: Text('Total: Gs. ${formatNumber(venta.total)}'),
              trailing: Text(tipoOperacion),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConsultaVentaDetallesScreen(venta: venta),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class ConsultaVentaDetallesScreen extends StatelessWidget {
  final Venta venta;
  const ConsultaVentaDetallesScreen({super.key, required this.venta});

  @override
  Widget build(BuildContext context) {
    DatabaseHelper dbHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Venta'),
      ),
      body: FutureBuilder<List<DetalleVenta>>(
        future: dbHelper.getDetallesVenta(venta.idVenta!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay detalles para esta venta.'));
          }

          final detalles = snapshot.data!;
          return Column(
            children: [
              Flexible(
                child: ListView.builder(
                  itemCount: detalles.length,
                  itemBuilder: (context, index) {
                    final detalle = detalles[index];
                    return FutureBuilder<Producto>(
                      future: dbHelper.getProductoFromId(detalle.idProducto),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          final producto = snapshot.data!;
                          return ListTile(
                            title: Text(producto.nombre),
                            subtitle: Text(
                              'Cantidad: ${detalle.cantidad}, Precio: Gs. ${formatNumber(detalle.precio)}',
                            ),
                          );
                        }
                        return const ListTile(
                          title: Text('Cargando producto...'),
                        );
                      },
                    );
                  },
                ),
              ),
              if (venta.tipoOperacion == "DELIVERY")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('Dirección de entrega: ${venta.direccion}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              if (venta.tipoOperacion == 'DELIVERY')
                GoogleMapsView(
                  ventaPosition: CameraPosition(
                    target: LatLng(venta.latitude!, venta.longitude!),
                    zoom: 15,
                  ),
                  getDatosGeograficosCallBack: (coordenadaX, coordenadaY, calle1, calle2) async {
                    print('Coordenadas: $coordenadaX, $coordenadaY');
                  },
                ),
              
            ],
          );
        },
      ),
    );
  }
}
