import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/book.dart';

/// Erro de transporte/protocolo da [BookApiService]. Fica restrito à camada de
/// dados: o repositório o traduz para uma mensagem de usuário.
class BookApiException implements Exception {
  final String message;

  const BookApiException(this.message);

  @override
  String toString() => 'BookApiException: $message';
}

/// Cliente HTTP da Gutendex API (https://gutendex.com), que expõe o catálogo
/// do Project Gutenberg. Pública e sem necessidade de chave de acesso.
///
/// Esta classe só sabe falar HTTP e desserializar JSON — não decide o que
/// buscar nem como apresentar erros. Essas decisões ficam no repositório.
class BookApiService {
  // A barra final importa: sem ela a Gutendex responde 301 e o cliente HTTP
  // gasta um round-trip extra seguindo o redirecionamento.
  static const _baseUrl = 'https://gutendex.com/books/';
  static const _timeout = Duration(seconds: 10);

  final http.Client _client;

  BookApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Consulta o catálogo. Sem nenhum parâmetro, a Gutendex devolve a primeira
  /// página do acervo completo ordenada por popularidade — que é exatamente o
  /// estado inicial da tela de catálogo.
  ///
  /// [search] casa contra título e nome do autor; [topic] casa contra assuntos
  /// e estantes. Quando os dois vêm juntos, a API aplica os dois como AND.
  Future<List<Book>> fetchBooks({String? search, String? topic}) async {
    final query = <String, String>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (topic != null && topic.isNotEmpty) 'topic': topic,
    };
    final uri = Uri.parse(
      _baseUrl,
    ).replace(queryParameters: query.isEmpty ? null : query);

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on Exception catch (error) {
      throw BookApiException('Falha de rede ao consultar a Gutendex: $error');
    }

    if (response.statusCode != 200) {
      throw BookApiException(
        'A Gutendex respondeu com status ${response.statusCode}.',
      );
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } on Exception catch (error) {
      throw BookApiException(
        'Resposta da Gutendex em formato inesperado: $error',
      );
    }

    final results = data['results'] as List? ?? const [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(Book.fromJson)
        .toList();
  }
}
