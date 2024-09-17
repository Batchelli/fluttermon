import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Fluttermon',
      home: MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String pkId = '';
  String pkName = '';

  Future<Map<String, dynamic>> fetchPokemon() async {
    final response =
        await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pkId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Falha ao carregar o pokemon");
    }
  }

  @override
  void initState() {
    super.initState();
    pkroll();
  }

  pkroll() {
    final pkSort = Random().nextInt(1025) + 1;
    setState(() {
      pkId = pkSort.toString();
    });
    fetchPokemon();
  }

  pkSearch() {
    setState(() {
      pkId = pkName;
    });
    fetchPokemon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.05,
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        child: Column(
          children: [
            const Text('Pokedex'),
            FutureBuilder<Map<String, dynamic>>(
              future: fetchPokemon(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(Icons.warning_amber_rounded),
                        Text('Erro: ${snapshot.error}')
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  final pokeData = snapshot.data!;
                  final pkSprite = pokeData['sprites']['other']
                      ['official-artwork']['front_default'];

                  loadPkImg() {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return Image.network(
                        pkSprite,
                        height: double.infinity,
                        width: double.infinity,
                      );
                    }
                  }

                  return Column(
                    children: [
                      Container(
                        height: 225,
                        width: 225,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        child: loadPkImg(),
                      ),
                      Text('Pokemon: ${pokeData['name']}')
                    ],
                  );
                } else {
                  return const Center(
                    child: Text('Nenhum dado disponivel'),
                  );
                }
              },
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Teste'),
              onChanged: (value) {
                pkName = value;
              },
            ),
            ElevatedButton(
              onPressed: pkSearch,
              child: const Text('Procurar pokemon'),
            ),
            ElevatedButton(
              onPressed: pkroll,
              child: const Text('Pokemon aleatório'),
            )
          ],
        ),
      ),
    );
  }
}
