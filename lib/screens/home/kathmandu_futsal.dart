import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/court_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/court/futsal_card.dart';

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

  // Kathmandu-specific dummy data
  final List<_DummyFutsal> _kathmanduCourts = const [
    _DummyFutsal(
      name: 'Valley Futsal Arena',
      city: 'Kathmandu',
      description: 'Premium turf with LED lighting and locker facilities.',
      priceRange: 'Rs. 2,200 / hour',
      surfaceType: '5-a-side • Hybrid turf',
      accentColor: Color(0xFFE3F2FD),
    ),
    _DummyFutsal(
      name: 'Summit Arena',
      city: 'Kathmandu',
      description: 'Indoor court with climate control for all-weather play.',
      priceRange: 'Rs. 2,500 / hour',
      surfaceType: '5-a-side • Indoor mat',
      accentColor: Color(0xFFF3E5F5),
    ),
    _DummyFutsal(
      name: 'Thamel Futsal Center',
      city: 'Kathmandu',
      description: 'Located in the heart of Thamel with modern facilities.',
      priceRange: 'Rs. 2,300 / hour',
      surfaceType: '6-a-side • Synthetic turf',
      accentColor: Color(0xFFFFF3E0),
    ),
    _DummyFutsal(
      name: 'City Sports Complex',
      city: 'Kathmandu',
      description: 'Multi-court facility with professional lighting.',
      priceRange: 'Rs. 2,400 / hour',
      surfaceType: '5-a-side • Astro turf',
      accentColor: Color(0xFFE8F5E9),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKathmanduCourts();
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
        _loadMoreCourts();
      }
    }
  }

  Future<void> _loadKathmanduCourts() async {
    final courtProvider = context.read<CourtProvider>();
    await courtProvider.searchCourts(city: 'Kathmandu');

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
        title: const Text('Futsal Courts in Kathmandu'),
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
              hintText: 'Search futsal courts in Kathmandu...',
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
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    // For now, using dummy data. Replace with actual API call when ready
    return _buildKathmanduCourtsList();
  }

  Widget _buildKathmanduCourtsList() {
    final repeatedCourts = List.generate(
      12, // Show 12 items (3 sets of 4 courts)
          (index) => _kathmanduCourts[index % _kathmanduCourts.length],
    );

    return RefreshIndicator(
      onRefresh: _loadKathmanduCourts,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppTheme.paddingM),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: repeatedCourts.length + (_hasMoreData ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
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
            'No more courts in Kathmandu',
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

// Reuse these classes from home_screen.dart or move to separate file
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
              color.withOpacity(0.7),
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
              backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
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