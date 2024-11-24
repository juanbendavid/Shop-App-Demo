import 'package:flutter/material.dart';
import 'package:frontend_parcial2/config/funciones.dart';
import 'package:intl/intl.dart';
import 'package:frontend_parcial2/database/databasehelper.dart';
import 'package:frontend_parcial2/models/models.dart';
import 'package:frontend_parcial2/pages/consuta%20ventas/consulta_venta_detalles_screen.dart';

class ConsultaVentaScreen extends StatefulWidget {
  const ConsultaVentaScreen({super.key});

  @override
  State<ConsultaVentaScreen> createState() => _ConsultaVentaScreenState();
}

class _ConsultaVentaScreenState extends State<ConsultaVentaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Venta> ventasDelivery = [];
  List<Venta> ventasPickup = [];
  TextEditingController filtroController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getVentas();
  }

  // Obtener ventas y dividirlas entre DELIVERY y PICKUP
  void _getVentas({String? filtro, String? filtroFecha}) async {
    var data = await dbHelper.getVentas(filtroCliente: filtro, filtroFecha: filtroFecha);
    setState(() {
      ventasDelivery = data.where((venta) => venta.tipoOperacion == 'DELIVERY').toList();
      ventasPickup = data.where((venta) => venta.tipoOperacion == 'PICKUP').toList();
    });
  }

  // Mostrar DatePicker y filtrar por fecha seleccionada
  void _mostrarDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
        _getVentas(filtroFecha: formattedDate);
      });
    }
  }

  // Widget para construir la lista de ventas
  Widget _buildVentasList(List<Venta> ventas) {
    if (ventas.isEmpty) {
      return const Center(child: Text('No hay ventas disponibles.'));
    }

    return ListView.builder(
      itemCount: ventas.length,
      itemBuilder: (context, index) {
        final venta = ventas[index];
        return ListTile(
          subtitle: Text('Fecha: ${venta.fecha}'),
          title: FutureBuilder<Cliente>(
            future: dbHelper.getClienteFromId(venta.idCliente),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  final cliente = snapshot.data!;
                  return Text(
                    'Cliente: ${cliente.nombre} ${cliente.apellido} - Total: Gs. ${formatNumber(venta.total)}',
                  );
                }
              }
              return const Text('Cargando cliente...');
            },
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConsultaVentaDetallesScreen(venta: venta),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Ventas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pickup'),
            Tab(text: 'Delivery'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: filtroController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nombre, apellido o cédula',
                    ),
                    onChanged: (value) {
                      _getVentas(filtro: value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: _mostrarDatePicker,
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVentasList(ventasPickup),
                _buildVentasList(ventasDelivery),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
