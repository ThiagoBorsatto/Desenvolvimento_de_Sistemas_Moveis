import '../../domain/models/book.dart';
import '../../domain/models/book_category.dart';
import '../../utils/result.dart';
import '../services/book_api_service.dart';

/// Fonte de livros para as ViewModels.
///
/// É uma interface, e não uma classe concreta, para que os testes possam
/// injetar uma implementação falsa sem tocar na rede.
abstract class BookRepository {
  /// Catálogo da tela inicial. Com [category] nulo devolve o acervo inteiro
  /// (nenhum filtro aplicado), que é o estado padrão da tela.
  Future<Result<List<Book>>> loadCatalog({
    BookCategory? category,
    bool forceRefresh = false,
  });

  /// Busca livre. Casa contra título, nome do autor e — quando nenhuma
  /// categoria está selecionada — também contra assuntos e estantes do livro.
  Future<Result<List<Book>>> search({
    required String query,
    BookCategory? category,
    bool forceRefresh = false,
  });
}

/// Implementação sobre a Gutendex, com cache em memória por consulta.
///
/// O cache existe porque alternar entre os chips de categoria refazia uma
/// requisição HTTP a cada toque, mesmo voltando para uma categoria já vista.
class BookRepositoryRemote implements BookRepository {
  final BookApiService _api;
  final Map<String, List<Book>> _cache = {};

  BookRepositoryRemote(this._api);

  @override
  Future<Result<List<Book>>> loadCatalog({
    BookCategory? category,
    bool forceRefresh = false,
  }) {
    return _guard(
      cacheKey: 'catalog:${category?.topic ?? 'all'}',
      forceRefresh: forceRefresh,
      request: () => _api.fetchBooks(topic: category?.topic),
    );
  }

  @override
  Future<Result<List<Book>>> search({
    required String query,
    BookCategory? category,
    bool forceRefresh = false,
  }) {
    final term = query.trim();
    if (term.isEmpty) {
      return loadCatalog(category: category, forceRefresh: forceRefresh);
    }

    return _guard(
      cacheKey: 'search:$term:${category?.topic ?? 'all'}',
      forceRefresh: forceRefresh,
      request: () => _searchBooks(term, category),
    );
  }

  /// A Gutendex separa a busca em dois parâmetros: `search` cobre título e
  /// autor, `topic` cobre assuntos e estantes. Para o usuário isso é uma coisa
  /// só ("procurar por qualquer atributo"), então sem categoria selecionada
  /// disparamos as duas consultas em paralelo e unimos os resultados.
  ///
  /// Com uma categoria ativa o `topic` já está ocupado pelo filtro, então a
  /// busca fica restrita a título e autor dentro daquela categoria.
  Future<List<Book>> _searchBooks(String term, BookCategory? category) async {
    if (category != null) {
      return _api.fetchBooks(search: term, topic: category.topic);
    }

    final responses = await Future.wait([
      _api.fetchBooks(search: term),
      _api.fetchBooks(topic: term),
    ]);

    final merged = <int, Book>{};
    for (final books in responses) {
      for (final book in books) {
        merged.putIfAbsent(book.id, () => book);
      }
    }
    final result = merged.values.toList()
      ..sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
    return result;
  }

  /// Executa [request] respeitando o cache e converte qualquer exceção da
  /// camada de dados em um [Failure] com mensagem pronta para a tela.
  Future<Result<List<Book>>> _guard({
    required String cacheKey,
    required bool forceRefresh,
    required Future<List<Book>> Function() request,
  }) async {
    if (!forceRefresh) {
      final cached = _cache[cacheKey];
      if (cached != null) return Ok(cached);
    }

    try {
      final books = await request();
      _cache[cacheKey] = books;
      return Ok(books);
    } on BookApiException catch (error) {
      return Failure(
        'Não foi possível carregar os livros.\n'
        'Verifique sua conexão e tente novamente.',
        cause: error,
      );
    } on Exception catch (error) {
      return Failure(
        'Ocorreu um erro inesperado ao buscar os livros.',
        cause: error,
      );
    }
  }
}
