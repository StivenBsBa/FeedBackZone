import 'package:flutter/material.dart';

class Mensajes extends StatelessWidget {
  const Mensajes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mensajes",
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
      body: Center(
        child: Text("Esta pantalla está en producción"),
      ),
    );
  }
}
