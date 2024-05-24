import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class CrearPublicacionBackend {
  Future<String> uploadImageToFirebase(File imageFile) async {
    String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.png';
    Reference storageReference = FirebaseStorage.instance.ref().child(fileName);

    UploadTask uploadTask = storageReference.putFile(imageFile);
    await uploadTask;

    String downloadURL = await storageReference.getDownloadURL();
    return downloadURL;
  }

  Future<void> registrarPublicacion(
      String imageUrl, String titulo, String descripcion) async {
    User? usuario = FirebaseAuth.instance.currentUser;

    if (usuario != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('publicaciones').add({
        'UserId': usuario.uid,
        'titulo': titulo,
        'descripcion': descripcion,
        'imagenUrl': imageUrl,
        'fecha_publicacion': DateTime.now(),
        'likes': 0,
        'comentarios': [],
      });

      print('Publicación con imagen creada exitosamente');
    } else {
      print('Error: No hay usuario autenticado');
    }
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
