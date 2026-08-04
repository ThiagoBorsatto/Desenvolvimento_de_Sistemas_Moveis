import 'package:flutter/material.dart';

class Servico {
  final String titulo;
  final String descricao;
  final IconData icone;

  const Servico({
    required this.titulo,
    required this.descricao,
    required this.icone,
  });
}

final List<Servico> servicos = [
  Servico(titulo: 'Desenvolvimento de Software', descricao: 'Criar programas que ajudam a resolver problemas.', icone: Icons.build),
  Servico(titulo: 'Movéis sobre Medida', descricao: 'Criação de movéis sobre medida, desenvolvimento e montagem.', icone: Icons.table_bar),
  Servico(titulo: 'Entregador de IFood com Bicicleta', descricao: 'Bagulho é ir rápido.', icone: Icons.electric_bike_outlined),
];
