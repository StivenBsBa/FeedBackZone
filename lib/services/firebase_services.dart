import 'package:cloud_firestore/cloud_firestore.dart';

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



