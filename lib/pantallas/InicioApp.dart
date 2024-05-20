import 'package:feedbackzone/componentes/BarraNavegation.dart';
import 'package:feedbackzone/pantallas/Mensaje.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../services/firebase_services.dart';
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
    return FutureBuilder(
      future: getUsuarios(db),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (context, index) {
              Timestamp timestamp = snapshot.data![index]['fechaNacimiento'];
              DateTime fechaNacimiento = timestamp.toDate();
              String fechaFormateada = DateFormat('dd/MM/yyyy').format(fechaNacimiento);
              DateTime fechaActual = DateTime.now();
              int edad = fechaActual.year - fechaNacimiento.year;
              if (fechaActual.month < fechaNacimiento.month ||
                  (fechaActual.month == fechaNacimiento.month && fechaActual.day < fechaNacimiento.day)) {
                edad--;
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text('Nombre: ${snapshot.data![index]['username']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${snapshot.data![index]['email']}'),
                      Text('Género: ${snapshot.data![index]['genero']}'),
                      Text('Fecha de Nacimiento: $fechaFormateada'),
                      Text('Edad: $edad años'), 
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }),
    );
  }
}
