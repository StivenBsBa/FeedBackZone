import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feedbackzoom/services/ManejarInfoUser.dart';
import 'package:flutter/material.dart';
import 'package:feedbackzoom/pantallas/IniciarRegistrar/Login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool rememberPassword = false;
  DateTime? selectedDate;
  String gender = '';

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Mover la declaración de acceptedTerms dentro de la clase _RegisterState
  bool acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.blue,
        ),
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Registro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF050522)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF050522)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF050522)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF050522)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF050522)),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextButton(
                            onPressed: () {
                              _selectDate(context);
                            },
                            child: Text(
                              selectedDate != null
                                  ? 'Selected Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                  : 'Select Birthday',
                              style: const TextStyle(
                                color: Colors.black38,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.blue),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        const Text(
                          'Selecciona tu género',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  gender = 'Hombre';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gender == 'Hombre' ? Colors.blue : null,
                              ),
                              child: const Text('Hombre'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  gender = 'Mujer';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gender == 'Mujer' ? Colors.blue : null,
                              ),
                              child: const Text('Mujer'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  gender = 'Otros';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gender == 'Otros' ? Colors.blue : null,
                              ),
                              child: const Text('Otros'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // Verificar que todos los campos estén llenos
                        if (usernameController.text.isEmpty ||
                            emailController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty ||
                            selectedDate == null ||
                            gender.isEmpty) {
                          // Mostrar un mensaje de error si algún campo está vacío
                          _showErrorDialog(
                              'Por favor, complete todos los campos.');
                        } else if (!isValidEmail(emailController.text)) {
                          // Verificar si el correo electrónico es válido
                          _showErrorDialog(
                              'Por favor, ingrese un correo electrónico válido.');
                        } else {
                          // Verificar si el correo electrónico ya está registrado
                          String? existingEmailId =
                              await _checkEmailExists(emailController.text);
                          if (existingEmailId != null) {
                            // Mostrar un mensaje de error si el correo electrónico ya existe
                            _showErrorDialog(
                                'El correo electrónico ya está registrado.');
                          } else if (passwordController.text.length < 8) {
                            // Si la contraseña es demasiado corta, muestra un mensaje de error
                            _showErrorDialog(
                                'Error: La contraseña debe tener al menos 8 caracteres');
                          } else {
                            // Verificar si la edad es mayor a 15 años y menor a 70 años
                            DateTime currentDate = DateTime.now();
                            DateTime maximumDate = DateTime(2010, 1, 1);
                            if (selectedDate!.isAfter(maximumDate)) {
                              // Mostrar un mensaje de error si la edad no está dentro del rango permitido
                              _showErrorDialog(
                                  'Debe tener más de 15 años para registrarse.');
                            } else {
                              // Verificar que las contraseñas coincidan
                              if (passwordController.text !=
                                  confirmPasswordController.text) {
                                // Verificar que las contraseñas coincidan
                                _showErrorDialog(
                                    'Las contraseñas no coinciden.');
                              }
                              if (!acceptedTerms) {
                                _showErrorDialog(
                                    'Por favor, acepta los términos y condiciones.');
                              } else {
                                // Registrar al usuario
                                registrarUsuario(
                                  usernameController.text,
                                  emailController.text,
                                  passwordController.text,
                                  gender,
                                  selectedDate,
                                );
                                // Mostrar mensaje de éxito
                                // Redirigir al usuario al inicio de sesión
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Login()),
                                );
                                _showSuccessDialog(
                                    'Usuario ${usernameController.text} registrado.');
                              }
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF070759),
                      ),
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: acceptedTerms,
                              onChanged: (value) {
                                setState(() {
                                  acceptedTerms = value!;
                                });
                              },
                              checkColor: Colors.white,
                              activeColor: const Color(0xFF303098),
                            ),
                            Text(
                              'Aceptar términos y condiciones',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDate = DateTime(2010, 1, 1);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1970, 1, 1),
      lastDate: DateTime(2010, 1, 1),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      print('Fecha seleccionada: $selectedDate');
    }
  }

  bool isValidEmail(String email) {
    String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    return RegExp(emailRegex).hasMatch(email);
  }

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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¡Registro Exitoso!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡$message!',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
