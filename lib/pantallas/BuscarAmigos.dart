import 'package:feedbackzone/componentes/VerUsuario.dart';
import 'package:flutter/material.dart';
import 'package:feedbackzone/services/ManejarInfoUser.dart';

class BuscarAmigos extends StatefulWidget {
  const BuscarAmigos({Key? key}) : super(key: key);

  @override
  _BuscarAmigosState createState() => _BuscarAmigosState();
}

class _BuscarAmigosState extends State<BuscarAmigos> {
  final BuscarSeguirAmigo _buscarSeguirAmigo = BuscarSeguirAmigo();
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

    List<Map<String, dynamic>> amigos =
        await _buscarSeguirAmigo.obtenerAmigosSugeridos(_query);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Buscar Amigos",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        automaticallyImplyLeading: false,
        elevation: 0,
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
                  const SizedBox(width: 10),
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar amigos...',
                        border: InputBorder.none,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _query = '';
                      });
                      _cargarAmigosSugeridos();
                    },
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: _amigosSugeridos.isEmpty
                      ? const Center(
                          child: Text('No se encontraron resultados'))
                      : ListView.builder(
                          itemCount: _amigosSugeridos.length,
                          itemBuilder: (context, index) {
                            bool esSeguido =
                                _amigosSugeridos[index]['esSeguido'] ?? false;
                            bool teSigue =
                                _amigosSugeridos[index]['teSigue'] ?? false;
                            bool seSiguen =
                                _amigosSugeridos[index]['seSiguen'] ?? false;

                            return UsuarioItem(
                              userData: _amigosSugeridos[index],
                              seSiguen: seSiguen,
                              esSeguido: esSeguido,
                              teSigue: teSigue,
                              onPressed: (bool esSeguido) async {
                                if (esSeguido) {
                                  await _buscarSeguirAmigo
                                      .dejarDeSeguirAmigo(
                                          _amigosSugeridos[index]['uid']);
                                  setState(() {
                                    _amigosSugeridos[index]['esSeguido'] =
                                        false;
                                    _amigosSugeridos[index]['seSiguen'] =
                                        false;
                                  });
                                } else {
                                  await _buscarSeguirAmigo.seguirAmigo(
                                      _amigosSugeridos[index]['uid']);
                                  setState(() {
                                    _amigosSugeridos[index]['esSeguido'] =
                                        true;
                                    if (_amigosSugeridos[index]['teSigue']) {
                                      _amigosSugeridos[index]['seSiguen'] =
                                          true;
                                    }
                                  });
                                }
                              },
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
