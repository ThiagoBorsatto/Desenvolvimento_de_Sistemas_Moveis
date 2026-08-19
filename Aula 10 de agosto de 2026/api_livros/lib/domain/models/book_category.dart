/// Categorias oferecidas como filtro no catálogo.
enum BookCategory {
  fiction('Ficção', 'fiction'),
  fantasy('Fantasia', 'fantasy'),
  romance('Romance', 'romance'),
  history('História', 'history'),
  mystery('Mistério', 'mystery'),
  children('Infantil', 'children');

  const BookCategory(this.label, this.topic);

  /// Nome exibido no chip de filtro.
  final String label;

  /// Termo enviado no parâmetro `topic` da Gutendex, que casa contra os
  /// assuntos (`subjects`) e as estantes (`bookshelves`) do livro.
  final String topic;
}
