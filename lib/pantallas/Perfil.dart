import 'package:feedbackzone/componentes/CrearPublicacion.dart';
import 'package:feedbackzone/componentes/MostrarPublicacion.dart';
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

  void _navigateToSeguidores() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeguidoresScreen(
          seguidores: userData!['Seguidores'],
        ),
      ),
    );
  }

  void _navigateToSiguiendo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SiguiendoScreen(
          siguiendo: userData!['Siguiendo'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil User'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Oculta la flecha hacia atrás en la barra de navegación
      ),
      body: userData != null
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(userData!['FtPerfil']),
                      radius: 50,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      userData!['username'],
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _navigateToSeguidores,
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${userData!['Seguidores']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Seguidores',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: _navigateToSiguiendo,
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${userData!['Siguiendo']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Siguiendo',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  CrearPublicacion(
                    mostrarModal: () {
                      (context);
                    },
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class SeguidoresScreen extends StatelessWidget {
  final int seguidores;

  const SeguidoresScreen({required this.seguidores});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguidores'),
      ),
      body: Center(
        child: seguidores > 0
            ? Text('Se está creando esta lista.')
            : Text('Aún nadie te sigue'),
      ),
    );
  }
}

class SiguiendoScreen extends StatelessWidget {
  final int siguiendo;

  const SiguiendoScreen({required this.siguiendo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Siguiendo'),
      ),
      body: Center(
        child: siguiendo > 0
            ? Text('Se está creando esta lista.')
            : Text('Aún no sigues a nadie'),
      ),
    );
  }
}
