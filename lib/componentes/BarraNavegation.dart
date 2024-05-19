import 'package:flutter/material.dart';

class BarraNavegation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BarraNavegation({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          _buildNavigationBarItem(Icons.home, 'Inicio', 0),
          _buildNavigationBarItem(Icons.chat_bubble, 'Mensajes', 1),
          _buildNavigationBarItem(Icons.group, 'Buscar Amigos', 2),
          _buildNavigationBarItem(Icons.person, 'Perfil', 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationBarItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(icon, color: currentIndex == index ? Colors.black : Colors.grey), // Icono en gris si no está seleccionado, negro si está seleccionado
      label: label,
    );
  }
}
