import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/book.dart';

/// Cliente para a Open Library API (https://openlibrary.org/dev/docs/api).
///
/// API pública e sem necessidade de chave de acesso, ideal para estudo.
class BookService {
  static const _baseUrl = 'https://openlibrary.org';

  Future<List<Book>> fetchBySubject(String subject, {int limit = 30}) async {
    final uri = Uri.parse('$_baseUrl/subjects/$subject.json?limit=$limit');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar o catálogo (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final works = data['works'] as List? ?? [];
    return works.map((w) => Book.fromJson(w as Map<String, dynamic>)).toList();
  }

  Future<List<Book>> search(String query, {int limit = 30}) async {
    final uri = Uri.parse(
      '$_baseUrl/search.json'
      '?q=${Uri.encodeQueryComponent(query)}'
      '&limit=$limit'
      '&fields=key,title,author_name,cover_i,first_publish_year,subject',
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Falha ao buscar livros (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = data['docs'] as List? ?? [];
    return docs.map((d) => Book.fromJson(d as Map<String, dynamic>)).toList();
  }

  /// Busca a sinopse de uma obra a partir da sua workKey (ex: "/works/OL66554W").
  Future<String?> fetchDescription(String workKey) async {
    final uri = Uri.parse('$_baseUrl$workKey.json');
    final response = await http.get(uri);

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final description = data['description'];
    if (description is String) return description;
    if (description is Map && description['value'] is String) {
      return description['value'] as String;
    }
    return null;
  }
}
