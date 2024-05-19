import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CrearPublicacion extends StatefulWidget {
  final VoidCallback mostrarModal;

  const CrearPublicacion({Key? key, required this.mostrarModal}) : super(key: key);

  @override
  _CrearPublicacionState createState() => _CrearPublicacionState();
}

class _CrearPublicacionState extends State<CrearPublicacion> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _contenidoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  File? _imageFile;
  bool _botonCrearPresionado = false;

  bool _isFieldEmpty(TextEditingController controller) => controller.text.isEmpty;

  void _mostrarModal(BuildContext contexto) {
    setState(() {
      _botonCrearPresionado = false;
    });

    showModalBottomSheet(
      isScrollControlled: true,
      context: contexto,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        hintText: 'Título',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _contenidoController,
                      decoration: InputDecoration(
                        hintText: 'Contenido',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _descripcionController,
                      decoration: InputDecoration(
                        hintText: 'Descripción',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Seleccionar Imagen'),
                    ),
                    if (_imageFile != null) ...[
                      SizedBox(height: 16.0),
                      Container(
                        height: 150.0, // Aumenta el tamaño del contenedor
                        width: 150.0, // Aumenta el tamaño del contenedor
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () => _crearPublicacion(context),
                      child: Text('Publicar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<String> _uploadImageToFirebase() async {
    if (_imageFile == null) {
      throw 'No se seleccionó ninguna imagen';
    }
    String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.png';
    Reference storageReference = FirebaseStorage.instance.ref().child(fileName);

    UploadTask uploadTask = storageReference.putFile(_imageFile!);
    await uploadTask;

    String downloadURL = await storageReference.getDownloadURL();
    return downloadURL;
  }

  void _crearPublicacion(BuildContext context) async {
    setState(() {
      _botonCrearPresionado = true;
    });

    final campos = {
      _tituloController: 'Título',
      _contenidoController: 'Contenido',
      _descripcionController: 'Descripción',
    };

    List<String> camposFaltantes = [];

    campos.forEach((controller, hint) {
      if (_isFieldEmpty(controller)) {
        camposFaltantes.add(hint);
      }
    });

    if (_imageFile == null) {
      camposFaltantes.add('Imagen');
    }

    if (camposFaltantes.isNotEmpty) {
      String mensaje = 'Por favor llena el campo';
      if (camposFaltantes.length > 1) {
        mensaje += 's:';
      } else {
        mensaje += ':';
      }
      mensaje += ' ${camposFaltantes.join(', ')}';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Campos Faltantes'),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Entendido'),
              ),
            ],
          );
        },
      );
    } else {
      try {
        String imageUrl = await _uploadImageToFirebase();
        await _registrarPublicacion(imageUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Publicación creada exitosamente')),
        );
        _limpiarCampos();
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar la imagen: $error')),
        );
      }
    }
  }

  Future<void> _registrarPublicacion(String imageUrl) async {
    try {
      User? usuario = FirebaseAuth.instance.currentUser;

      if (usuario != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        await firestore.collection('publicaciones').add({
          'userId': usuario.uid,
          'titulo': _tituloController.text,
          'contenido': _contenidoController.text,
          'descripcion': _descripcionController.text,
          'imagenUrl': imageUrl,
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

  void _limpiarCampos() {
    _tituloController.clear();
    _contenidoController.clear();
    _descripcionController.clear();
    _imageFile = null;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _mostrarModal(context),
      child: Text('Crear Publicación'),
    );
  }
}
