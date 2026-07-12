import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/place.dart';
import '../providers/place_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/place_image.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  String _getCategoryLabel(String id) {
    if (id == 'quiet') return 'Quiet Study';
    if (id == 'coffee') return 'Coffee Run';
    if (id == 'artisan') return 'Hidden Gems';
    if (id == 'late_night') return 'Late Night';
    return id;
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 20),
        onPressed: onPressed,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildSummaryPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    bool isMonospace = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreviewCard(BuildContext context) {
    if (place.hasPreciseLocation) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppTheme.borderSubtle, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(place.latitude, place.longitude),
            initialZoom: 15.0,
            minZoom: 12.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(place.latitude, place.longitude),
                  width: 150,
                  height: 55,
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(AppRadius.capsule),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 11),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                place.name,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppTheme.borderSubtle, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 32,
              color: AppTheme.textMuted.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'Map preview unavailable',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Precise GPS coordinates were not captured for this spot.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // Hero Image with Gradient Overlay and Floating Circle Buttons
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            leading: _buildCircleButton(
              icon: Icons.arrow_back,
              iconColor: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PlaceImage(
                    imagePath: place.imagePath,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.black.withOpacity(0.25),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Consumer<PlaceProvider>(
                builder: (context, placeProvider, child) {
                  final isSaved = place.isSaved;
                  return _buildCircleButton(
                    icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                    iconColor: isSaved ? Colors.amber : Colors.white,
                    onPressed: () {
                      placeProvider.toggleSavePlace(place.id);
                    },
                  );
                },
              ),
              _buildCircleButton(
                icon: Icons.delete_outline,
                iconColor: Colors.white,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Spot?'),
                      content: Text('Are you sure you want to delete "${place.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<PlaceProvider>().deletePlace(place.id);
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Name
                  Text(
                    place.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.onSurface,
                          letterSpacing: -0.6,
                        ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Location Address Subtitle
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppTheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.location,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Metadata Pills Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildSummaryPill(
                          context,
                          icon: Icons.local_offer_outlined,
                          label: _getCategoryLabel(place.category),
                          color: AppTheme.primary,
                          backgroundColor: AppTheme.primary.withOpacity(0.08),
                        ),
                        const SizedBox(width: 8),
                        _buildSummaryPill(
                          context,
                          icon: Icons.star,
                          label: place.rating.toString(),
                          color: Colors.amber[800]!,
                          backgroundColor: Colors.amber.withOpacity(0.1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // About Section
                  Text(
                    'About This Spot',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurface.withOpacity(0.8),
                          height: 1.6,
                          fontSize: 14.5,
                        ),
                  ),
                  const SizedBox(height: 28),

                  // Location Map Preview Section
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                  ),
                  if (place.hasPreciseLocation) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.gps_fixed, size: 12, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'GPS Coordinates: ${place.latitude.toStringAsFixed(6)}, ${place.longitude.toStringAsFixed(6)}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.textMuted,
                                fontFamily: 'monospace',
                              ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildMapPreviewCard(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppTheme.borderSubtle.withOpacity(0.5),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        child: Row(
          children: [
            // Bookmark Secondary Toggle Action
            Consumer<PlaceProvider>(
              builder: (context, placeProvider, child) {
                final isSaved = place.isSaved;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSaved ? AppTheme.primary : AppTheme.borderSubtle,
                      width: 1.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: AppTheme.primary,
                      size: 22,
                    ),
                    onPressed: () {
                      placeProvider.toggleSavePlace(place.id);
                    },
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(12),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            // Primary Directions Action
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final bool hasCoordinates = place.hasPreciseLocation;
                  if (hasCoordinates) {
                    final Uri googleMapsUrl = Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}',
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening Google Maps to ${place.name}...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    try {
                      if (await canLaunchUrl(googleMapsUrl)) {
                        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                      } else {
                        await launchUrl(googleMapsUrl);
                      }
                    } catch (e) {
                      debugPrint('Error launching maps: $e');
                      await launchUrl(googleMapsUrl);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Directions unavailable: Precise location not set for this spot.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: place.hasPreciseLocation
                      ? AppTheme.primary
                      : AppTheme.textMuted.withOpacity(0.15),
                  foregroundColor: place.hasPreciseLocation
                      ? Colors.white
                      : AppTheme.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.capsule),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.directions_outlined, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Get Directions',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
