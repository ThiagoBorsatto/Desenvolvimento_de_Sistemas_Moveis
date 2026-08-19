import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/book_repository.dart';
import '../../../domain/models/book.dart';
import '../../../domain/models/book_category.dart';
import '../../../utils/result.dart';

/// Estado e regras da tela de catálogo.
///
/// Concentra tudo que não é desenho: qual categoria está ativa, o termo de
/// busca, o debounce do teclado, o descarte de respostas obsoletas e a
/// mensagem de erro. A view só lê estes getters e chama estes métodos.
class CatalogViewModel extends ChangeNotifier {
  /// Espera antes de disparar a busca, para não fazer uma requisição por tecla.
  static const debounceDuration = Duration(milliseconds: 500);

  final BookRepository _repository;

  CatalogViewModel(this._repository);

  List<Book> _books = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String _query = '';

  /// Nulo significa "sem filtro": é o estado inicial da tela, em que o acervo
  /// aparece inteiro, sem separação por categoria. As categorias só entram em
  /// cena quando o usuário toca em um chip.
  BookCategory? _selectedCategory;

  Timer? _debounce;

  /// Identifica a requisição em voo. Respostas de requisições antigas
  /// (usuário trocou de filtro no meio do carregamento) são descartadas.
  int _requestId = 0;

  bool _disposed = false;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  BookCategory? get selectedCategory => _selectedCategory;
  bool get isSearching => _query.isNotEmpty;
  bool get hasActiveFilter => _selectedCategory != null;

  Future<void> load() => _fetch();

  Future<void> refresh() => _fetch(forceRefresh: true);

  /// [category] nulo volta para o acervo completo (chip "Todos"). Trocar de
  /// categoria encerra a busca em andamento.
  void selectCategory(BookCategory? category) {
    if (category == _selectedCategory && _query.isEmpty) return;
    _selectedCategory = category;
    _query = '';
    _debounce?.cancel();
    notifyListeners();
    _fetch();
  }

  /// Chamado a cada tecla digitada no campo de busca.
  void onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(debounceDuration, () => submitQuery(value));
  }

  /// Dispara a busca imediatamente, sem esperar o debounce (usado quando o
  /// usuário confirma no teclado).
  void submitQuery(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed == _query) return;
    _query = trimmed;
    notifyListeners();
    _fetch();
  }

  void clearSearch() => submitQuery('');

  Future<void> _fetch({bool forceRefresh = false}) async {
    final requestId = ++_requestId;

    _isLoading = true;
    _errorMessage = null;
    _notify();

    final result = _query.isEmpty
        ? await _repository.loadCatalog(
            category: _selectedCategory,
            forceRefresh: forceRefresh,
          )
        : await _repository.search(query: _query, forceRefresh: forceRefresh);

    // Outra requisição começou depois desta: o resultado aqui já não vale.
    if (requestId != _requestId) return;

    switch (result) {
      case Ok(:final value):
        _books = value;
        _errorMessage = null;
      case Failure(:final message):
        _books = const [];
        _errorMessage = message;
    }

    _isLoading = false;
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}
