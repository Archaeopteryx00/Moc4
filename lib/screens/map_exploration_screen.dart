import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/place.dart';
import '../providers/place_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/place_image.dart';
import 'place_detail_screen.dart';

class MapExplorationScreen extends StatefulWidget {
  const MapExplorationScreen({super.key});

  @override
  State<MapExplorationScreen> createState() => _MapExplorationScreenState();
}

class _MapExplorationScreenState extends State<MapExplorationScreen> {
  final MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();
  int _selectedPlaceIndex = 0;
  bool _hasCenteredOnStartup = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final placeProvider = Provider.of<PlaceProvider>(context, listen: true);
    final places = placeProvider.places;
    final currentPos = placeProvider.currentPosition;
    
    // Programmatically center on device location on startup if available
    if (currentPos != null && !_hasCenteredOnStartup) {
      _hasCenteredOnStartup = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(LatLng(currentPos.latitude, currentPos.longitude), 14.5);
      });
    } 
    // Otherwise fallback to first place with location if places are loaded
    else if (places.isNotEmpty && !_hasCenteredOnStartup) {
      final defaultIndex = places.indexWhere((p) => p.hasPreciseLocation);
      if (defaultIndex != -1) {
        _hasCenteredOnStartup = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _selectedPlaceIndex = defaultIndex;
          });
          final centerPlace = places[defaultIndex];
          _mapController.move(LatLng(centerPlace.latitude, centerPlace.longitude), 14.5);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          // 1. Interactive Leaflet Map Background (Minimalist CartoDB Positron Theme)
          Positioned.fill(
            child: Consumer<PlaceProvider>(
              builder: (context, placeProvider, child) {
                final places = placeProvider.places;
                final currentPos = placeProvider.currentPosition;
                
                final defaultCenter = LatLng(51.5156, -0.1278);
                final initialCenter = currentPos != null
                    ? LatLng(currentPos.latitude, currentPos.longitude)
                    : defaultCenter;

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 13.5,
                    minZoom: 3.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        // User Current Location Marker (Blue Dot with Ring)
                        if (currentPos != null)
                          Marker(
                            point: LatLng(currentPos.latitude, currentPos.longitude),
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        // Food Spot Markers
                        ...places
                            .asMap()
                            .entries
                            .where((entry) => entry.value.hasPreciseLocation) // Filter out places without precise location
                            .map((entry) {
                          final index = entry.key;
                          final place = entry.value;
                          final isSelected = index == _selectedPlaceIndex;

                        return Marker(
                          point: LatLng(place.latitude, place.longitude),
                          width: 150,
                          height: 55,
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: () {
                              if (isSelected) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlaceDetailScreen(place: place),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _selectedPlaceIndex = index;
                                });
                                _mapController.move(LatLng(place.latitude, place.longitude), 14.5);
                                _scrollController.animateTo(
                                  index * 292.0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Marker label capsule
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.primary : Colors.white,
                                    borderRadius: BorderRadius.circular(AppRadius.capsule),
                                    border: Border.all(
                                      color: isSelected ? Colors.white : AppTheme.borderSubtle,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(isSelected ? 0.15 : 0.08),
                                        blurRadius: isSelected ? 8 : 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: isSelected ? Colors.white : Colors.amber,
                                        size: 11,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          place.name,
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : AppTheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Anchor Dot
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.primary : AppTheme.secondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
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
                        );
                      }),
                    ],
                  ),
                  ],
                );
              },
            ),
          ),

          // 2. Floating Search Bar Overlay
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.capsule),
                boxShadow: [AppShadow.ambient],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search nearby spots...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.secondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.capsule),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          
          // 3. Place Cards Carousel (Floating above navigation bar)
          Positioned(
            bottom: 96,
            left: 0,
            right: 0,
            child: Consumer<PlaceProvider>(
              builder: (context, placeProvider, child) {
                final places = placeProvider.places;
                
                if (places.isEmpty) return const SizedBox.shrink();
                
                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      final isSelected = index == _selectedPlaceIndex;
                      return _buildPlaceCard(context, place, index, isSelected);
                    },
                  ),
                );
              },
            ),
          ),
          // Re-center on User Location Button
          Positioned(
            bottom: 232, // Height of card carousel (120) + bottom offset (96) + margin (16)
            right: 16,
            child: Consumer<PlaceProvider>(
              builder: (context, placeProvider, child) {
                final currentPos = placeProvider.currentPosition;
                return Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.my_location, color: AppTheme.primary),
                    onPressed: () {
                      if (currentPos != null) {
                        _mapController.move(LatLng(currentPos.latitude, currentPos.longitude), 15.0);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Device location not available.'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, Place place, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceDetailScreen(place: place),
            ),
          );
        } else {
          if (place.hasPreciseLocation) {
            setState(() {
              _selectedPlaceIndex = index;
            });
            _mapController.move(LatLng(place.latitude, place.longitude), 14.5);
            _scrollController.animateTo(
              index * 292.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            // Select index but do not pan map
            setState(() {
              _selectedPlaceIndex = index;
            });
            _scrollController.animateTo(
              index * 292.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No precise coordinates set. Map centering disabled.'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            isSelected
                ? BoxShadow(
                    color: AppTheme.primary.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                : AppShadow.ambient,
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: PlaceImage(
                imagePath: place.imagePath,
                width: 80,
                height: 104,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Info block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    place.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                        size: 12,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          place.location,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          if (!place.hasPreciseLocation) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(AppRadius.small),
                              ),
                              child: Text(
                                'NO GPS',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.orange.shade800,
                                      fontSize: 7,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            place.rating.toString(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
