import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/venue.dart';
import '../../utils/theme.dart';

class AdminVenuesScreen extends StatefulWidget {
  const AdminVenuesScreen({Key? key}) : super(key: key);

  @override
  State<AdminVenuesScreen> createState() => _AdminVenuesScreenState();
}

class _AdminVenuesScreenState extends State<AdminVenuesScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  List<Venue> _venues = [];
  List<Venue> _filteredVenues = [];
  bool _isLoading = true;
  String _error = '';
  String _filterStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadVenues();
    _searchController.addListener(_filterVenues);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterVenues() {
  setState(() {
    _filteredVenues = _venues.where((venue) {
      final searchTerm = _searchController.text.toLowerCase();
      
      // Check name (assuming name is never null or has default)
      final nameMatches = venue.name.toLowerCase().contains(searchTerm);
      
      // Check city (handle null case)
      final cityMatches = venue.city?.toLowerCase().contains(searchTerm) ?? false;
      
      final matchesSearch = nameMatches || cityMatches;
      
      final matchesStatus = _filterStatus == 'ALL' ||
          (_filterStatus == 'ACTIVE' && venue.isActive) ||
          (_filterStatus == 'SUSPENDED' && !venue.isActive);
      
      return matchesSearch && matchesStatus;
    }).toList();
  });
}

  Future<void> _loadVenues() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final venues = await _adminService.getAllVenues();
      setState(() {
        _venues = venues;
        _filteredVenues = venues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyVenue(String venueId) async {
    try {
      await _adminService.verifyVenue(venueId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Venue verified successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
      _loadVenues();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
    }
  }

  Future<void> _suspendVenue(String venueId) async {
    try {
      await _adminService.suspendVenue(venueId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Venue suspended successfully'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
      _loadVenues();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
    }
  }

  Future<void> _reactivateVenue(String venueId) async {
    try {
      await _adminService.reactivateVenue(venueId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Venue reactivated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
      _loadVenues();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
    }
  }

  Widget _buildSearchAndFilter() {
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
              const Icon(Icons.search, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppTheme.textPrimaryDark),
                  decoration: InputDecoration(
                    hintText: 'Search by name or city...',
                    hintStyle: const TextStyle(color: AppTheme.textTertiaryDark),
                    border: InputBorder.none,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: AppTheme.textTertiaryDark,
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Filter:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip('ALL'),
                      const SizedBox(width: 8),
                      _buildStatusChip('ACTIVE'),
                      const SizedBox(width: 8),
                      _buildStatusChip('SUSPENDED'),
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

  Widget _buildStatusChip(String status) {
    final isSelected = _filterStatus == status;
    return ChoiceChip(
      label: Text(
        status,
        style: TextStyle(
          color: isSelected ? AppTheme.buttonPrimaryText : AppTheme.textPrimaryDark,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: AppTheme.backgroundDark,
      side: BorderSide(color: AppTheme.dividerColorDark),
      onSelected: (selected) {
        setState(() {
          _filterStatus = status;
          _filterVenues();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardColorDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: $_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textPrimaryDark),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadVenues,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadVenues,
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.cardColorDark,
            child: _filteredVenues.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_city,
                          size: 64,
                          color: AppTheme.textTertiaryDark,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No venues found',
                          style: TextStyle(
                            color: AppTheme.textSecondaryDark,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredVenues.length,
                    itemBuilder: (context, index) {
                      final venue = _filteredVenues[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColorDark,
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          border: Border.all(
                            color: AppTheme.dividerColorDark.withOpacity(0.3),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                              color: const Color(0xFF9C27B0).withOpacity(0.1),
                              border: Border.all(
                                color: const Color(0xFF9C27B0),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.sports_soccer,
                              size: 28,
                              color: Color(0xFF9C27B0),
                            ),
                          ),
                          title: Text(
                            venue.name,
                            style: const TextStyle(
                              color: AppTheme.textPrimaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 12,
                                    color: AppTheme.textTertiaryDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${venue.city}, ${venue.address}',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondaryDark,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: venue.isActive
                                          ? const Color(0xFF2196F3).withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                      border: Border.all(
                                        color: venue.isActive
                                            ? const Color(0xFF2196F3)
                                            : Colors.red,
                                      ),
                                    ),
                                    child: Text(
                                      venue.isActive ? 'ACTIVE' : 'SUSPENDED',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: venue.isActive
                                            ? const Color(0xFF2196F3)
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                  if (venue.rating != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                        border: Border.all(color: Colors.amber),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 12,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            venue.rating!.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            color: AppTheme.cardColorDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            ),
                            icon: const Icon(
                              Icons.more_vert,
                              color: AppTheme.textSecondaryDark,
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.verified,
                                    size: 20,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  title: const Text(
                                    'Verify',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _verifyVenue(venue.id);
                                  },
                                ),
                              ),
                              if (venue.isActive)
                                PopupMenuItem(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(
                                      Icons.block,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                    title: const Text(
                                      'Suspend',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _suspendVenue(venue.id);
                                    },
                                  ),
                                )
                              else
                                PopupMenuItem(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    title: const Text(
                                      'Reactivate',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _reactivateVenue(venue.id);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}