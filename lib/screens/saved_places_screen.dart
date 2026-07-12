import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../providers/place_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/place_image.dart';
import 'place_detail_screen.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          'Saved Spots',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
        ),
      ),
      body: Consumer<PlaceProvider>(
        builder: (context, placeProvider, child) {
          final savedPlaces = placeProvider.savedPlaces;
          
          if (savedPlaces.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_outline_rounded,
                        size: 48,
                        color: AppTheme.secondary.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your saved collection is empty',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tapping the bookmark icon on any hidden gem will save it here for quick reference offline.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textMuted,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), // Padded for floating bar
            itemCount: savedPlaces.length,
            itemBuilder: (context, index) {
              final place = savedPlaces[index];
              return _buildPlaceCard(context, place);
            },
          );
        },
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, Place place) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailScreen(place: place),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [AppShadow.ambient],
        ),
        child: Row(
          children: [
            // Image Square
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: PlaceImage(
                imagePath: place.imagePath,
                width: 84,
                height: 84,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Info block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 13,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          place.location,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppTheme.textMuted,
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
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: Text(
                          place.category.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.primary,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star,
                        size: 13,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        place.rating.toString(),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Remove button
            IconButton(
              icon: const Icon(Icons.bookmark),
              color: AppTheme.primary,
              iconSize: 22,
              onPressed: () {
                context.read<PlaceProvider>().toggleSavePlace(place.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
