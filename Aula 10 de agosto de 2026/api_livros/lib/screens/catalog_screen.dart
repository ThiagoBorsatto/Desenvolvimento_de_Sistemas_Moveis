import 'dart:async';

import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/auth_service.dart';
import '../services/book_service.dart';
import '../widgets/book_card.dart';
import 'book_detail_screen.dart';

class _Category {
  final String label;
  final String subject;

  const _Category(this.label, this.subject);
}

const _categories = [
  _Category('Ficção', 'fiction'),
  _Category('Fantasia', 'fantasy'),
  _Category('Romance', 'romance'),
  _Category('História', 'history'),
  _Category('Mistério', 'mystery'),
  _Category('Infantil', 'juvenile_fiction'),
];

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _service = BookService();
  final _searchController = TextEditingController();
  Timer? _debounce;

  String _selectedSubject = _categories.first.subject;
  String? _activeQuery;
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _service.fetchBySubject(_selectedSubject);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = value.trim();
      setState(() {
        _activeQuery = query.isEmpty ? null : query;
        _booksFuture = _activeQuery != null
            ? _service.search(_activeQuery!)
            : _service.fetchBySubject(_selectedSubject);
      });
    });
  }

  void _selectCategory(String subject) {
    setState(() {
      _selectedSubject = subject;
      _activeQuery = null;
      _searchController.clear();
      _booksFuture = _service.fetchBySubject(subject);
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _booksFuture = _activeQuery != null
          ? _service.search(_activeQuery!)
          : _service.fetchBySubject(_selectedSubject);
    });
    await _booksFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Livros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar por título ou autor',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      ),
                isDense: true,
              ),
            ),
          ),
          if (_activeQuery == null)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final selected = category.subject == _selectedSubject;
                  return ChoiceChip(
                    label: Text(category.label),
                    selected: selected,
                    onSelected: (_) => _selectCategory(category.subject),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<Book>>(
                future: _booksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _MessageView(
                      icon: Icons.wifi_off,
                      message: 'Não foi possível carregar os livros.\nVerifique sua conexão e tente novamente.',
                      onRetry: _refresh,
                    );
                  }
                  final books = snapshot.data ?? [];
                  if (books.isEmpty) {
                    return const _MessageView(
                      icon: Icons.search_off,
                      message: 'Nenhum livro encontrado.',
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
                },
              ),
            ),
          ),
        ],
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
                  Icon(icon, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(message, textAlign: TextAlign.center),
                  if (onRetry != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
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
