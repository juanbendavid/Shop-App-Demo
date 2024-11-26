import 'package:frontend_parcial2/models/models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    // primero eliminar la base de datos si existe
    // await deleteDb();

    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'proveedores.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE categorias (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL,
          icono TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE productos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL,
          idCategoria INTEGER NOT NULL,
          precioVenta INTEGER NOT NULL,
          cantidadExistente INTEGER NOT NULL,
          imagen TEXT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE Cliente (
          idCliente INTEGER PRIMARY KEY AUTOINCREMENT,
          cedula TEXT NOT NULL UNIQUE,
          nombre TEXT NOT NULL,
          apellido TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE Venta (
          idVenta INTEGER PRIMARY KEY AUTOINCREMENT,
          fecha TEXT NOT NULL,
          idCliente INTEGER NOT NULL,
          total INTEGER NOT NULL,
          tipoOperacion TEXT NOT NULL,
          latitude TEXT,
          longitude TEXT,
          direccion TEXT,
          FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
        )
      ''');

      await db.execute('''
        CREATE TABLE DetalleVenta (
          idDetalleVenta INTEGER PRIMARY KEY AUTOINCREMENT,
          idVenta INTEGER NOT NULL,
          idProducto INTEGER NOT NULL,
          cantidad INTEGER NOT NULL,
          precio INTEGER NOT NULL,
          FOREIGN KEY (idVenta) REFERENCES Venta(idVenta)
        )
      ''');
    });
  }

  // Función para borrar la base de datos
  Future<void> deleteDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "proveedores.db");
    await deleteDatabase(path);
  }

  // agregar categorias y productos de prueba al iniciar la app
  Future<void> agregarDatosDePrueba() async {
    var categoriasExistentes = await getCategorias();
    var clientesExistentes = await getClientes();

    // Verificar si ya existen categorías de prueba antes de insertarlas
    if (categoriasExistentes.isEmpty) {
      await insertCategoria(Categoria(nombre: 'Smartphones'));
      await insertCategoria(Categoria(nombre: 'Laptops'));
      await insertCategoria(Categoria(nombre: 'Accesorios'));
      await insertCategoria(Categoria(nombre: 'Tablets'));
      await insertCategoria(Categoria(nombre: 'Smartwatches'));
      await insertCategoria(Categoria(nombre: 'Monitores'));
    }

    // Verificar si ya existen productos de prueba antes de insertarlos
    var productosExistentes = await getProductos();
    if (productosExistentes.isEmpty) {
      await insertProducto(Producto(
          nombre: 'Computadora', idCategoria: 2, precioVenta: 15000000));
      await insertProducto(Producto(
          nombre: 'Iphone 16 Pro Max', idCategoria: 1, precioVenta: 8000000));
      await insertProducto(Producto(
          nombre: 'Samsung S23 Ultra', idCategoria: 1, precioVenta: 7000000));
      await insertProducto(Producto(
          nombre: 'Samsung Tab S9', idCategoria: 4, precioVenta: 3000000));
      await insertProducto(Producto(
          nombre: 'Apple Watch Series 9',
          idCategoria: 3,
          precioVenta: 1500000));
      await insertProducto(Producto(
          nombre: 'Samsung Buds 2', idCategoria: 3, precioVenta: 1000000));
      await insertProducto(Producto(
          nombre: 'Monitor Samsung', idCategoria: 6, precioVenta: 1000000));
    }

    // Verificar si ya existen clientes de prueba antes de insertarlos
    if (clientesExistentes.isEmpty) {
      await insertCliente(
          Cliente(cedula: '5611898', nombre: 'Juan', apellido: 'David'));
      await insertCliente(
          Cliente(cedula: '5738080', nombre: 'Fabrizio', apellido: 'Román'));
      await insertCliente(
          Cliente(cedula: '5425495', nombre: 'Esteban', apellido: 'Fernandez'));
    }
  }

  // Crear una categoria
  Future<int> insertCategoria(Categoria categoria) async {
    var dbClient = await db;
    return await dbClient.insert('categorias', categoria.toMap());
  }

  Future<List<Categoria>> getCategorias({String? filtroNombre}) async {
  var dbClient = await db;
  List<Map<String, dynamic>> maps = await dbClient.query('categorias');

  // Filtrar las categorías si filtroNombre no es null y no está vacío
  if (filtroNombre != null && filtroNombre.isNotEmpty) {
    maps = maps.where((map) => 
      map['nombre'].toString().toLowerCase().contains(filtroNombre.toLowerCase())
    ).toList();
  }

  // Generar la lista de categorías basada en el filtro
  return List.generate(maps.length, (i) {
    return Categoria.fromMap(maps[i]);
  });
}


  // get categoria por id
  Future<Categoria> getCategoriaFromId(int id) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps =
        await dbClient.query('categorias', where: 'id = ?', whereArgs: [id]);
    return Categoria.fromMap(maps[0]);
  }

  // Actualizar categoria
  Future<int> updateCategoria(Categoria categoria) async {
    var dbClient = await db;
    return await dbClient.update('categorias', categoria.toMap(),
        where: 'id = ?', whereArgs: [categoria.id]);
  }

  // Eliminar categoria
  Future<int> deleteCategoria(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete('categorias', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD PRODUCTOS
  // Crear un producto
  Future<int> insertProducto(Producto producto) async {
    var dbClient = await db;
    return await dbClient.insert('productos', producto.toMap());
  }

  // Leer todos los productos con filtro opcional por nombre
  Future<List<Producto>> getProductos({String? filtroNombre}) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps;

    // filtrar por nombre y categoria
    if (filtroNombre != null && filtroNombre.isNotEmpty) {
      maps = await dbClient.query('productos',
          where: 'nombre LIKE ?', whereArgs: ['%$filtroNombre%']);
    } else {
      maps = await dbClient.query('productos');
    }

    return List.generate(maps.length, (i) {
      return Producto.fromMap(maps[i]);
    });
  }

  // Actualizar producto
  Future<int> updateProducto(Producto producto) async {
    var dbClient = await db;
    return await dbClient.update('productos', producto.toMap(),
        where: 'id = ?', whereArgs: [producto.id]);
  }

  // Eliminar producto
  Future<int> deleteProducto(int id) async {
    var dbClient = await db;
    return await dbClient.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD para Clientes
  // Crear un cliente
  Future<int> insertCliente(Cliente cliente) async {
    var dbClient = await db;
    return await dbClient.insert('Cliente', cliente.toMap());
  }

  // Leer todos los clientes (con filtro opcional por cédula, nombre y apellido)
  Future<List<Cliente>> getClientes({String? query}) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps;

    if (query != null && query.isNotEmpty) {
      // Verificar si el query es numérico (para búsqueda exacta por cédula)
      if (RegExp(r'^[0-9]+$').hasMatch(query)) {
        // Si el query es numérico, buscar por cédula exacta
        maps = await dbClient
            .query('Cliente', where: 'cedula = ?', whereArgs: [query]);
      } else {
        // Si el query es texto, buscar primero por nombre y luego por apellido si no hay resultados
        maps = await dbClient
            .query('Cliente', where: 'nombre LIKE ?', whereArgs: ['%$query%']);

        if (maps.isEmpty) {
          // Si no hay resultados por nombre, buscar por apellido
          maps = await dbClient.query('Cliente',
              where: 'apellido LIKE ?', whereArgs: ['%$query%']);
        }
      }
    } else {
      maps = [];
    }

    return List.generate(maps.length, (i) {
      return Cliente.fromMap(maps[i]);
    });
  }

  // Actualizar cliente
  Future<int> updateCliente(Cliente cliente) async {
    var dbClient = await db;
    return await dbClient.update('Cliente', cliente.toMap(),
        where: 'idCliente = ?', whereArgs: [cliente.idCliente]);
  }

  // Eliminar cliente
  Future<int> deleteCliente(int idCliente) async {
    var dbClient = await db;
    return await dbClient
        .delete('Cliente', where: 'idCliente = ?', whereArgs: [idCliente]);
  }

  // CRUD para Ventas
  // Crear una venta
  Future<int> insertVenta(Venta venta) async {
    var dbClient = await db;
    return await dbClient.insert('Venta', venta.toMap());
  }

// Leer todas las ventas (con filtros opcionales)
  Future<List<Venta>> getVentas(
      {String? filtroFecha, String? filtroCliente}) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    // Verificar si el filtro es numérico para buscar solo por cédula
    if (filtroCliente != null && filtroCliente.isNotEmpty) {
      if (RegExp(r'^[0-9]+$').hasMatch(filtroCliente)) {
        // Si el filtro es un número, buscar por cédula exacta
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause +=
            'idCliente IN (SELECT idCliente FROM Cliente WHERE cedula = ?)';
        whereArgs.add(filtroCliente);
      } else {
        // Si no es numérico, buscar por nombre o apellido
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause +=
            'idCliente IN (SELECT idCliente FROM Cliente WHERE nombre LIKE ? OR apellido LIKE ?)';
        whereArgs.add('%$filtroCliente%');
        whereArgs.add('%$filtroCliente%');
      }
    }

    if (filtroFecha != null && filtroFecha.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'fecha = ?';
      whereArgs.add(filtroFecha);
    }

    if (whereClause.isNotEmpty) {
      maps = await dbClient.query('Venta',
          where: whereClause, whereArgs: whereArgs);
    } else {
      maps = await dbClient.query('Venta');
    }

    return List.generate(maps.length, (i) {
      return Venta.fromMap(maps[i]);
    });
  }

  // Actualizar venta
  Future<int> updateVenta(Venta venta) async {
    var dbClient = await db;
    return await dbClient.update('Venta', venta.toMap(),
        where: 'idVenta = ?', whereArgs: [venta.idVenta]);
  }

  // Eliminar venta
  Future<int> deleteVenta(int idVenta) async {
    var dbClient = await db;
    return await dbClient
        .delete('Venta', where: 'idVenta = ?', whereArgs: [idVenta]);
  }

  // CRUD para DetalleVenta
  // Crear un detalle de venta
  Future<int> insertDetalleVenta(DetalleVenta detalle) async {
    var dbClient = await db;
    return await dbClient.insert('DetalleVenta', detalle.toMap());
  }

  // Leer detalles de una venta específica
  Future<List<DetalleVenta>> getDetallesVenta(int idVenta) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(
      'DetalleVenta',
      where: 'idVenta = ?',
      whereArgs: [idVenta],
    );

    return List.generate(maps.length, (i) {
      return DetalleVenta.fromMap(maps[i]);
    });
  }

  Future<Producto> getProductoFromId(int idProducto) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient
        .query('productos', where: 'id = ?', whereArgs: [idProducto]);
    return Producto.fromMap(maps[0]);
  }

  Future<Cliente> getClienteFromId(int idCliente) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient
        .query('Cliente', where: 'idCliente = ?', whereArgs: [idCliente]);
    return Cliente.fromMap(maps[0]);
  }
}
