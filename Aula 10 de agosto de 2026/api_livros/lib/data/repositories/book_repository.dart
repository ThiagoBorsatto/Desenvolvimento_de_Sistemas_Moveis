import '../../domain/models/book.dart';
import '../../domain/models/book_category.dart';
import '../../utils/result.dart';
import '../services/book_api_service.dart';

/// Fonte de livros para as ViewModels.
///
/// É uma interface, e não uma classe concreta, para que os testes possam
/// injetar uma implementação falsa sem tocar na rede.
abstract class BookRepository {
  /// Livros de uma categoria.
  Future<Result<List<Book>>> loadCatalog({
    required BookCategory category,
    bool forceRefresh = false,
  });

  /// Busca livre por título ou nome do autor.
  Future<Result<List<Book>>> search({
    required String query,
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
    required BookCategory category,
    bool forceRefresh = false,
  }) {
    return _guard(
      cacheKey: 'catalog:${category.topic}',
      forceRefresh: forceRefresh,
      request: () => _api.fetchBooks(topic: category.topic),
    );
  }

  @override
  Future<Result<List<Book>>> search({
    required String query,
    bool forceRefresh = false,
  }) {
    final term = query.trim();
    return _guard(
      cacheKey: 'search:$term',
      forceRefresh: forceRefresh,
      request: () => _api.fetchBooks(search: term),
    );
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
