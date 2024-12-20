import 'package:flutter/material.dart';
import 'package:frontend_parcial2/config/constantes.dart';
import 'package:frontend_parcial2/pages/consuta%20ventas/consulta_venta_screen.dart';
import 'package:frontend_parcial2/pages/home/venta_screen.dart';
import 'package:frontend_parcial2/pages/productos/producto_form_screen.dart';
import 'package:frontend_parcial2/pages/productos/productos_list_screen.dart';
import 'package:frontend_parcial2/pages/categorias/categorias.dart';
import 'package:frontend_parcial2/pages/categorias/categorias_form_screen.dart';

class HomeScreen extends StatefulWidget {
  final int? index;
  const HomeScreen({super.key, this.index});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  // Lista de las pantallas para cada pestaña
  final List<Widget> _screens = [
    const VentaScreen(),
    CategoriasListScreen(),
    ProductosListScreen(),
    const ConsultaVentaScreen(),
  ];

  // Cambiar la pantalla cuando se selecciona un item en la barra inferior
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  // Cambiar la pantalla cuando se desliza
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      _currentIndex = widget.index!;
    }
    _pageController = PageController(initialPage: _currentIndex);
  }

  // Función para navegar desde el Drawer
  void _navigateFromDrawer(int index) {
    Navigator.pop(context); // Cerrar el Drawer
    _onItemTapped(index); // Navegar a la página seleccionada
  }

  // Determina el texto del botón flotante según la pantalla actual
  String getFloatingButtonText() {
    switch (_currentIndex) {
      case categoriasIndex:
        return 'Agregar Categoría';
      case productosIndex:
        return 'Agregar Producto';
      case ventasIndex:
        return 'Carrito';
      default:
        return 'Agregar';
    }
  }

  // Determina la acción del botón flotante según la pantalla actual
  void onFloatingButtonPressed() {
    if (_currentIndex == categoriasIndex) {
      showFormCategoria();
    } else if (_currentIndex == productosIndex) {
      showFormProducto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(getTitle())),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      floatingActionButton:
          (_currentIndex != ventasIndex && _currentIndex != consultaIndex)
              ? FloatingActionButton.extended(
                  onPressed: onFloatingButtonPressed,
                  icon: Icon(getIcon()),
                  label: Text(getFloatingButtonText()),
                )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        selectedLabelStyle:
            TextStyle(color: Theme.of(context).colorScheme.primary),
        unselectedLabelStyle:
            TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        backgroundColor: Theme.of(context).colorScheme.background,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Ventas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Categorías'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Productos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on), label: 'Consulta'),
        ],
      ),
    );
  }

  void showFormCategoria() {
    // Navegar a la pantalla de creación/edición (CRUD)
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return CategoriaFormScreen();
    })).then((value) {
      // Refrescar la lista si es necesario
    });
  }

  void showFormProducto() {
    // Navegar a la pantalla de creación/edición (CRUD)
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return ProductoFormScreen();
    }));
  }

  String getTitle() {
    switch (_currentIndex) {
      case ventasIndex:
        return 'Ventas';
      case categoriasIndex:
        return 'Categorías';
      case productosIndex:
        return 'Productos';
      case consultaIndex:
        return 'Consultas';
      default:
        return 'Home';
    }
  }

  IconData? getIcon() {
    switch (_currentIndex) {
      case ventasIndex:
        return Icons.shopping_cart;
      default:
        return Icons.add;
    }
  }
}
