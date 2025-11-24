import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/court_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading.dart';
// Remove unused import: import '../../widgets/common/error_widget.dart';
import '../../widgets/court/futsal_card.dart';
import '../../widgets/common/app_drawer.dart';

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

  final List<_DummyFutsal> _dummyCourts = const [
    _DummyFutsal(
      name: 'Valley Futsal Arena',
      city: 'Kathmandu',
      description: 'Premium turf with LED lighting and locker facilities.',
      priceRange: 'Rs. 2,200 / hour',
      surfaceType: '5-a-side • Hybrid turf',
      accentColor: Color(0xFFE3F2FD),
    ),
    _DummyFutsal(
      name: 'Heritage Sports Hub',
      city: 'Bhaktapur',
      description: 'Spacious court ideal for evening matches and training.',
      priceRange: 'Rs. 1,900 / hour',
      surfaceType: '5-a-side • Synthetic grass',
      accentColor: Color(0xFFFFF3E0),
    ),
    _DummyFutsal(
      name: 'Riverside Kick Park',
      city: 'Lalitpur',
      description: 'Scenic riverside venue with cafe and chill zone.',
      priceRange: 'Rs. 2,000 / hour',
      surfaceType: '6-a-side • Astro turf',
      accentColor: Color(0xFFE8F5E9),
    ),
    _DummyFutsal(
      name: 'Summit Arena',
      city: 'Kathmandu',
      description: 'Indoor court with climate control for all-weather play.',
      priceRange: 'Rs. 2,500 / hour',
      surfaceType: '5-a-side • Indoor mat',
      accentColor: Color(0xFFF3E5F5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourts();
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
        _loadMoreCourts();
      }
    }
  }

  Future<void> _loadCourts() async {
    final courtProvider = context.read<CourtProvider>();
    await courtProvider.searchCourts();

    // Reset pagination
    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
    });
  }

  Future<void> _loadMoreCourts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Remove unused variable
      // final courtProvider = context.read<CourtProvider>();

      // TODO: When you have real API with pagination, call it like this:
      // await courtProvider.searchCourts(
      //   city: _searchCity.isNotEmpty ? _searchCity : null,
      //   name: _searchController.text.isNotEmpty ? _searchController.text : null,
      //   page: _currentPage + 1,
      // );

      // Simulate API call delay for now
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _currentPage++;
        // If API returns empty or less than expected, set _hasMoreData = false
        // For now, we'll stop after page 3
        if (_currentPage > 3) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      if (mounted) {
        Helpers.showSnackbar(
          context,
          'Failed to load more courts',
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

  Future<void> _searchCourts() async {
    final courtProvider = context.read<CourtProvider>();
    await courtProvider.searchCourts(
      city: _searchCity.isNotEmpty ? _searchCity : null,
      name: _searchController.text.isNotEmpty ? _searchController.text : null,
    );

    // Reset pagination when searching
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
          if (authProvider.user?.isOwner ?? false) {
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
            _searchCourts();
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
                  _searchCourts();
                },
              ),
            ),
            onSubmitted: (_) => _searchCourts(),
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
    if (_searchCity.isEmpty && _searchController.text.isEmpty) {
      return _buildDummyCourtsList();
    }

    return Consumer<CourtProvider>(
      builder: (context, provider, _) {
        if (provider.isSearching && _currentPage == 1) {
          return const LoadingWidget(message: 'Loading courts...');
        }

        if (provider.courts.isEmpty && _currentPage == 1) {
          return const Center(
            child: Text(
              'No futsal courts found',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadCourts,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppTheme.paddingM),
            itemCount: provider.courts.length + (_hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom
              if (index == provider.courts.length) {
                return _buildLoadingMoreIndicator();
              }

              return FutsalCard(
                futsalCourt: provider.courts[index],
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

  Widget _buildDummyCourtsList() {
    // Create repeated dummy data for demonstration
    final repeatedCourts = List.generate(
      20, // Show 20 items (5 sets of 4 courts)
          (index) => _dummyCourts[index % _dummyCourts.length],
    );

    return RefreshIndicator(
      onRefresh: _loadCourts,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppTheme.paddingM),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: repeatedCourts.length + (_hasMoreData ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          // Show loading indicator at the bottom
          if (index == repeatedCourts.length) {
            return _buildLoadingMoreIndicator();
          }

          final court = repeatedCourts[index];
          return _buildDummyCourtCard(court);
        },
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    if (!_hasMoreData) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No more courts to load',
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

  Widget _buildDummyCourtCard(_DummyFutsal court) {
    return InkWell(
      onTap: () => _showCourtDetails(court),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 500;
            return isCompact
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DummyImagePlaceholder(color: court.accentColor),
                const SizedBox(height: 12),
                _DummyCourtDetails(
                  court: court,
                  onTap: () => _showCourtDetails(court),
                ),
              ],
            )
                : Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _DummyImagePlaceholder(color: court.accentColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: _DummyCourtDetails(
                    court: court,
                    onTap: () => _showCourtDetails(court),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCourtDetails(_DummyFutsal court) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  court.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  court.city,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  court.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Surface: ${court.surfaceType}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rate: ${court.priceRange}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DummyFutsal {
  final String name;
  final String city;
  final String description;
  final String priceRange;
  final String surfaceType;
  final Color accentColor;

  const _DummyFutsal({
    required this.name,
    required this.city,
    required this.description,
    required this.priceRange,
    required this.surfaceType,
    required this.accentColor,
  });
}

class _DummyImagePlaceholder extends StatelessWidget {
  final Color color;

  const _DummyImagePlaceholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color,
              // FIXED: Replace withOpacity with Color.fromRGBO
              Color.fromRGBO(color.red, color.green, color.blue, 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(
          Icons.sports_soccer,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _DummyCourtDetails extends StatelessWidget {
  final _DummyFutsal court;
  final VoidCallback onTap;

  const _DummyCourtDetails({required this.court, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          court.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          court.city,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          court.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text(court.surfaceType),
              // FIXED: Replace withOpacity with Color.fromRGBO
              backgroundColor: Color.fromRGBO(
                AppTheme.primaryColor.red,
                AppTheme.primaryColor.green,
                AppTheme.primaryColor.blue,
                0.08,
              ),
            ),
            Chip(
              label: Text(court.priceRange),
              backgroundColor: AppTheme.surfaceColor,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.info_outline),
            label: const Text('View details'),
          ),
        ),
      ],
    );
  }
}