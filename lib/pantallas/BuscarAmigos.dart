import 'package:feedbackzone/services/ManejarInfoUser.dart';
import 'package:flutter/material.dart';

class BuscarAmigos extends StatefulWidget {
  const BuscarAmigos({Key? key}) : super(key: key);

  @override
  _BuscarAmigosState createState() => _BuscarAmigosState();
}

class _BuscarAmigosState extends State<BuscarAmigos> {
  final Backend _backend = Backend();
  List<Map<String, dynamic>> _amigosSugeridos = [];
  String _query = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarAmigosSugeridos();
  }

  Future<void> _cargarAmigosSugeridos() async {
    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> amigos = await _backend.obtenerAmigosSugeridos(_query);
    
    setState(() {
      _amigosSugeridos = amigos;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _query = query;
    });
    _cargarAmigosSugeridos();
  }

  void _onTabTapped(int index) {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Buscar Amigos",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true, // Centra el título en la AppBar
        backgroundColor: Colors.lightBlue, // Color azul claro para todo el AppBar
        automaticallyImplyLeading: false, // Oculta la flecha hacia atrás en la barra de navegación
        elevation: 0, // Sin sombra ni borde para el AppBar
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar amigos...',
                        border: InputBorder.none,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _query = '';
                      });
                      _cargarAmigosSugeridos();
                    },
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
          ),
          _isLoading
              ? Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: _amigosSugeridos.isEmpty
                      ? Center(child: Text('No se encontraron resultados'))
                      : ListView.builder(
                          itemCount: _amigosSugeridos.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(_amigosSugeridos[index]['FtPerfil']!),
                                ),
                                title: Text(_amigosSugeridos[index]['username']!),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    _backend.enviarSolicitudAmistad(_amigosSugeridos[index]['uid']!);
                                  },
                                  child: const Text('Seguir', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
