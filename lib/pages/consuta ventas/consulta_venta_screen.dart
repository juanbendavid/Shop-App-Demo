import 'package:flutter/material.dart';
import 'package:frontend_parcial2/database/databasehelper.dart';
import 'package:frontend_parcial2/models/models.dart';
import 'package:frontend_parcial2/pages/consuta%20ventas/consulta_venta_detalles_screen.dart';

class ConsultaVentaScreen extends StatefulWidget {
  const ConsultaVentaScreen({super.key});

  @override
  State<ConsultaVentaScreen> createState() => _ConsultaVentaScreenState();
}

class _ConsultaVentaScreenState extends State<ConsultaVentaScreen> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Venta> ventas = [];
  TextEditingController filtroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getVentas();
  }

  // Función para obtener las ventas con filtro
  void _getVentas({String? filtro}) async {
    var data = await dbHelper.getVentas(filtroCliente: filtro);
    setState(() {
      ventas = data;
    });
  }

  // Navegar a la pantalla de detalles de la venta
  void _verDetallesVenta(int idVenta) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return ConsultaVentaDetallesScreen(idVenta: idVenta);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Ventas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: filtroController,
              decoration: InputDecoration(
                labelText: 'Buscar por fecha, nombre, apellido o cédula',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _getVentas(filtro: filtroController.text);
                  },
                ),
              ),
              onChanged: (value) {
                _getVentas(filtro: value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: ventas.length,
              itemBuilder: (context, index) {
                final venta = ventas[index];
                return ListTile(
                  title: Text('Fecha: ${venta.fecha}'),
                  subtitle: FutureBuilder<Cliente>(
                    future: dbHelper.getClienteFromId(venta.idCliente),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          final cliente = snapshot.data!;
                          return Text('Cliente: ${cliente.nombre} ${cliente.apellido} - Total: \$${venta.total}');
                        }
                      }
                      return const Text('Cargando cliente...');
                    },
                  ),
                  onTap: () => _verDetallesVenta(venta.idVenta!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
