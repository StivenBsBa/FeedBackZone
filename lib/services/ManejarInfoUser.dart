import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      await firestore.collection('usuarios').doc(user.uid).set({
        'UserId':user.uid,
        'username': username,
        'email': email,
        'genero': genero,
        'fechaNacimiento': fechaNacimiento,

      });

      print('Usuario registrado exitosamente');
    } else {
      print('Error: No se pudo obtener el usuario recién creado');
    }
  } catch (e) {
    print('Error al registrar usuario: $e');
  }
}

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
