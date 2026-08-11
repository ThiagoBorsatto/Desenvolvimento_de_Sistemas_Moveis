/// Representa um livro retornado pela Open Library API.
///
/// A API expõe os mesmos dados com nomes de campos diferentes conforme o
/// endpoint (busca vs. lista por assunto), por isso o [fromJson] normaliza
/// ambos os formatos.
class Book {
  final String workKey;
  final String title;
  final List<String> authors;
  final int? coverId;
  final int? firstPublishYear;
  final List<String> subjects;

  const Book({
    required this.workKey,
    required this.title,
    required this.authors,
    required this.coverId,
    required this.firstPublishYear,
    required this.subjects,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final authorsList = <String>[];
    if (json['author_name'] is List) {
      authorsList.addAll((json['author_name'] as List).whereType<String>());
    } else if (json['authors'] is List) {
      for (final author in json['authors'] as List) {
        if (author is Map && author['name'] is String) {
          authorsList.add(author['name'] as String);
        }
      }
    }

    return Book(
      workKey: json['key'] as String? ?? '',
      title: json['title'] as String? ?? 'Título desconhecido',
      authors: authorsList,
      coverId: (json['cover_i'] ?? json['cover_id']) as int?,
      firstPublishYear: json['first_publish_year'] as int?,
      subjects: (json['subject'] as List?)?.whereType<String>().toList() ?? const [],
    );
  }

  String get authorsLabel => authors.isEmpty ? 'Autor desconhecido' : authors.join(', ');

  String? coverUrl({String size = 'M'}) {
    if (coverId == null) return null;
    return 'https://covers.openlibrary.org/b/id/$coverId-$size.jpg';
  }
}
