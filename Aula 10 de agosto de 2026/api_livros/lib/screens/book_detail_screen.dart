import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/book_service.dart';
import '../theme/app_theme.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _service = BookService();
  late final Future<String?> _descriptionFuture;

  @override
  void initState() {
    super.initState();
    _descriptionFuture = _service.fetchDescription(widget.book.workKey);
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final coverUrl = book.coverUrl(size: 'L');

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        bottom: const GothicDivider(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Hero(
              tag: book.workKey,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 160,
                  height: 240,
                  child: coverUrl == null
                      ? Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: const Icon(Icons.menu_book_outlined, size: 48),
                        )
                      : Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: const Icon(Icons.menu_book_outlined, size: 48),
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            book.title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            book.authorsLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          if (book.firstPublishYear != null) ...[
            const SizedBox(height: 4),
            Text(
              'Publicado em ${book.firstPublishYear}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          Text('Sinopse', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<String?>(
            future: _descriptionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final description = snapshot.data;
              if (description == null || description.isEmpty) {
                return Text(
                  'Sinopse não disponível para este livro.',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              }
              return Text(description, style: Theme.of(context).textTheme.bodyMedium);
            },
          ),
          if (book.subjects.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Assuntos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: book.subjects
                  .take(8)
                  .map((subject) => Chip(label: Text(subject)))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
