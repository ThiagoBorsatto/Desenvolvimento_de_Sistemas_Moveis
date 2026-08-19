import 'package:api_livros/data/repositories/book_repository.dart';
import 'package:api_livros/domain/models/book.dart';
import 'package:api_livros/domain/models/book_category.dart';
import 'package:api_livros/ui/catalog/view_model/catalog_view_model.dart';
import 'package:api_livros/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dublê do repositório: registra como foi chamado e devolve o que o teste
/// mandar, sem tocar na rede. Só é possível porque [BookRepository] é uma
/// interface e a ViewModel a recebe pelo construtor.
class _FakeBookRepository implements BookRepository {
  final List<BookCategory?> catalogCalls = [];
  final List<String> searchCalls = [];

  List<Book> booksToReturn = const [];
  String? failureMessage;

  @override
  Future<Result<List<Book>>> loadCatalog({
    BookCategory? category,
    bool forceRefresh = false,
  }) async {
    catalogCalls.add(category);
    return _result();
  }

  @override
  Future<Result<List<Book>>> search({
    required String query,
    bool forceRefresh = false,
  }) async {
    searchCalls.add(query);
    return _result();
  }

  Result<List<Book>> _result() {
    final message = failureMessage;
    if (message != null) return Failure(message);
    return Ok(booksToReturn);
  }
}

Book _book(int id, String title) => Book(
  id: id,
  title: title,
  authors: const ['Autor'],
  coverUrl: null,
  subjects: const [],
  description: null,
);

void main() {
  late _FakeBookRepository repository;
  late CatalogViewModel viewModel;

  setUp(() {
    repository = _FakeBookRepository();
    viewModel = CatalogViewModel(repository);
  });

  tearDown(() => viewModel.dispose());

  test('começa sem filtro e carrega o acervo completo', () async {
    repository.booksToReturn = [_book(1, 'Dom Casmurro')];

    expect(viewModel.selectedCategory, isNull);
    expect(viewModel.hasActiveFilter, isFalse);

    await viewModel.load();

    // Categoria nula = nenhum filtro enviado para a API.
    expect(repository.catalogCalls, [null]);
    expect(viewModel.books, hasLength(1));
    expect(viewModel.isLoading, isFalse);
  });

  test('selecionar uma categoria passa a filtrar o acervo', () async {
    await viewModel.load();
    viewModel.selectCategory(BookCategory.fantasy);
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.selectedCategory, BookCategory.fantasy);
    expect(viewModel.hasActiveFilter, isTrue);
    expect(repository.catalogCalls, [null, BookCategory.fantasy]);
  });

  test('voltar para "Todos" remove o filtro', () async {
    await viewModel.load();
    viewModel.selectCategory(BookCategory.history);
    await Future<void>.delayed(Duration.zero);
    viewModel.selectCategory(null);
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.selectedCategory, isNull);
    expect(repository.catalogCalls, [null, BookCategory.history, null]);
  });

  test('busca envia o termo sem espaços em volta', () async {
    viewModel.submitQuery('  machado  ');
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.isSearching, isTrue);
    expect(viewModel.query, 'machado');
    expect(repository.searchCalls, ['machado']);
  });

  test('limpar a busca volta para o catálogo', () async {
    viewModel.submitQuery('machado');
    await Future<void>.delayed(Duration.zero);
    viewModel.clearSearch();
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.isSearching, isFalse);
    expect(repository.catalogCalls, [null]);
  });

  test('falha do repositório vira mensagem de erro e lista vazia', () async {
    repository.failureMessage = 'Sem conexão.';

    await viewModel.load();

    expect(viewModel.errorMessage, 'Sem conexão.');
    expect(viewModel.books, isEmpty);
    expect(viewModel.isLoading, isFalse);
  });
}
