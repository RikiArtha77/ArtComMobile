// artwork_grid.dart

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../services/api_service.dart';
import '../models/artworks.dart';

class ArtworkGrid extends StatefulWidget {
  const ArtworkGrid({super.key});

  @override
  State<ArtworkGrid> createState() => _ArtworkGridState();
}

class _ArtworkGridState extends State<ArtworkGrid> {
  static const _pageSize = 10;
  final PagingController<int, Artwork> _pagingController = PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      // REVISED: Panggil API dengan pageSize.
      final apiResponse = await ApiService.fetchArtworks(pageKey, pageSize: _pageSize);

      // REVISED: Periksa apakah panggilan API berhasil.
      if (apiResponse['success'] == true) {
        final newItems = apiResponse['artworks'] as List<Artwork>;
        final isLastPage = apiResponse['isLastPage'] as bool;

        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(newItems, nextPageKey);
        }
      } else {
        // REVISED: Jika gagal, lemparkan error dengan pesan dari API.
        throw Exception(apiResponse['message']);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedGridView<int, Artwork>(
      pagingController: _pagingController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      padding: const EdgeInsets.all(16.0),
      builderDelegate: PagedChildBuilderDelegate<Artwork>(
        itemBuilder: (context, item, index) => Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
        newPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
        noItemsFoundIndicatorBuilder: (_) => const Center(child: Text('No artworks found')),
        newPageErrorIndicatorBuilder: (_) =>
            const Center(child: Text('Something went wrong. Pull to retry.')),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}