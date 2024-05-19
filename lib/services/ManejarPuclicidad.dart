import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> RegistrarPublicacion(
    String tituloPublicacion,
    String contenidoPublicacion,
    String descripcionPublicacion,
    String imagenUrl) async {
  try {
    User? usuario = FirebaseAuth.instance.currentUser;

    if (usuario != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('publicaciones').add({
        'userId': usuario.uid,
        'titulo': tituloPublicacion,
        'contenido': contenidoPublicacion,
        'descripcion': descripcionPublicacion,
        'imagenUrl': imagenUrl,
        'fecha_publicacion': DateTime.now(),
        'likes': 0,
        'comentarios': [],
      });

      print('Publicación con imagen creada exitosamente');
    } else {
      print('Error: No hay usuario autenticado');
    }
  } catch (e) {
    print('Error al crear la publicación con imagen: $e');
  }
}

Future<List<Map<String, dynamic>>> getPublicaciones(
    FirebaseFirestore firestore) async {
  List<Map<String, dynamic>> publicaciones = [];

  try {
    CollectionReference collectionReferencePublicacion =
        firestore.collection('publicaciones');
    QuerySnapshot queryPublicaciones =
        await collectionReferencePublicacion.get();

    for (var documento in queryPublicaciones.docs) {
      publicaciones.add(documento.data() as Map<String, dynamic>);
    }
  } catch (e) {
    print('Error al obtener las publicaciones: $e');
    // Puedes manejar el error de alguna manera, por ejemplo, lanzando una excepción o devolviendo una lista vacía
  }

  return publicaciones;
}
