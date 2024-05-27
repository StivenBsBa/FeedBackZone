import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//verificar si el correo existe
Future<String?> _checkEmailExists(String email) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
      .collection('usuarios')
      .where('email', isEqualTo: email)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    // Si encuentra un correo electrónico existente, devuelve el ID del documento
    return querySnapshot.docs.first.id;
  } else {
    // Si no encuentra un correo electrónico existente, devuelve null
    return null;
  }
}

//Registrar Usuario
Future<void> registrarUsuario(String username, String email, String password,
    String genero, DateTime? fechaNacimiento) async {
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
        FtPerfil =
            'https://w7.pngwing.com/pngs/945/530/png-transparent-male-avatar-boy-face-man-user-flat-classy-users-icon.png'; // Reemplaza con la URL de la imagen para hombres
      } else if (genero == 'Mujer') {
        FtPerfil =
            'https://cdn-icons-png.flaticon.com/512/4139/4139951.png'; // Reemplaza con la URL de la imagen para mujeres
      } else {
        FtPerfil =
            'https://cdn-icons-png.flaticon.com/512/456/456212.png'; // URL de imagen por defecto si no se especifica género
      }

      await firestore.collection('usuarios').doc(user.uid).set({
        'UserId': user.uid,
        'username': username,
        'email': email,
        'genero': genero,
        'fechaNacimiento': fechaNacimiento,
        'Seguidores': Seguidores,
        'Siguiendo': siguiendo,
        'FtPerfil':
            FtPerfil, // Asigna la URL de la imagen de icono según el género
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
  static Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
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
    print(
        'Se ha enviado un correo electrónico de restablecimiento de contraseña a $email');
  } catch (error) {
    print(
        'Ha ocurrido un error al enviar el correo electrónico de restablecimiento: $error');
  }
}




//Busmar y seguir amigo



class BuscarSeguirAmigo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> obtenerAmigosSugeridos(String query) async {
    List<Map<String, dynamic>> amigosSugeridos = [];
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        QuerySnapshot snapshot = await _firestore
            .collection('usuarios')
            .where('username', isGreaterThanOrEqualTo: query)
            .where('username', isLessThanOrEqualTo: query + '\uf8ff')
            .get();

        List<String> seguidosIds = await obtenerSeguidos(currentUser.uid);
        List<String> seguidoresIds = await obtenerSeguidores(currentUser.uid);

        for (var doc in snapshot.docs) {
          if (doc.id != currentUser.uid) {
            bool esSeguido = seguidosIds.contains(doc.id);
            bool teSigue = seguidoresIds.contains(doc.id);
            bool seSiguen = esSeguido && teSigue;
            amigosSugeridos.add({
              'uid': doc.id,
              'username': doc['username'],
              'FtPerfil': doc['FtPerfil'],
              'esSeguido': esSeguido,
              'teSigue': teSigue,
              'seSiguen': seSiguen,
            });
          }
        }
      }
    } catch (e) {
      print('Error al obtener amigos sugeridos: $e');
    }
    return amigosSugeridos;
  }

  Future<void> seguirAmigo(String userIdAmigo) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('seguidores').add({
          'seguidorId': user.uid,
          'seguidoId': userIdAmigo,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error al seguir amigo: $e');
    }
  }

  Future<void> dejarDeSeguirAmigo(String userIdAmigo) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot snapshot = await _firestore
            .collection('seguidores')
            .where('seguidorId', isEqualTo: user.uid)
            .where('seguidoId', isEqualTo: userIdAmigo)
            .get();

        for (var doc in snapshot.docs) {
          await _firestore.collection('seguidores').doc(doc.id).delete();
        }
      }
    } catch (e) {
      print('Error al dejar de seguir amigo: $e');
    }
  }

  Future<List<String>> obtenerSeguidos(String userId) async {
    QuerySnapshot result = await _firestore
        .collection('seguidores')
        .where('seguidorId', isEqualTo: userId)
        .get();
    return result.docs.map((doc) => doc['seguidoId'].toString()).toList();
  }

  Future<List<String>> obtenerSeguidores(String userId) async {
    QuerySnapshot result = await _firestore
        .collection('seguidores')
        .where('seguidoId', isEqualTo: userId)
        .get();
    return result.docs.map((doc) => doc['seguidorId'].toString()).toList();
  }
}









//manejar informacion del usaurio autenticado
Future<void> obtenerInformacionUsuario() async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;

    // Verifica si hay un usuario autenticado
    User? user = auth.currentUser;

    if (user != null) {
      // El usuario está autenticado, obtén su UID
      String UserId = user.uid;

      // Accede a Firestore y obtén los datos del usuario
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userSnapshot =
          await firestore.collection('usuarios').doc(UserId).get();

      // Verifica si el documento existe
      if (userSnapshot.exists) {
        // Accede a los datos del usuario
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
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
