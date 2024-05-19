import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getUsuarios(FirebaseFirestore firestore) async {
  List usuarios = [];

  CollectionReference collectionReferenceUsuarios =
      firestore.collection('usuarios');
  QuerySnapshot queryUsuarios = await collectionReferenceUsuarios.get();

  for (var documento in queryUsuarios.docs) {
    usuarios.add(documento.data());
  }

  return usuarios;
}



Future<void> obtenerInformacionUsuario() async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;

    // Verifica si hay un usuario autenticado
    User? user = auth.currentUser;
    
    if (user != null) {
      // El usuario está autenticado, obtén su UID
      String userId = user.uid;

      // Accede a Firestore y obtén los datos del usuario
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userSnapshot = await firestore.collection('usuarios').doc(userId).get();

      // Verifica si el documento existe
      if (userSnapshot.exists) {
        // Accede a los datos del usuario
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        print('Información del usuario:');
        print('Username: ${userData['username']}');
        print('Email: ${userData['email']}');
        print('Género: ${userData['genero']}');
        print('Fecha de Nacimiento: ${userData['fechaNacimiento']}');
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

