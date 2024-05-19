import 'package:flutter/material.dart';

class BuscarAmigos extends StatefulWidget {
  const BuscarAmigos({Key? key});

  @override
  _BuscarAmigosState createState() => _BuscarAmigosState();
}

class _BuscarAmigosState extends State<BuscarAmigos> {
  int _currentIndex = 2;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Pantalla Buscar Amigos",
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
