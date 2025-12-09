import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/venue_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/common/loading.dart';
import '/models/venue.dart';

class MyVenuesScreen extends StatefulWidget {
  const MyVenuesScreen({super.key});

  @override
  State<MyVenuesScreen> createState() => _MyVenuesScreenState();
}

class _MyVenuesScreenState extends State<MyVenuesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch venues when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VenueProvider>().getOwnerVenues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Venues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/add-venue');
            },
          ),
        ],
      ),
      body: Consumer<VenueProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Loading your venues...');
          }

          if (provider.venues.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.stadium_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No venues added yet'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/add-venue');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your First Venue'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.getOwnerVenues(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppTheme.paddingM),
              itemCount: provider.venues.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final venue = provider.venues[index];
                return _buildVenueCard(venue);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildVenueCard(Venue venue) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Placeholder
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: (venue.images != null && venue.images!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(venue.images!.first), // Assumes URL
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (venue.images == null || venue.images!.isEmpty)
                ? const Icon(Icons.image_not_supported, size: 40, color: Colors.grey)
                : null,
          ),
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        venue.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusChip(venue.isActive),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venue.address,
                        style: TextStyle(color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${venue.courts?.length ?? 0} Courts',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextButton(
                      onPressed: () {
                         // TODO: Navigate to venue details
                      },
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
        ),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
