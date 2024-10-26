import 'package:flutter/material.dart';
import 'package:frontend_parcial2/pages/productos/producto_form_screen.dart';
import 'package:frontend_parcial2/pages/productos/productos_list_screen.dart';
import 'package:frontend_parcial2/pages/proveedores/proveedores.dart';
import 'package:frontend_parcial2/pages/proveedores/proveedores_form_screen.dart';

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
    const Center(child: Text('Home')),
    CategoriasListScreen(),
    const Center(child: Text('Ventas')),
    ProductosListScreen(),
    const Center(child: Text('Clientes')),
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
    _onItemTapped(index);   // Navegar a la página seleccionada
  }

  // Determina el texto del botón flotante según la pantalla actual
  String getFloatingButtonText() {
    switch (_currentIndex) {
      case 1:
        return 'Agregar Categoría';
      case 3:
        return 'Agregar Producto';
      default:
        return 'Agregar';
    }
  }

  // Determina la acción del botón flotante según la pantalla actual
  void onFloatingButtonPressed() {
    if (_currentIndex == 1) {
      showFormCategoria();
    } else if (_currentIndex == 3) {
      showFormProducto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventas')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menú de Navegación',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => _navigateFromDrawer(0),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categorías'),
              onTap: () => _navigateFromDrawer(1),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Ventas'),
              onTap: () => _navigateFromDrawer(2),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Productos'),
              onTap: () => _navigateFromDrawer(3),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Clientes'),
              onTap: () => _navigateFromDrawer(4),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onFloatingButtonPressed,
        icon: const Icon(Icons.add),
        label: Text(getFloatingButtonText()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(color: Colors.blue),
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categorías'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Ventas'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Productos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Clientes'),
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
}
