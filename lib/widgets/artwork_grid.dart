import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../services/api_service.dart';
import '../models/artworks.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArtworkGrid extends StatefulWidget {
  const ArtworkGrid({super.key});

  @override
  State<ArtworkGrid> createState() => _ArtworkGridState();
}

class _ArtworkGridState extends State<ArtworkGrid> with AutomaticKeepAliveClientMixin {
  static const _pageSize = 10;
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
          _pagingController.appendPage(newItems, pageKey + 1);
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
    super.build(context);

    return RefreshIndicator(
      onRefresh: () async {
        _pagingController.refresh();
      },
      child: PagedGridView<int, Artwork>(
        pagingController: _pagingController,
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        padding: const EdgeInsets.all(16.0),
        builderDelegate: PagedChildBuilderDelegate<Artwork>(
          itemBuilder: (context, item, index) => Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image)),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: NetworkImage(item.userProfileUrl),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.userName,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
          newPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
          noItemsFoundIndicatorBuilder: (_) => const Center(child: Text('No artworks found')),
          newPageErrorIndicatorBuilder: (_) => Center(
            child: Column(
              children: [
                const Text('Something went wrong. Pull to retry.'),
                TextButton(
                  onPressed: () => _pagingController.retryLastFailedRequest(),
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pagingController.refresh();
  }

  @override
  bool get wantKeepAlive => true;
}
