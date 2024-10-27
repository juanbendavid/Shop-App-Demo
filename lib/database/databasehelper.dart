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
    await agregarDatosDePrueba();
    return _db!;
  }

  Future<Database> initDb() async {
    // primero eliminar la base de datos si existe
    await deleteDb();

    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'proveedores.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE categorias (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL
        )
      ''');

       await db.execute('''
        CREATE TABLE productos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL,
          idCategoria INTEGER NOT NULL,
          precioVenta INTEGER NOT NULL
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
    await insertCategoria(Categoria(nombre: 'Categoría A'));
    await insertCategoria(Categoria(nombre: 'Categoría B'));
    await insertProducto(Producto(nombre: 'Producto 1', idCategoria: 1, precioVenta: 10));
    await insertProducto(Producto(nombre: 'Producto 2', idCategoria: 2, precioVenta: 15));
   }

  // Crear una categoria
  Future<int> insertCategoria(Categoria categoria) async {
    var dbClient = await db;
    return await dbClient.insert('categorias', categoria.toMap());
  }

  // Leer todas las categorias
  Future<List<Categoria>> getCategorias() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query('categorias');
    return List.generate(maps.length, (i) {
      return Categoria.fromMap(maps[i]);
    });
  }
  // get categoria por id
  Future<Categoria> getCategoriaFromId(int id) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query('categorias', where: 'id = ?', whereArgs: [id]);
    return Categoria.fromMap(maps[0]);
  }

  // Actualizar categoria
  Future<int> updateCategoria(Categoria categoria) async {
    var dbClient = await db;
    return await dbClient.update('categorias', categoria.toMap(), where: 'id = ?', whereArgs: [categoria.id]);
  }

  // Eliminar categoria
  Future<int> deleteCategoria(int id) async {
    var dbClient = await db;
    return await dbClient.delete('categorias', where: 'id = ?', whereArgs: [id]);
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
      maps = await dbClient.query('productos', where: 'nombre LIKE ?', whereArgs: ['%$filtroNombre%']);
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

  // Leer todos los clientes (con filtro opcional por cédula)
  Future<List<Cliente>> getClientes({String? filtroCedula}) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps;

    if (filtroCedula != null && filtroCedula.isNotEmpty) {
      maps = await dbClient.query('Cliente',
          where: 'cedula LIKE ?', whereArgs: ['%$filtroCedula%']);
    } else {
      maps = await dbClient.query('Cliente');
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
    return await dbClient.delete('Cliente', where: 'idCliente = ?', whereArgs: [idCliente]);
  }

  // CRUD para Ventas
  // Crear una venta
  Future<int> insertVenta(Venta venta) async {
    var dbClient = await db;
    return await dbClient.insert('Venta', venta.toMap());
  }

  // Leer todas las ventas (con filtros opcionales)
  Future<List<Venta>> getVentas({String? filtroFecha, String? filtroCliente}) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (filtroFecha != null && filtroFecha.isNotEmpty) {
      whereClause += 'fecha LIKE ?';
      whereArgs.add('%$filtroFecha%');
    }

    if (filtroCliente != null && filtroCliente.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'idCliente IN (SELECT idCliente FROM Cliente WHERE nombre LIKE ? OR apellido LIKE ?)';
      whereArgs.add('%$filtroCliente%');
      whereArgs.add('%$filtroCliente%');
    }

    if (whereClause.isNotEmpty) {
      maps = await dbClient.query('Venta', where: whereClause, whereArgs: whereArgs);
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
    return await dbClient.delete('Venta', where: 'idVenta = ?', whereArgs: [idVenta]);
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
}

