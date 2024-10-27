import 'package:flutter/material.dart';
import 'package:frontend_parcial2/database/databasehelper.dart';
import 'package:frontend_parcial2/models/models.dart';

class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});

  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen> {
  List<Producto> productosDisponibles = [];
  List<Map<Producto, int>> carrito = [];
  String filtroNombre = '';
  String? filtroCategoria; // Almacena la categoría seleccionada
  TextEditingController filtroNombreController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper();

  // Lista de categorías disponibles para los chips
  final List<String> categoriasDisponibles = ['Categoría A', 'Categoría B'];

  @override
  void initState() {
    super.initState();
    _getProductos();
  }

  void _getProductos() async {
    var data = await dbHelper.getProductos(
      filtroNombre: filtroNombre,
    );
    setState(() {
      productosDisponibles = data;
    });
  }

  // Función para agregar un producto al carrito
  void _agregarAlCarrito(Producto producto) {
    int index = carrito.indexWhere((item) => item.keys.first.id == producto.id);
    if (index == -1) {
      // Producto no está en el carrito, agregarlo con cantidad inicial de 1
      carrito.add({producto: 1});
    } else {
      // Producto ya está en el carrito, incrementar la cantidad
      carrito[index][producto] = carrito[index][producto]! + 1;
    }
    setState(() {});
  }

  // Función para mostrar el dialogo de resumen del carrito
  void _mostrarCarrito() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Carrito'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: carrito.length,
              itemBuilder: (context, index) {
                final producto = carrito[index].keys.first;
                final cantidad = carrito[index][producto]!;
                return ListTile(
                  title: Text('${producto.nombre} x$cantidad'),
                  subtitle: Text('Precio unitario: \$${producto.precioVenta}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_shopping_cart),
                    onPressed: () {
                      setState(() {
                        carrito.removeAt(index);
                      });
                      Navigator.pop(context);
                      _mostrarCarrito(); // Actualizar el diálogo del carrito
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: _finalizarOrden,
              child: const Text('Finalizar Orden'),
            ),
          ],
        );
      },
    );
  }

  // Función para finalizar la orden y solicitar datos del cliente
  void _finalizarOrden() {
    Navigator.pop(context); // Cerrar el diálogo del carrito
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController cedulaController = TextEditingController();
        TextEditingController nombreController = TextEditingController();
        TextEditingController apellidoController = TextEditingController();

        return AlertDialog(
          title: const Text('Finalizar Orden'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: cedulaController,
                decoration: const InputDecoration(labelText: 'Cédula'),
              ),
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextFormField(
                controller: apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Aquí debes manejar la lógica para guardar la venta y el cliente
                // Implementa la lógica de almacenamiento en la base de datos
                Navigator.pop(context); // Cerrar el diálogo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Orden finalizada')),
                );
                setState(() {
                  carrito.clear(); // Vaciar el carrito después de finalizar la orden
                });
              },
              child: const Text('Guardar Orden'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: filtroNombreController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          filtroNombre = filtroNombreController.text;
                          _getProductos(); // Actualiza la lista de productos con el filtro
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  children: categoriasDisponibles.map((categoria) {
                    return ChoiceChip(
                      label: Text(categoria),
                      selected: filtroCategoria == categoria,
                      onSelected: (bool selected) {
                        setState(() {
                          filtroCategoria = selected ? categoria : null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: productosDisponibles.length,
              itemBuilder: (context, index) {
                final producto = productosDisponibles[index];
                if ((filtroNombre.isNotEmpty &&
                        !producto.nombre
                            .toLowerCase()
                            .contains(filtroNombre.toLowerCase())) ||
                    (filtroCategoria != null &&
                        producto.idCategoria != categoriasDisponibles.indexOf(filtroCategoria!) + 1)) {
                  return Container(); // Ocultar productos que no coincidan con el filtro
                }
                return ListTile(
                  title: Text(producto.nombre),
                  subtitle: Text('Categoría: ${producto.idCategoria}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () => _agregarAlCarrito(producto),
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
