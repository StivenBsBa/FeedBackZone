import 'package:flutter/material.dart';

class UsuarioItem extends StatelessWidget {
  final Map<String, dynamic> userData;
  final bool seSiguen;
  final bool esSeguido;
  final bool teSigue;
  final Function(bool) onPressed;

  const UsuarioItem({
    required this.userData,
    required this.seSiguen,
    required this.esSeguido,
    required this.teSigue,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(userData['FtPerfil'] ?? ''),
        ),
        title: Text(userData['username'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (seSiguen) const Text("Se siguen", style: TextStyle(color: Colors.purple)),
            if (!seSiguen && esSeguido) const Text("Siguiendo", style: TextStyle(color: Colors.green)),
            if (!seSiguen && teSigue) const Text("Te sigue", style: TextStyle(color: Colors.blue)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            onPressed(esSeguido);
          },
          child: Text(
            esSeguido ? 'Dejar de seguir' : 'Seguir',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}
