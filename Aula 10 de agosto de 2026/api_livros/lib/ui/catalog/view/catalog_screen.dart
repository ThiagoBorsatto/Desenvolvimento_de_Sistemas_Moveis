import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../domain/models/book_category.dart';
import '../../book_detail/view/book_detail_screen.dart';
import '../../core/view_model/theme_view_model.dart';
import '../../core/widgets/book_card.dart';
import '../../core/widgets/theme_toggle_button.dart';
import '../view_model/catalog_view_model.dart';

/// Tela principal: acervo completo por padrão, com filtro por categoria e
/// busca opcionais.
class CatalogScreen extends StatefulWidget {
  final BookRepository bookRepository;
  final AuthRepository authRepository;
  final ThemeViewModel themeViewModel;

  const CatalogScreen({
    super.key,
    required this.bookRepository,
    required this.authRepository,
    required this.themeViewModel,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final CatalogViewModel _viewModel;
  final _searchController = TextEditingController();

  /// Controla se a barra superior está no modo busca (campo de texto) ou no
  /// modo normal (título + ícone de lupa).
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _viewModel = CatalogViewModel(widget.bookRepository)..load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _openSearch() => setState(() => _isSearchOpen = true);

  void _closeSearch() {
    setState(() => _isSearchOpen = false);
    _searchController.clear();
    _viewModel.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSearchOpen ? _buildSearchAppBar() : _buildDefaultAppBar(),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => Column(
          children: [
            _CategoryFilterBar(
              selected: _viewModel.selectedCategory,
              onSelected: _viewModel.selectCategory,
            ),
            if (_viewModel.isSearching && !_viewModel.isLoading)
              _ResultSummary(
                query: _viewModel.query,
                count: _viewModel.books.length,
              ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _viewModel.refresh,
                child: _buildResults(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildDefaultAppBar() {
    return AppBar(
      title: const Text('Catálogo de Livros'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Buscar livros',
          onPressed: _openSearch,
        ),
        ThemeToggleButton(viewModel: widget.themeViewModel),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sair',
          onPressed: () => widget.authRepository.signOut(),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Fechar busca',
        onPressed: _closeSearch,
      ),
      titleSpacing: 0,
      title: TextField(
        controller: _searchController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onChanged: _viewModel.onQueryChanged,
        onSubmitted: _viewModel.submitQuery,
        decoration: const InputDecoration(
          hintText: 'Título, autor ou assunto',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          isDense: true,
        ),
      ),
      actions: [
        // Reconstrói só este botão conforme o texto muda, para o "limpar"
        // aparecer e sumir sem um setState na tela inteira.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Limpar busca',
                  onPressed: () {
                    _searchController.clear();
                    _viewModel.clearSearch();
                  },
                ),
        ),
        ThemeToggleButton(viewModel: widget.themeViewModel),
      ],
    );
  }

  Widget _buildResults() {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = _viewModel.errorMessage;
    if (error != null) {
      return _MessageView(
        icon: Icons.wifi_off,
        message: error,
        onRetry: _viewModel.refresh,
      );
    }

    final books = _viewModel.books;
    if (books.isEmpty) {
      return _MessageView(
        icon: Icons.search_off,
        message: _viewModel.isSearching
            ? 'Nenhum livro encontrado para "${_viewModel.query}".'
            : 'Nenhum livro encontrado.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.6,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(
          book: book,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
          ),
        );
      },
    );
  }
}

/// Faixa horizontal de chips de categoria.
///
/// O primeiro chip é "Todos" e vem selecionado na abertura do app: o acervo
/// aparece inteiro e só se separa por categoria quando o usuário escolhe uma.
class _CategoryFilterBar extends StatelessWidget {
  final BookCategory? selected;
  final ValueChanged<BookCategory?> onSelected;

  const _CategoryFilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        // +1 pelo chip "Todos", que não é um valor do enum.
        itemCount: BookCategory.values.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: const Text('Todos'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            );
          }

          final category = BookCategory.values[index - 1];
          return ChoiceChip(
            label: Text(category.label),
            selected: category == selected,
            onSelected: (isSelected) =>
                onSelected(isSelected ? category : null),
          );
        },
      ),
    );
  }
}

/// Linha de resumo exibida durante uma busca ("N resultados para …").
class _ResultSummary extends StatelessWidget {
  final String query;
  final int count;

  const _ResultSummary({required this.query, required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 resultado' : '$count resultados';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$label para "$query"',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  const _MessageView({required this.icon, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(message, textAlign: TextAlign.center),
                  if (onRetry != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onRetry,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
