import 'package:flutter/material.dart';
import 'package:frontend_parcial2/config/funciones.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl en tu pubspec.yaml para formatear fechas
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
  DateTime? selectedDate; // Fecha seleccionada

  @override
  void initState() {
    super.initState();
    _getVentas();
  }

  // Función para obtener las ventas con filtro
  void _getVentas({String? filtro, String? filtroFecha}) async {
    var data = await dbHelper.getVentas(filtroCliente: filtro, filtroFecha: filtroFecha);
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

  // Función para mostrar el DatePicker y filtrar por fecha seleccionada
  void _mostrarDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // Fecha mínima
      lastDate: DateTime.now(),  // Fecha máxima
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        // Formatear la fecha seleccionada a 'yyyy-MM-dd' (para comparar en la base de datos)
        String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
        _getVentas(filtroFecha: formattedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Usar Expanded para que el TextField ocupe el espacio disponible
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
                // Icono para abrir el DatePicker
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: _mostrarDatePicker,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
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
                          return Text('Cliente: ${cliente.nombre} ${cliente.apellido} - Total: Gs. ${formatNumber(venta.total)}');
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
