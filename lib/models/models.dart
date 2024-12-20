class Categoria {
  int? id;
  String nombre;
  String icono;

  Categoria({this.id, required this.nombre, this.icono = ''});

  // Convertir a Map para operaciones CRUD
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'icono': icono,
    };
  }

  // Crear una instancia desde un Map (recuperar de la base de datos)
  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nombre: map['nombre'],
      icono: map['icono'],
    );
  }
}

class Producto {
  int? id;
  String nombre;
  int idCategoria;
  int precioVenta;
  String imagen;
  int cantidadExistente;

  Producto({this.id, required this.nombre, required this.idCategoria, required this.precioVenta, this.imagen = '', this.cantidadExistente = 0});

  // Convertir a Map para operaciones CRUD
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'idCategoria': idCategoria,
      'precioVenta': precioVenta,
      'imagen': imagen,
      'cantidadExistente': cantidadExistente,
    };
  }

  // Crear una instancia desde un Map (recuperar de la base de datos)
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      nombre: map['nombre'],
      idCategoria: map['idCategoria'],
      precioVenta: map['precioVenta'],
      imagen: map['imagen'],
      cantidadExistente: map['cantidadExistente'],
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
  int total;
  String tipoOperacion;
  double? latitude;
  double? longitude;
  String? direccion;

  Venta({this.idVenta, required this.fecha, required this.idCliente, required this.total,required this.tipoOperacion, this.latitude, this.longitude, this.direccion});

  Map<String, dynamic> toMap() {
    return {
      'idVenta': idVenta,
      'fecha': fecha,
      'idCliente': idCliente,
      'total': total,
      'tipoOperacion': tipoOperacion,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'direccion': direccion,
    };
  }

  factory Venta.fromMap(Map<String, dynamic> map) {
    return Venta(
      idVenta: map['idVenta'],
      fecha: map['fecha'],
      idCliente: map['idCliente'],
      total: map['total'],
      tipoOperacion: map['tipoOperacion'],
      latitude: map['latitude']!=null? double.parse(map['latitude']):null,
      longitude: map['longitude']!=null? double.parse(map['longitude']):null,
      direccion: map['direccion'],
    );
  }
}

class DetalleVenta {
  int? idDetalleVenta;
  int idVenta;
  int idProducto;
  int cantidad;
  int precio;

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
