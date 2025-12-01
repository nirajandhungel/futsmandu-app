import 'package:flutter/material.dart';
import '../../models/venue.dart';
import '../../utils/theme.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback? onTap;

  const VenueCard({
    super.key,
    required this.venue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image or Placeholder
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: venue.images != null && venue.images!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  child: Image.network(
                    venue.images!.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder();
                    },
                  ),
                )
                    : _buildPlaceholder(),
              ),
              const SizedBox(height: 12),
              // Name
              Text(
                venue.name,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Location
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${venue.address}, ${venue.city}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Rating and Courts Count
              Row(
                children: [
                  if (venue.rating != null) ...[
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      venue.rating!.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (venue.totalReviews != null) ...[
                      Text(
                        ' (${venue.totalReviews})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(width: 16),
                  ],
                  if (venue.courts != null) ...[
                    const Icon(
                      Icons.sports_soccer,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${venue.courts!.length} Courts',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
              // Amenities
              if (venue.amenities != null &&
                  venue.amenities!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: venue.amenities!.take(3).map((amenity) {
                    return Chip(
                      label: Text(
                        amenity,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.sports_soccer,
        size: 64,
        color: AppTheme.primaryColor.withOpacity(0.3),
      ),
    );
  }
}