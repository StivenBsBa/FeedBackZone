import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feedbackzone/componentes/CrearPublicacion.dart';
import 'package:feedbackzone/componentes/MostrarPublicacion.dart';
import 'package:feedbackzone/componentes/VerUsuario.dart';
import 'package:feedbackzone/services/ManejarInfoUser.dart';

class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  Map<String, dynamic>? userData;
  List<String> seguidores = [];
  List<String> siguiendo = [];

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
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .get();
        if (userSnapshot.exists) {
          List<String> seguidoresList =
              await BuscarSeguirAmigo().obtenerSeguidores(userId);
          List<String> siguiendoList =
              await BuscarSeguirAmigo().obtenerSeguidos(userId);
          setState(() {
            userData = userSnapshot.data() as Map<String, dynamic>;
            seguidores = seguidoresList;
            siguiendo = siguiendoList;
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
        title: const Text('Perfil Usuario'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.menu),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configuración'),
                  onTap: () {
                    // Aquí puedes navegar a la pantalla de configuración
                  },
                ),
              ),
              
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Cerrar Sesión'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              backgroundImage: userData != null
                  ? NetworkImage(userData!['FtPerfil'])
                  : const AssetImage('assets/images/placeholder_image.jpg')
                      as ImageProvider,
              radius: 50,
            ),
            const SizedBox(height: 20),
            Text(
              userData != null ? userData!['username'] : 'Nombre de Usuario',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUserInfoContainer('Seguidores', seguidores.length),
                const SizedBox(width: 20),
                _buildUserInfoContainer('Siguiendo', siguiendo.length),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CrearPublicacion()),
                );
              },
              child: const Text('Crear Publicación'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: MostrarPublicacion(
                  UserId: userData != null ? userData!['UserId'] : ''),
            ),
            const SizedBox(height: 20),
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
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSeguidores() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SeguidoresScreen(seguidores: seguidores)),
    );
  }

  void _navigateToSiguiendo() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SiguiendoScreen(siguiendo: siguiendo)),
    );
  }
}

class SeguidoresScreen extends StatelessWidget {
  final List<String> seguidores;

  const SeguidoresScreen({required this.seguidores});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguidores'),
      ),
      body: seguidores.isNotEmpty
          ? ListView.builder(
              itemCount: seguidores.length,
              itemBuilder: (context, index) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(seguidores[index])
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                          child:
                              Text('No se encontró información del usuario'));
                    }
                    var user = snapshot.data!;
                    return UsuarioItem(
                      userData: {
                        'username': user['username'],
                        'FtPerfil': user['FtPerfil'],
                      },
                      seSiguen: false, // Define los estados según corresponda
                      esSeguido:
                          true, // En este caso, están siguiendo al usuario
                      teSigue: false, // En este caso, el usuario no te sigue
                      onPressed: (bool seguir) {
                        // Aquí puedes manejar la lógica de seguimiento/deseguimiento
                      },
                    );
                  },
                );
              },
            )
          : const Center(child: Text('Aún nadie te sigue')),
    );
  }
}

class SiguiendoScreen extends StatelessWidget {
  final List<String> siguiendo;

  const SiguiendoScreen({required this.siguiendo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Siguiendo'),
      ),
      body: siguiendo.isNotEmpty
          ? ListView.builder(
              itemCount: siguiendo.length,
              itemBuilder: (context, index) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(siguiendo[index])
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                          child:
                              Text('No se encontró información del usuario'));
                    }
                    var user = snapshot.data!;
                    return UsuarioItem(
                      userData: {
                        'username': user['username'],
                        'FtPerfil': user['FtPerfil'],
                      },
                      seSiguen: true, // Define los estados según corresponda
                      esSeguido:
                          false, // En este caso, no estás siguiendo al usuario
                      teSigue: true, // En este caso, el usuario te sigue
                      onPressed: (bool seguir) {
                        // Aquí puedes manejar la lógica de seguimiento/deseguimiento
                      },
                    );
                  },
                );
              },
            )
          : const Center(child: Text('Aún no sigues a nadie')),
    );
  }
}
