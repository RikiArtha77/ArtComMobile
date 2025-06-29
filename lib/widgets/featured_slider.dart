import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../services/api_service.dart';
import '../models/artworks.dart';
import '../widgets/error_indicator.dart';

class FeaturedSlider extends StatefulWidget {
  const FeaturedSlider({super.key});

  @override
  State<FeaturedSlider> createState() => _FeaturedSliderState();
}

class _FeaturedSliderState extends State<FeaturedSlider> {
  static const _pageSize = 5;
  final PagingController<int, Artwork> _pagingController = PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final apiResponse = await ApiService.fetchArtworks(pageKey, pageSize: _pageSize);

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
        throw Exception(apiResponse['message']);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PagedListView<int, Artwork>(
        pagingController: _pagingController,
        scrollDirection: Axis.horizontal,
        builderDelegate: PagedChildBuilderDelegate<Artwork>(
          itemBuilder: (context, item, index) => Container(
            width: 300,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image, size: 40)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Perbaikan ditambahkan di sini
                    ),
                  ),
                ],
              ),
            ),
          ),
          firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
            message: _pagingController.error.toString(),
            onTryAgain: () => _pagingController.retryLastFailedRequest(),
          ),
          newPageErrorIndicatorBuilder: (context) => ErrorIndicator(
            message: _pagingController.error.toString(),
            onTryAgain: () => _pagingController.retryLastFailedRequest(),
          ),
          firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
          newPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
          noItemsFoundIndicatorBuilder: (_) =>
              const Center(child: Text('No featured artworks found')),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}