import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mensajes extends StatelessWidget {
  const Mensajes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mensajes"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('publicaciones').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos.'));
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay publicaciones disponibles.'));
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> publicacion = document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(publicacion['titulo']),
                subtitle: Text(publicacion['descripcion']),
                leading: Image.network(publicacion['imagenUrl']),
                onTap: () {
                  // Aquí puedes manejar la acción al hacer tap en una publicación
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
