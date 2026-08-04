import 'package:flutter/material.dart';
import 'package:projeto_opcao_a/servico.dart';

class DetalhesScreen extends StatefulWidget {
  final Servico servico;
  const DetalhesScreen({super.key, required this.servico});

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  bool _favoritado = false;

  void _alternarFavorito() {
    setState(() {
      _favoritado = !_favoritado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.servico.titulo)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(widget.servico.icone, size: 64),
          const SizedBox(height: 12),
          Text(
            widget.servico.titulo,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            widget.servico.descricao,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        IconButton(
          icon: Icon(_favoritado ? Icons.favorite : Icons.favorite_border),
          onPressed: _alternarFavorito,
        ),
      ElevatedButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Voltar'),
    ),
  ],
),
    );
  }
}