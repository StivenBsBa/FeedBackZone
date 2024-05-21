import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//verificar si el correo existe
Future<String?> _checkEmailExists(String email) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await firestore.collection('usuarios').where('email', isEqualTo: email).get();

  if (querySnapshot.docs.isNotEmpty) {
    // Si encuentra un correo electrónico existente, devuelve el ID del documento
    return querySnapshot.docs.first.id;
  } else {
    // Si no encuentra un correo electrónico existente, devuelve null
    return null;
  }
}

//Registrar Usuario
Future<void> registrarUsuario(String username, String email, String password, String genero, DateTime? fechaNacimiento) async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;

    // Verifica si el correo electrónico ya está en uso
    String? existingEmailId = await _checkEmailExists(email);
    if (existingEmailId != null) {
      // Si el correo electrónico ya está en uso, muestra un mensaje de error
      print('Error: El correo electrónico ya está en uso');
      return;
    }

    // Crea el usuario en Firebase Authentication
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Define las URLs de las imágenes de icono para hombres y mujeres
      String FtPerfil;
      int Seguidores = 0;
      int siguiendo = 0;
      if (genero == 'Hombre') {
        FtPerfil = 'https://w7.pngwing.com/pngs/945/530/png-transparent-male-avatar-boy-face-man-user-flat-classy-users-icon.png'; // Reemplaza con la URL de la imagen para hombres
      } else if (genero == 'Mujer') {
        FtPerfil = 'https://cdn-icons-png.flaticon.com/512/4139/4139951.png'; // Reemplaza con la URL de la imagen para mujeres
      } else {
        FtPerfil = 'https://cdn-icons-png.flaticon.com/512/456/456212.png'; // URL de imagen por defecto si no se especifica género
      }

      await firestore.collection('usuarios').doc(user.uid).set({
        'UserId': user.uid,
        'username': username,
        'email': email,
        'genero': genero,
        'fechaNacimiento': fechaNacimiento,
        'Seguidores': Seguidores,
        'Siguiendo': siguiendo,
        'FtPerfil': FtPerfil, // Asigna la URL de la imagen de icono según el género
      });

      print('Usuario registrado exitosamente');
    } else {
      print('Error: No se pudo obtener el usuario recién creado');
    }
  } catch (e) {
    print('Error al registrar usuario: $e');
  }
}

//iniciarsesion
class LoginUserAuth {
  static Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw e;
    }
  } 
}

// Función para enviar un correo electrónico de restablecimiento de contraseña
Future<void> enviarCorreoRecuperacion(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    print('Se ha enviado un correo electrónico de restablecimiento de contraseña a $email');
  } catch (error) {
    print('Ha ocurrido un error al enviar el correo electrónico de restablecimiento: $error');
  }

}

//Buscar amigos
class Backend {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> obtenerAmigosSugeridos(String query) async {
    List<Map<String, dynamic>> amigosSugeridos = [];
    try {
      QuerySnapshot snapshot = await _firestore.collection('usuarios')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      for (var doc in snapshot.docs) {
        amigosSugeridos.add({
          'uid': doc.id,
          'username': doc['username'],
          'FtPerfil': doc['FtPerfil'],
        });
      }
    } catch (e) {
      print('Error al obtener amigos sugeridos: $e');
    }
    return amigosSugeridos;
  }

  Future<void> enviarSolicitudAmistad(String userIdAmigo) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('solicitudesAmistad').add({
          'de': user.uid,
          'para': userIdAmigo,
          'estado': 'pendiente',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error al enviar solicitud de amistad: $e');
    }
  }
}


//manejar informacion del usaurio autenticado
