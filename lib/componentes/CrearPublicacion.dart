import 'package:feedbackzone/services/ManejarPuclicidad.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CrearPublicacion extends StatefulWidget {
  @override
  _CrearPublicacionState createState() => _CrearPublicacionState();
}

class _CrearPublicacionState extends State<CrearPublicacion> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  bool _botonCrearPresionado = false;

  CrearPublicacionBackend _backend = CrearPublicacionBackend();

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor introduce el $hintText';
        }
        return null;
      },
      maxLines: null, // Para ajustar automáticamente al tamaño del texto
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 300.0, // Ajustar al tamaño deseado
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.file(
          _imageFile!,
          fit: BoxFit.cover,
        ),
      ),
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

  Future<void> _crearPublicacion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _botonCrearPresionado = true;
    });

    try {
      String imageUrl = await _backend.uploadImageToFirebase(_imageFile!);
      await _backend.registrarPublicacion(
          imageUrl, _tituloController.text, _descripcionController.text);
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

  void _limpiarCampos() {
    _tituloController.clear();
    _descripcionController.clear();
    _imageFile = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Publicación'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_tituloController, 'Título'),
                SizedBox(height: 16.0),
                _buildTextField(_descripcionController, 'Descripción'),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Seleccionar Imagen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue, // Color del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                if (_imageFile != null) ...[
                  SizedBox(height: 16.0),
                  _buildImagePreview(),
                ],
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _botonCrearPresionado ? null : _crearPublicacion,
                  child: Text('Publicar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue, // Color del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
