import 'package:flutter/material.dart';
import 'package:projeto_opcao_a/detalhes.dart';
import 'package:projeto_opcao_a/servico.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atividade 2 - Primeiro app Flutter',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.red),
      ),
      home: const MyHomePage(title: 'Home Page'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final servico in servicos)
            _buildCard(context, servico),
        ],
      ),
      ),
    );
  }

 Widget _buildCard(BuildContext context, Servico servico) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetalhesScreen(servico: servico),
        ),
      );
    },
    child: Container(
      width: MediaQuery.of(context).size.width * 0.85,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(/* ... */),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(servico.icone),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(servico.titulo),
              Text(servico.descricao),
            ],
          ),
        ],
      ),
    ),
  );
}
}
