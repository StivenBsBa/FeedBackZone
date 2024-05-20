import 'package:feedbackzone/pantallas/IniciarRegistrar/Login.dart';
import 'package:feedbackzone/pantallas/IniciarRegistrar/Register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(
    title: 'Bienvenida',
    home: WelcomeScreen(),
  ));
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF309CFF),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset('assets/logo.png'),
              ),
              SizedBox(height: 20),
              const Text(
                'Feedback Zone: Conectando tu futuro ingeniero con experiencias y conocimientos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Groupbtn(
                text: 'Registrar',
                color: const Color(0xFFFFDE69),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const Register()));
                },
              ),
              const SizedBox(height: 10),
              Groupbtn(
                text: 'Iniciar Sesión',
                color: const Color(0xFF309CFF),
                borderColor: const Color(0xFFFFDE69),
                textColor: const Color(0xFFFFDE69),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Groupbtn extends StatelessWidget {
  final String text;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const Groupbtn({
    required this.text,
    required this.color,
    this.borderColor = const Color(0xFFFFDE69),
    this.textColor = const Color(0xFF1B1A40),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 281,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: color,
            border: Border.all(
              width: 3,
              color: borderColor,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26FFDE69),
                blurRadius: 10,
                offset: Offset(-1, 1),
                spreadRadius: 0,
              )
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontFamily: 'Segoe UI',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
