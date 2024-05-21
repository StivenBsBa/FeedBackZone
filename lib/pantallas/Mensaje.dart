import 'package:feedbackzone/componentes/MostrarPublicacion.dart';
import 'package:flutter/material.dart';

class Mensajes extends StatelessWidget {
  const Mensajes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mensajes"),
        automaticallyImplyLeading: false, // Oculta la flecha hacia atrás en la barra de navegación
      ),
      body: Mostrarpublicacion(), // Utiliza el componente aquí
    );
  }
}
