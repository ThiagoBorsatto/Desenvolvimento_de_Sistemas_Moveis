/// Representa um livro retornado pela Gutendex API (catálogo do Project
/// Gutenberg).
class Book {
  final int id;
  final String title;
  final List<String> authors;
  final String? coverUrl;
  final List<String> subjects;
  final List<String> languages;
  final String? description;

  /// Número de downloads no Project Gutenberg. Serve como proxy de
  /// popularidade para ordenar resultados de busca vindos de fontes diferentes.
  final int downloadCount;

  const Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.coverUrl,
    required this.subjects,
    required this.languages,
    required this.description,
    required this.downloadCount,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final authorsList = <String>[];
    if (json['authors'] is List) {
      for (final author in json['authors'] as List) {
        if (author is Map && author['name'] is String) {
          authorsList.add(author['name'] as String);
        }
      }
    }

    final formats = json['formats'] as Map<String, dynamic>? ?? {};
    final summaries = json['summaries'] as List?;

    return Book(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Título desconhecido',
      authors: authorsList,
      coverUrl: _proxiedCoverUrl(formats['image/jpeg'] as String?),
      subjects:
          (json['subjects'] as List?)?.whereType<String>().toList() ?? const [],
      languages:
          (json['languages'] as List?)?.whereType<String>().toList() ??
          const [],
      description: summaries != null && summaries.isNotEmpty
          ? summaries.first as String?
          : null,
      downloadCount: json['download_count'] as int? ?? 0,
    );
  }

  String get authorsLabel =>
      authors.isEmpty ? 'Autor desconhecido' : authors.join(', ');

  /// gutenberg.org não envia cabeçalhos CORS nas imagens de capa, então o
  /// Flutter Web (renderer CanvasKit) bloqueia o download via fetch. O
  /// images.weserv.nl reencaminha a mesma imagem já com CORS liberado.
  static String? _proxiedCoverUrl(String? original) {
    if (original == null) return null;
    final withoutScheme = original.replaceFirst(RegExp(r'^https?://'), '');
    return 'https://images.weserv.nl/?url=${Uri.encodeComponent(withoutScheme)}';
  }
}
