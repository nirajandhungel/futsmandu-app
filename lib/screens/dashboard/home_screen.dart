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
  String _searchCity = '';

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
    await venueProvider.getAllVenues(

    );

    if (!mounted) return;  // <-- IMPORTANT

    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
    });
  }
  // Future<void> _loadVenues() async {
  //   final venueProvider = context.read<VenueProvider>();
  //   await venueProvider.searchVenues(
  //     city: _searchCity.isNotEmpty ? _searchCity : null,
  //     name: _searchController.text.isNotEmpty ? _searchController.text : null,
  //   );

  //   if (!mounted) return;  // <-- IMPORTANT

  //   setState(() {
  //     _currentPage = 1;
  //     _hasMoreData = true;
  //   });
  // }

  Future<void> _loadMoreVenues() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMore = true;
    });


    try {
      // Remove unused variable
      // final venueProvider = context.read<VenueProvider>();

      // TODO: When you have real API with pagination, call it like this:
      // await venueProvider.searchVenues(
      //   city: _searchCity.isNotEmpty ? _searchCity : null,
      //   name: _searchController.text.isNotEmpty ? _searchController.text : null,
      //   page: _currentPage + 1,
      // );

      // Simulate API call delay for now
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;    // <-- ADD THIS

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
      city: _searchCity.isNotEmpty ? _searchCity : null,
      name: _searchController.text.isNotEmpty ? _searchController.text : null,
    );

    if (!mounted) return;  // <-- ADD THIS

    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
    });

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

  // FIXED: Removed duplicate method and fixed the single implementation
  Widget _buildCityChip(String label, String value) {
    final isSelected = _searchCity == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (value.isNotEmpty) {
            // Navigate to city-specific screen
            switch (value) {
              case 'Kathmandu':
                context.push('/kathmandu-futsal');
                break;
              case 'Bhaktapur':
                context.push('/bhaktapur-futsal');
                break;
              case 'Lalitpur':
                context.push('/lalitpur-futsal');
                break;
            }
          } else {
            // Stay in home screen (All)
            setState(() {
              _searchCity = value;
            });
            _searchVenues();
          }
        },
        // FIXED: Replace withOpacity with Color.fromRGBO
        selectedColor: Color.fromRGBO(
          AppTheme.primaryColor.red,
          AppTheme.primaryColor.green,
          AppTheme.primaryColor.blue,
          0.2,
        ),
      ),
    );
  }

  // FIXED: Added missing _buildSearchHeader method
  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingM),
      color: AppTheme.surfaceColor,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search',
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
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('City: '),
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
                    _loadVenues();
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
              'No venues found',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
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
