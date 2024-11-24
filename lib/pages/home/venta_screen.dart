import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_parcial2/config/google_maps_direction.dart';
import 'package:frontend_parcial2/config/icons_mapping.dart';
import 'package:frontend_parcial2/database/databasehelper.dart';
import 'package:frontend_parcial2/models/models.dart';
import 'package:intl/intl.dart';

class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});

  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen> with SingleTickerProviderStateMixin {
  List<Producto> productosDisponibles = [];
  List<Map<Producto, int>> carrito = [];
  String filtroNombre = '';
  Categoria? filtroCategoria; // Almacena la categoría seleccionada
  TextEditingController filtroNombreController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper();

  // Controladores para los datos del cliente
  TextEditingController cedulaController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController apellidoController = TextEditingController();
  TextEditingController direccionController = TextEditingController();

  // Lista para mostrar clientes encontrados durante la búsqueda
  List<Cliente> clientesEncontrados = [];
  Cliente? clienteSeleccionado;
  double? latitude;
  double? longitude;

  // Lista de categorías disponibles para los chips
  List<Categoria> categoriasDisponibles = [];
  late TabController tabController;


  @override
  void initState() {
    super.initState();
    _getProductos();
    _getCategorias();
    tabController = TabController(length: 2, vsync: this); // Inicializarlo
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        // Capturar el índice seleccionado
        print('Tab seleccionado: ${tabController.index}');
      }
    });

  }

  void _getProductos() async {
    var data = await dbHelper.getProductos(
      filtroNombre: filtroNombre,
    );
    setState(() {
      productosDisponibles = data;
    });
  }

  // Función para buscar cliente por cédula
  void _buscarClientePorCedula(String cedula) async {
    var clientes = await dbHelper.getClientes(query: cedula);
    if (clientes.isNotEmpty) {
      var cliente = clientes.first;
      setState(() {
        nombreController.text = cliente.nombre;
        apellidoController.text = cliente.apellido;
      });
    } else {
      // Si no se encuentra el cliente, limpiar los campos
      setState(() {
        nombreController.clear();
        apellidoController.clear();
      });
    }
  }

  // Función para agregar o actualizar la cantidad de un producto en el carrito
  void _actualizarCantidad(Producto producto, int cantidad) {
    int index = carrito.indexWhere((item) => item.keys.first.id == producto.id);
    if (index == -1) {
      // Producto no está en el carrito, agregarlo con la cantidad seleccionada
      carrito.add({producto: cantidad});
    } else {
      // Producto ya está en el carrito, actualizar la cantidad
      carrito[index][producto] = cantidad;
    }
    setState(() {});
  }

  // Obtener la cantidad seleccionada de un producto
  int _obtenerCantidad(Producto producto) {
    int index = carrito.indexWhere((item) => item.keys.first.id == producto.id);
    if (index != -1) {
      return carrito[index][producto]!;
    }
    return 0;
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

  // Función para seleccionar un cliente de la lista
  void _seleccionarCliente(Cliente cliente) {
    setState(() {
      clienteSeleccionado = cliente;
      cedulaController.text = cliente.cedula;
      nombreController.text = cliente.nombre;
      apellidoController.text = cliente.apellido;
      clientesEncontrados =
          []; // Limpiar la lista de búsqueda después de seleccionar
    });
  }

  // Función para finalizar la orden y solicitar datos del cliente
  void _finalizarOrden() {
    Navigator.pop(context); // Cerrar el diálogo del carrito
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Finalizar Orden'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input para cédula con búsqueda en tiempo real
              TextFormField(
                controller: cedulaController,
                decoration: const InputDecoration(labelText: 'Cédula'),
                onChanged: (value) {
                  _buscarClientePorCedula(value);
                },
              ),
              // Dropdown de opciones de clientes encontrados
              if (clientesEncontrados.isNotEmpty)
                DropdownButton<Cliente>(
                  isExpanded: true,
                  hint: const Text('Selecciona un cliente'),
                  items: clientesEncontrados.map((cliente) {
                    return DropdownMenuItem<Cliente>(
                      value: cliente,
                      child: Text(
                          '${cliente.cedula} - ${cliente.nombre} ${cliente.apellido}'),
                    );
                  }).toList(),
                  onChanged: (cliente) {
                    if (cliente != null) {
                      _seleccionarCliente(cliente);
                    }
                  },
                ),
              // Input para nombre con búsqueda en tiempo real
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              // Input para apellido con búsqueda en tiempo real
              TextFormField(
                controller: apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
              ),
              // switch para Delivery o pick up
              // Row(
              //   children: [
              //     const Text('Delivery'),
              //     Switch(
              //       value: false,
              //       onChanged: (value) {
              //         // Implementar lógica para habilitar/deshabilitar campos de dirección
              //       },
              //     ),
              //   ],
              // ),
               DefaultTabController(
                length: 2,
                child: TabBar(
                  controller:tabController,
                  onTap: (value) {
                    print(value);
                  },
                  tabs: const [
                  Tab(text: 'Pick up',),
                  Tab(text: 'Delivery'),
                ]),
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
                _guardarVenta(); // Llamar a la función para guardar la venta
                // Navigator.pop(context); // Cerrar el diálogo
                setState(() {
                  carrito
                      .clear(); // Vaciar el carrito después de finalizar la orden
                });
              },
              child: const Text('Guardar Orden'),
            ),
          ],
        );
      },
    );
  }

  // Función para finalizar la orden y guardar la venta en la base de datos
  void _guardarVenta() async {
    final carritoCopy = [...carrito];
    print('Guardando venta...');
    print(tabController.index);
    bool? resultMap;
    if (tabController.index == 1) {
      print('Tab seleccionado: ${tabController.index}');
      // abrir dialogo para ingresar dirección y mapa
      // Navigator.pop(context); // Cerrar el diálogo del carrito
      resultMap= await showModalBottomSheet<bool>(
        enableDrag: true,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.95,
            child: Container(
              height: 500,
              child: Column(
                children: [
                  const Text('Dirección de entrega'),
                  const SizedBox(height: 10),
                  GoogleMapsView(
                    getDatosGeograficosCallBack: (double lat, double long, String calle1, String calle2) async{
                    print('Latitud: $lat, Longitud: $long');
                    print('Calle 1: $calle1, Calle 2: $calle2');
                    latitude = long;
                    longitude = lat;

                  }),
                  TextField(
                    controller: direccionController,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (latitude == null || longitude == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selecciona una ubicación en el mapa')),
                        );
                        return;
                      }
                      if (direccionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ingresa una dirección')),
                        );
                        return;
                      }
                      Navigator.pop(context, true);
                    },
                    child: const Text('Guardar Orden'),
                  ),
                ],
              ),
            ),
          );
        },
      );

    }

    if (resultMap != null && !resultMap) {
      return;
    }
    
    // Verificar que el carrito no esté vacío
    if (carritoCopy.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito no puede estar vacío')),
      );
    }
    

    // 1. Verificar si el cliente existe o crear uno nuevo
    String cedula = cedulaController.text;
    String nombre = nombreController.text;
    String apellido = apellidoController.text;
    String direccion = direccionController.text;

    Cliente? clienteExistente;
    var clientes = await  dbHelper.getClientes(query: cedula);
    if (clientes.isNotEmpty) {
      clienteExistente = clientes.first;
    } else {
      // Si no existe el cliente, crearlo
      clienteExistente =
          Cliente(cedula: cedula, nombre: nombre, apellido: apellido);
      clienteExistente.idCliente =
          await dbHelper.insertCliente(clienteExistente);
    }

    // Calcular el total de la venta
    int total = 0;
    for (var item in carritoCopy) {
      final producto = item.keys.first;
      final cantidad = item[producto] ?? 0;
      total += producto.precioVenta * cantidad;
    }

    // Crear la venta
    String fechaActual = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Venta nuevaVenta = Venta(
      fecha: fechaActual,
      idCliente: clienteExistente.idCliente!,
      total: total,
      tipoOperacion: tabController.index == 0 ? 'PICKUP' : 'DELIVERY',
      latitude: tabController.index == 1? latitude:null,
      longitude: tabController.index == 1? longitude:null,
      direccion: tabController.index == 1? direccion:null,
    );
    int idVenta = await dbHelper.insertVenta(nuevaVenta);

    // Guardar detalles de la venta
    for (var item in carritoCopy) {
      final producto = item.keys.first;
      final cantidad = item[producto] ?? 0;
      DetalleVenta detalle = DetalleVenta(
        idVenta: idVenta,
        idProducto: producto.id!,
        cantidad: cantidad,
        precio: producto.precioVenta,
      );
      await dbHelper.insertDetalleVenta(detalle);
    }
    // Actualizar la cantidad de productos en la base de datos
    for (var item in carritoCopy) {
      final producto = item.keys.first;
      final cantidad = item[producto] ?? 0;
      producto.cantidadExistente -= cantidad;
      await dbHelper.updateProducto(producto);
    }

    // Mostrar mensaje de éxito y limpiar carrito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Venta guardada exitosamente')),
    );
    setState(() {
      carrito.clear(); // Limpiar el carrito después de guardar la venta
    });
    // if (tabController.index == 1) {
      Navigator.pop(context); // Cerrar el diálogo
    // }
  }

  // Cargar categorías disponibles desde la base de datos
  void _getCategorias() async {
    var data = await dbHelper.getCategorias();
    setState(() {
      categoriasDisponibles = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarCarrito,
        child: const Icon(Icons.shopping_cart),
      ),
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8.0,
                    children: categoriasDisponibles.map((categoria) {
                      return ChoiceChip(
                        label: Row(
                          children: [
                            IconsMapping.iconMap[categoria.icono] != null
                                ? Icon(IconsMapping.iconMap[categoria.icono])
                                : const Icon(Icons.category),
                            const SizedBox(width: 4),
                            Text(categoria.nombre),
                          ],
                        ),
                        selected: filtroCategoria == categoria,
                        onSelected: (bool selected) {
                          setState(() {
                            filtroCategoria = selected ? categoria : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: productosDisponibles.length,
              itemBuilder: (context, index) {
                final producto = productosDisponibles[index];
                int cantidadSeleccionada = _obtenerCantidad(producto);
                if ((filtroNombre.isNotEmpty &&
                        !producto.nombre
                            .toLowerCase()
                            .contains(filtroNombre.toLowerCase())) ||
                    (filtroCategoria != null &&
                        producto.idCategoria != filtroCategoria!.id)) {
                  return Container(); // Ocultar productos que no coincidan con el filtro
                }
                return ListTile(
                  title: Row(
                    children: [
                      producto.imagen != null
                      ? Image.file(File(producto.imagen!), width: 55, height: 55, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold),),
                          Text('Categoría: ${producto.idCategoria}'),
                          Text('Cantidad: ${producto.cantidadExistente}'),
                        ],
                      ),
                    ],
                  ),
                  // subtitle: Text('Categoría: ${producto.idCategoria}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (cantidadSeleccionada > 0) {
                            _actualizarCantidad(
                                producto, cantidadSeleccionada - 1);
                          }
                        },
                      ),
                      Text('$cantidadSeleccionada'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final resuult = validarCantidadDisponible(producto, cantidadSeleccionada);
                          if (!resuult) return;
                          _actualizarCantidad(
                              producto, cantidadSeleccionada + 1);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  bool validarCantidadDisponible(Producto producto, int cantidadSeleccionada) {
    if (cantidadSeleccionada >= producto.cantidadExistente) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay suficiente stock'), duration: Duration(milliseconds: 500),),
      );
      return false;
    }else{
      return true;
    }
  }
}
