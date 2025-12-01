import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/venue_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/court/venue_card.dart';
import '../menu/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _searchCity = ''; // Empty means "All"

  // Pagination variables
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVenues();
    });

    // Add scroll listener for infinite scrolling
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Infinite scroll listener
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is 200px from bottom
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreVenues();
      }
    }
  }

  Future<void> _loadVenues() async {
    final venueProvider = context.read<VenueProvider>();

    // If no city is selected (All), fetch all venues
    if (_searchCity.isEmpty && _searchController.text.isEmpty) {
      await venueProvider.getAllVenues();
    } else {
      // Otherwise, search with filters
      await venueProvider.searchVenues(
        city: _searchCity.isNotEmpty ? _searchCity : null,
        name: _searchController.text.isNotEmpty ? _searchController.text : null,
      );
    }

    if (!mounted) return;

    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
    });
  }

  Future<void> _loadMoreVenues() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      // TODO: When you have real API with pagination, call it like this:
      // final venueProvider = context.read<VenueProvider>();
      // if (_searchCity.isEmpty && _searchController.text.isEmpty) {
      //   await venueProvider.getAllVenues(page: _currentPage + 1);
      // } else {
      //   await venueProvider.searchVenues(
      //     city: _searchCity.isNotEmpty ? _searchCity : null,
      //     name: _searchController.text.isNotEmpty ? _searchController.text : null,
      //     page: _currentPage + 1,
      //   );
      // }

      // Simulate API call delay for now
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

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
    await _loadVenues(); // Reuse the same logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text('FUTSMANDU'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                context.push(RouteNames.profile);
              },
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      authProvider.user?.fullName.isNotEmpty ?? false
                          ? authProvider.user!.fullName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(child: _buildBodyContent()),
        ],
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Show "Add Court" button only when user is in owner mode
          if (authProvider.user?.isInOwnerMode ?? false) {
            return FloatingActionButton.extended(
              onPressed: () {
                Helpers.showSnackbar(context, 'Add court coming soon!');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Court'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCityChip(String label, String value) {
    final isSelected = _searchCity == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _searchCity = value; // Set the selected city (empty for "All")
          });
          _searchVenues(); // Fetch venues based on the selected city
        },
        selectedColor: Color.fromRGBO(
          AppTheme.primaryColor.red,
          AppTheme.primaryColor.green,
          AppTheme.primaryColor.blue,
          0.2,
        ),
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
              hintText: 'Search venues by name',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _searchVenues();
                },
              )
                  : null,
            ),
            onSubmitted: (_) => _searchVenues(),
            onChanged: (_) {
              setState(() {}); // Update UI to show/hide clear button
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'City: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCityChip('All', ''),
                      _buildCityChip('Kathmandu', 'Kathmandu'),
                      _buildCityChip('Lalitpur', 'Lalitpur'),
                      _buildCityChip('Bhaktapur', 'Bhaktapur'),
                    ],
                  ),
                ),
              ),
            ],
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
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.clearError();
                    _loadVenues();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.venues.isEmpty && _currentPage == 1) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchCity.isEmpty && _searchController.text.isEmpty
                      ? 'No venues available'
                      : 'No venues found matching your search',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (_searchCity.isNotEmpty || _searchController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchCity = '';
                        _searchController.clear();
                      });
                      _loadVenues();
                    },
                    child: const Text('Clear filters'),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadVenues,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppTheme.paddingM),
            itemCount: provider.venues.length + (_hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom
              if (index == provider.venues.length) {
                return _buildLoadingMoreIndicator();
              }

              return VenueCard(
                venue: provider.venues[index],
                onTap: () {
                  // Navigate to court detail screen when ready
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
            'No more venues to load',
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