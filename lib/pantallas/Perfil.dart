import 'package:feedbackzone/componentes/CrearPublicacion.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  int _currentIndex = 3;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    obtenerInformacionUsuario();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> obtenerInformacionUsuario() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      if (user != null) {
        String userId = user.uid;
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        DocumentSnapshot userSnapshot =
            await firestore.collection('usuarios').doc(userId).get();
        if (userSnapshot.exists) {
          setState(() {
            userData = userSnapshot.data() as Map<String, dynamic>;
          });
        } else {
          print('Error: No se encontró información para el usuario actual');
        }
      } else {
        print('Error: No hay usuario autenticado');
      }
    } catch (e) {
      print('Error al obtener la información del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: Center(
        child: userData != null
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Username: ${userData!['username']}'),
                      Text('Email: ${userData!['email']}'),
                      Text('Género: ${userData!['genero']}'),
                      Text(
                          'Fecha de Nacimiento: ${userData!['fechaNacimiento']}'),
                      CrearPublicacion(
                        mostrarModal: () {
                          (context);
                        },
                      ),
                    ],
                  ),
                ),
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
