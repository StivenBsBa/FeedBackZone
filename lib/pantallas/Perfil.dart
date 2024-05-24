import 'package:flutter/material.dart';
import 'package:feedbackzone/componentes/CrearPublicacion.dart';
import 'package:feedbackzone/componentes/MostrarPublicacion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _cargarInformacionUsuario();
  }

  Future<void> _cargarInformacionUsuario() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('usuarios').doc(userId).get();
        if (userSnapshot.exists) {
          setState(() {
            userData = userSnapshot.data() as Map<String, dynamic>;
          });
        } else {
          _mostrarError('No se encontró información para el usuario actual');
        }
      } else {
        _mostrarError('No hay usuario autenticado');
      }
    } catch (e) {
      _mostrarError('Error al obtener la información del usuario: $e');
    }
  }

  void _mostrarError(String errorMessage) {
    print('Error: $errorMessage');
    // Aquí puedes implementar una lógica para mostrar un mensaje de error al usuario
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil Usuario'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              backgroundImage: userData != null ? NetworkImage(userData!['FtPerfil']) : AssetImage('assets/images/placeholder_image.jpg') as ImageProvider,
              radius: 50,
            ),
            SizedBox(height: 20),
            Text(
              userData != null ? userData!['username'] : 'Nombre de Usuario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUserInfoContainer('Seguidores', userData != null ? userData!['Seguidores'] : 0),
                SizedBox(width: 20),
                _buildUserInfoContainer('Siguiendo', userData != null ? userData!['Siguiendo'] : 0),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CrearPublicacion()),
                );
              },
              child: Text('Crear Publicación'),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: MostrarPublicacion(UserId: userData != null ? userData!['UserId'] : ''),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoContainer(String label, int count) {
    return GestureDetector(
      onTap: () {
        if (label == 'Seguidores') {
          _navigateToSeguidores();
        } else if (label == 'Siguiendo') {
          _navigateToSiguiendo();
        }
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSeguidores() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SeguidoresScreen(seguidores: userData != null ? userData!['Seguidores'] : 0)),
    );
  }

  void _navigateToSiguiendo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SiguiendoScreen(siguiendo: userData != null ? userData!['Siguiendo'] : 0)),
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
