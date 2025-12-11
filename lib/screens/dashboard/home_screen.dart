// home_screen.dart (Final version with Material Icons)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/venue_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
// import '../../widgets/common/loading.dart';
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

  // Dashboard quick actions
  final List<DashboardAction> _quickActions = [
    DashboardAction(
      icon: Icons.calendar_today,
      title: 'My Bookings',
      subtitle: 'View upcoming bookings',
      route: RouteNames.mybookings,
      color: Color(0xFF2196F3), // Blue
    ),
    DashboardAction(
      icon: Icons.group,
      title: 'Join Teammates',
      subtitle: 'Find playing partners',
      route: RouteNames.joinTeammates,
      color: Color(0xFF4CAF50), // Green
    ),
    DashboardAction(
      icon: Icons.payment,
      title: 'My Payments',
      subtitle: 'Payment history & wallet',
      route: RouteNames.mybookings,
      color: Color(0xFF9C27B0), // Purple
    ),
    DashboardAction(
      icon: Icons.emoji_events,
      title: 'Active Tournaments',
      subtitle: 'Join competitions',
      route: RouteNames.mybookings,
      color: Color(0xFFFF9800), // Orange
    ),
  ];

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
    await _loadVenues();
  }

  @override
  Widget build(BuildContext context) {
      // Add this check at the beginning
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    
    if (user?.role=="OWNER"  && user?.mode =="OWNER" && user?.ownerStatus=="APPROVED") {
      // Redirect to owner dashboard
      context.go(RouteNames.ownerDashboard);
    } else if (user?.role=="ADMIN") {
      // Redirect to admin dashboard
      context.go(RouteNames.adminDashboard);
    }
  });
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 35, 34), 
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final user = authProvider.user;
                return Text(
                  'Hello, ${user?.fullName.split(' ').first ?? 'Guest'}!',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                );
              },
            ),
            const Text(
              'FUTSMANDU',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                context.push(RouteNames.profile);
              },
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: AppTheme.backgroundDark,
                      child: Text(
                        authProvider.user?.fullName.isNotEmpty ?? false
                            ? authProvider.user!.fullName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
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
      body: RefreshIndicator(
        onRefresh: _loadVenues,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Search Section
            SliverToBoxAdapter(
              child: _buildSearchSection(),
            ),
            // Welcome Banner
            SliverToBoxAdapter(
              child: _buildWelcomeBanner(),
            ),

            // Quick Actions Section
            SliverToBoxAdapter(
              child: _buildQuickActions(),
            ),


            // Featured Venues Section
            SliverToBoxAdapter(
              child: _buildFeaturedSection(),
            ),

            // All Venues Grid
            // _buildVenuesGrid(),

            // Loading indicator
            if (_isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),

            // "No more data" indicator
            if (!_hasMoreData && _currentPage > 1)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Center(
                    child: Text(
                      'No more venues to load',
                      style: TextStyle(
                        color: AppTheme.textSecondaryDark,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      )

    );
  }


    Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColorDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppTheme.dividerColorDark),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.search,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppTheme.textPrimaryDark),
                  decoration: InputDecoration(
                    hintText: 'Search venues by name...',
                    hintStyle: const TextStyle(color: AppTheme.textTertiaryDark),
                    border: InputBorder.none,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: AppTheme.textTertiaryDark,
                            onPressed: () {
                              _searchController.clear();
                              _searchVenues();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _searchVenues(),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by City:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCityChip('All', ''),
                    const SizedBox(width: 8),
                    _buildCityChip('Kathmandu', 'Kathmandu'),
                    const SizedBox(width: 8),
                    _buildCityChip('Lalitpur', 'Lalitpur'),
                    const SizedBox(width: 8),
                    _buildCityChip('Bhaktapur', 'Bhaktapur'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildWelcomeBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.darkPrimaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to play?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.buttonPrimaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Book your favorite futsal court in seconds',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.buttonPrimaryText.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      400,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.buttonPrimaryText,
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                  ),
                  child: const Text('Explore Courts'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          const Icon(
            Icons.sports_soccer,
            size: 60,
            color: AppTheme.buttonPrimaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: _quickActions.length,
            itemBuilder: (context, index) {
              final action = _quickActions[index];
              return GestureDetector(
                onTap: () {
                  context.push(action.route);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardColorDark,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: AppTheme.dividerColorDark.withOpacity(0.3),
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: action.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Icon(
                          action.icon,
                          color: action.color,
                          size: 24,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            action.subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textTertiaryDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildCityChip(String label, String value) {
    final isSelected = _searchCity == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.buttonPrimaryText : AppTheme.textPrimaryDark,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: AppTheme.backgroundDark,
      side: BorderSide(color: AppTheme.dividerColorDark),
      onSelected: (selected) {
        setState(() {
          _searchCity = selected ? value : '';
          _searchVenues();
        });
      },
    );
  }

  Widget _buildFeaturedSection() {
    return Consumer<VenueProvider>(
      builder: (context, provider, _) {
        if (provider.venues.isEmpty) return const SizedBox.shrink();
        
        final featuredVenues = provider.venues.toList();
        // final featuredVenues = provider.venues.take(3).toList();
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Courts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to all venues or featured list
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: featuredVenues.map((venue) {
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 12),
                      child: VenueCard(
                        venue: venue,
                        onTap: () {
                          context.push(RouteNames.venueDetail, extra: venue);
                        },
                        // featured: true,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color color;

  DashboardAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.color,
  });
}