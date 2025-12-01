import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/venue_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/court/venue_card.dart';

class KathmanduFutsalScreen extends StatefulWidget {
  const KathmanduFutsalScreen({super.key});

  @override
  State<KathmanduFutsalScreen> createState() => _KathmanduFutsalScreenState();
}

class _KathmanduFutsalScreenState extends State<KathmanduFutsalScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  // Pagination variables
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKathmanduVenues();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreVenues();
      }
    }
  }

  Future<void> _loadKathmanduVenues() async {
    final venueProvider = context.read<VenueProvider>();
    await venueProvider.searchVenues(city: 'Kathmandu');

    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
    });
  }

  Future<void> _loadMoreVenues() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _currentPage++;
        if (_currentPage > 3) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      if (mounted) {
        Helpers.showSnackbar(
          context,
          'Failed to load more venues',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _searchVenues() async {
    final venueProvider = context.read<VenueProvider>();
    await venueProvider.searchVenues(
      city: 'Kathmandu',
      name: _searchController.text.isNotEmpty ? _searchController.text : null,
    );

    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Venues in Kathmandu'),
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(child: _buildBodyContent()),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingM),
      color: AppTheme.surfaceColor,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search venues in Kathmandu...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _searchVenues();
                },
              ),
            ),
            onSubmitted: (_) => _searchVenues(),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    return Consumer<VenueProvider>(
      builder: (context, provider, _) {
        if (provider.isSearching && _currentPage == 1) {
          return const LoadingWidget(message: 'Loading venues...');
        }

        if (provider.errorMessage != null && _currentPage == 1) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  provider.errorMessage!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.clearError();
                    _loadKathmanduVenues();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.venues.isEmpty && _currentPage == 1) {
          return const Center(
            child: Text(
              'No venues found in Kathmandu',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadKathmanduVenues,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppTheme.paddingM),
            itemCount: provider.venues.length + (_hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.venues.length) {
                return _buildLoadingMoreIndicator();
              }

              return VenueCard(
                venue: provider.venues[index],
                onTap: () {
                  Helpers.showSnackbar(
                    context,
                    'Court detail coming soon!',
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingMoreIndicator() {
    if (!_hasMoreData) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No more venues in Kathmandu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator()
            : const SizedBox.shrink(),
      ),
    );
  }

}
