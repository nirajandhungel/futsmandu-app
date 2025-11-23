import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/court_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/court/futsal_card.dart';
import '../../widgets/common/app_drawer.dart';

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
          // Courts List (now starts immediately after search section)
          Expanded(
            child: Consumer<CourtProvider>(
              builder: (context, provider, _) {
                if (provider.isSearching) {
                  return const LoadingWidget(message: 'Loading courts...');
                }

                if (provider.courts.isEmpty) {
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
                    padding: const EdgeInsets.all(AppTheme.paddingM),
                    itemCount: provider.courts.length,
                    itemBuilder: (context, index) {
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