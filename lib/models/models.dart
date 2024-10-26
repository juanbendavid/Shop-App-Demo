class Categoria {
  int? id;
  String nombre;
  int idCategoria;

  Categoria({this.id, required this.nombre, required this.idCategoria});

  // Convertir a Map para operaciones CRUD
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'idCategoria': idCategoria,
    };
  }

  // Crear una instancia desde un Map (recuperar de la base de datos)
  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nombre: map['nombre'],
      idCategoria: map['idCategoria'],
    );
  }
}

class Producto {
  int? id;
  String nombre;
  int idCategoria;
  double precioVenta;

  Producto({this.id, required this.nombre, required this.idCategoria, required this.precioVenta});

  // Convertir a Map para operaciones CRUD
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'idCategoria': idCategoria,
      'precioVenta': precioVenta,
    };
  }

  // Crear una instancia desde un Map (recuperar de la base de datos)
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      nombre: map['nombre'],
      idCategoria: map['idCategoria'],
      precioVenta: map['precioVenta'],
    );
  }
}

class Cliente {
  int? idCliente;
  String cedula;
  String nombre;
  String apellido;

  Cliente({this.idCliente, required this.cedula, required this.nombre, required this.apellido});

  Map<String, dynamic> toMap() {
    return {
      'idCliente': idCliente,
      'cedula': cedula,
      'nombre': nombre,
      'apellido': apellido,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      idCliente: map['idCliente'],
      cedula: map['cedula'],
      nombre: map['nombre'],
      apellido: map['apellido'],
    );
  }
}
class Venta {
  int? idVenta;
  String fecha;
  int idCliente;
  double total;

  Venta({this.idVenta, required this.fecha, required this.idCliente, required this.total});

  Map<String, dynamic> toMap() {
    return {
      'idVenta': idVenta,
      'fecha': fecha,
      'idCliente': idCliente,
      'total': total,
    };
  }

  factory Venta.fromMap(Map<String, dynamic> map) {
    return Venta(
      idVenta: map['idVenta'],
      fecha: map['fecha'],
      idCliente: map['idCliente'],
      total: map['total'],
    );
  }
}

class DetalleVenta {
  int? idDetalleVenta;
  int idVenta;
  int idProducto;
  int cantidad;
  double precio;

  DetalleVenta({this.idDetalleVenta, required this.idVenta, required this.idProducto, required this.cantidad, required this.precio});

  Map<String, dynamic> toMap() {
    return {
      'idDetalleVenta': idDetalleVenta,
      'idVenta': idVenta,
      'idProducto': idProducto,
      'cantidad': cantidad,
      'precio': precio,
    };
  }

  factory DetalleVenta.fromMap(Map<String, dynamic> map) {
    return DetalleVenta(
      idDetalleVenta: map['idDetalleVenta'],
      idVenta: map['idVenta'],
      idProducto: map['idProducto'],
      cantidad: map['cantidad'],
      precio: map['precio'],
    );
  }
}
