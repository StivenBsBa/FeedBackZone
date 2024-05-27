import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MostrarPublicacion extends StatelessWidget {
  final String? UserId;

  const MostrarPublicacion({Key? key, this.UserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Query publicacionesQuery =
        FirebaseFirestore.instance.collection('publicaciones');

    if (UserId != null) {
      publicacionesQuery =
          publicacionesQuery.where('UserId', isEqualTo: UserId);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: publicacionesQuery.snapshots(),
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
            Map<String, dynamic> publicacion =
                document.data() as Map<String, dynamic>;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(publicacion['UserId'])
                  .get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox.shrink();
                }
                if (userSnapshot.hasError || !userSnapshot.hasData) {
                  return SizedBox.shrink();
                }
                Map<String, dynamic> usuario =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                return Card(
                  margin:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Parte superior: Foto y nombre de quien publicó
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25.0,
                              backgroundImage:
                                  NetworkImage(usuario['FtPerfil'] ?? ''),
                            ),
                            SizedBox(width: 10.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  usuario['username'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  calcularTiempoTranscurrido(
                                      publicacion['fecha_publicacion']),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetallePublicacion(
                                publicacion: publicacion,
                                usuario: usuario,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Título y descripción
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    publicacion['titulo'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    publicacion['descripcion'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            // Imagen de la publicación con tamaño máximo
                            AspectRatio(
                              aspectRatio: 4 /
                                  3, // Relación de aspecto estándar para las imágenes
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        publicacion['imagenUrl'] ?? ''),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botones de interacción: like, comentarios y compartir
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.favorite_border),
                                  onPressed: () {
                                    // Lógica para manejar el like
                                  },
                                ),
                                SizedBox(
                                    width: 10.0), // Espaciado entre los iconos
                                IconButton(
                                  icon: Icon(Icons.chat_bubble_outline),
                                  onPressed: () {
                                    // Lógica para mostrar los comentarios
                                  },
                                ),
                                SizedBox(
                                    width: 10.0), // Espaciado entre los iconos
                                IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: () {
                                    // Lógica para compartir la publicación
                                  },
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.bookmark_border),
                              onPressed: () {
                                // Lógica para guardar la publicación
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class DetallePublicacion extends StatelessWidget {
  final Map<String, dynamic> publicacion;
  final Map<String, dynamic> usuario;

  DetallePublicacion({required this.publicacion, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de la Publicación'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25.0,
                    backgroundImage: NetworkImage(usuario['FtPerfil'] ?? ''),
                  ),
                  SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario['username'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        calcularTiempoTranscurrido(
                            publicacion['fecha_publicacion']),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Text(
                publicacion['titulo'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
              ),
              SizedBox(height: 10.0),
              Text(publicacion['descripcion'] ?? ''),
              SizedBox(height: 10.0),
              Image.network(publicacion['imagenUrl'] ?? ''),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.favorite_border),
                        onPressed: () {
                          // Lógica para manejar el like
                        },
                      ),
                      SizedBox(width: 10.0), // Espaciado entre los iconos
                      IconButton(
                        icon: Icon(Icons.chat_bubble_outline),
                        onPressed: () {
                          // Lógica para mostrar los comentarios
                        },
                      ),
                      SizedBox(width: 10.0), // Espaciado entre los iconos
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          // Lógica para compartir la publicación
                        },
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.bookmark_border),
                    onPressed: () {
                      // Lógica para guardar la publicación
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String calcularTiempoTranscurrido(Timestamp fechaPublicacion) {
  DateTime ahora = DateTime.now();
  DateTime fecha = fechaPublicacion.toDate();
  Duration diferencia = ahora.difference(fecha);

  if (diferencia.inSeconds < 60) {
    return 'Hace ${diferencia.inSeconds} segundos';
  } else if (diferencia.inMinutes < 60) {
    return 'Hace ${diferencia.inMinutes} minutos';
  } else if (diferencia.inHours < 24) {
    return 'Hace ${diferencia.inHours} horas';
  } else if (diferencia.inDays < 30) {
    return 'Hace ${diferencia.inDays} días';
  } else {
    // Si han pasado más de 30 días, mostrar la fecha en formato día/mes/año
    return DateFormat('dd/MM/yyyy').format(fecha);
  }
}
