import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/book.dart';

/// Cliente para a Gutendex API (https://gutendex.com), que expõe o catálogo
/// do Project Gutenberg. Pública e sem necessidade de chave de acesso.
class BookService {
  static const _baseUrl = 'https://gutendex.com/books/';

  Future<List<Book>> fetchBySubject(String subject) {
    final uri = Uri.parse('$_baseUrl?topic=${Uri.encodeQueryComponent(subject)}');
    return _fetchBooks(uri);
  }

  Future<List<Book>> search(String query) {
    final uri = Uri.parse('$_baseUrl?search=${Uri.encodeQueryComponent(query)}');
    return _fetchBooks(uri);
  }

  Future<List<Book>> _fetchBooks(Uri uri) async {
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar o catálogo (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List? ?? [];
    return results.map((r) => Book.fromJson(r as Map<String, dynamic>)).toList();
  }
}
