import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/court_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/court/futsal_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchCity = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCourts() async {
    final courtProvider = context.read<CourtProvider>();
    await courtProvider.searchCourts();
  }

  Future<void> _searchCourts() async {
    final courtProvider = context.read<CourtProvider>();
    await courtProvider.searchCourts(
      city: _searchCity.isNotEmpty ? _searchCity : null,
      name: _searchController.text.isNotEmpty ? _searchController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Futsmandu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile
              Helpers.showSnackbar(context, 'Profile coming soon!');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingM),
            color: AppTheme.surfaceColor,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search futsal courts...',
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
                const SizedBox(height: 12),
                // City Filter
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
          ),
          // Courts List
          Expanded(
            child: Consumer<CourtProvider>(
              builder: (context, provider, _) {
                if (provider.isSearching) {
                  return const LoadingWidget(message: 'Loading courts...');
                }

                if (provider.errorMessage != null) {
                  return AppErrorWidget(
                    message: provider.errorMessage!,
                    onRetry: _loadCourts,
                  );
                }

                if (provider.courts.isEmpty) {
                  return EmptyStateWidget(
                    message: 'No futsal courts found',
                    actionText: 'Refresh',
                    onAction: _loadCourts,
                    icon: Icons.sports_soccer,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadCourts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.paddingM),
                    itemCount: provider.courts.length,
                    itemBuilder: (context, index) {
                      return FutsalCard(
                        futsalCourt: provider.courts[index],
                        onTap: () {
                          // Navigate to court detail
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
            ),
          ),
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

  Widget _buildCityChip(String label, String value) {
    final isSelected = _searchCity == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _searchCity = value;
          });
          _searchCourts();
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      ),
    );
  }
}