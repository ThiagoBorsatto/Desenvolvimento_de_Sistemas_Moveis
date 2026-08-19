/// Categorias oferecidas como filtro no catálogo.
///
/// Não existe um valor "Todos": ausência de filtro é representada por
/// `BookCategory?` nulo, que é o estado inicial da tela.
enum BookCategory {
  fiction('Ficção', 'fiction'),
  fantasy('Fantasia', 'fantasy'),
  romance('Romance', 'romance'),
  history('História', 'history'),
  mystery('Mistério', 'mystery'),
  children('Infantil', 'children'),
  poetry('Poesia', 'poetry'),
  adventure('Aventura', 'adventure');

  const BookCategory(this.label, this.topic);

  /// Nome exibido no chip de filtro.
  final String label;

  /// Termo enviado no parâmetro `topic` da Gutendex, que casa contra os
  /// assuntos (`subjects`) e as estantes (`bookshelves`) do livro.
  final String topic;
}
