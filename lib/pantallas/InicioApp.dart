import 'package:feedbackzone/componentes/BarraNavegation.dart';
import 'package:feedbackzone/componentes/MostrarPublicacion.dart';
import 'package:feedbackzone/pantallas/Mensaje.dart';
import 'package:flutter/material.dart';
import 'BuscarAmigos.dart';
import 'Perfil.dart';

class InicioApp extends StatefulWidget {
  const InicioApp({Key? key}) : super(key: key);

  @override
  _InicioAppState createState() => _InicioAppState();
}

class _InicioAppState extends State<InicioApp> {
  int _currentIndex = 0;

  // Define las pantallas disponibles
  final List<Widget> _screens = [
    InicioScreen(),
    Mensajes(), // Reemplaza esto con tus otras pantallas
    BuscarAmigos(),
    Perfil(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Muestra la pantalla actual
      bottomNavigationBar: BarraNavegation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class InicioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FeedBackZone",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true, // Centra el título en la AppBar
        backgroundColor: Colors.lightBlue, // Color azul claro para todo el AppBar
        automaticallyImplyLeading: false, // Oculta la flecha hacia atrás en la barra de navegación
        elevation: 0, // Sin sombra ni borde para el AppBar
      ),
      body: MostrarPublicacion(), // Utiliza el componente aquí
    );
  }
}
