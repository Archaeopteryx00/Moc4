import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../providers/place_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/place_image.dart';
import '../widgets/search_field.dart';
import '../widgets/hero_card.dart';
import '../widgets/category_row.dart';
import 'add_hidden_spot_screen.dart';
import 'place_detail_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  String _getCategoryLabel(String id) {
    if (id == 'quiet') return 'Quiet Study';
    if (id == 'coffee') return 'Coffee Run';
    if (id == 'artisan') return 'Hidden Gems';
    if (id == 'late_night') return 'Late Night';
    return id;
  }

  Widget _buildWelcomeHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find your next hidden café',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Discover cafés, local food, and cozy corners.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                  height: 1.3,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        bottom: false,
        child: Consumer<PlaceProvider>(
          builder: (context, placeProvider, child) {
            final allPlaces = placeProvider.places;

            // Resolve selected category places
            final categoryPlaces = placeProvider.getPlacesByCategory(_selectedCategory);

            // 1. Featured Pick: Highest rated place matching selected category
            Place? featuredPick;
            if (categoryPlaces.isNotEmpty) {
              featuredPick = categoryPlaces.reduce(
                (curr, next) => curr.rating > next.rating ? curr : next,
              );
            }

            // 2. Curated Study Corners: Places matching 'quiet' and selected category filters
            final quietStudyPlaces = categoryPlaces.where((p) => p.category == 'quiet').toList();

            // 3. Curated Fresh Gems: Places matching 'artisan' or 'coffee' and selected category filters
            final artisanGems = categoryPlaces.where((p) => p.category == 'artisan' || p.category == 'coffee').toList();

            // 4. Explore More / Results spots list
            var explorePlaces = categoryPlaces;
            if (_searchQuery.isNotEmpty) {
              explorePlaces = explorePlaces.where((place) {
                final query = _searchQuery.toLowerCase();
                return place.name.toLowerCase().contains(query) ||
                    place.location.toLowerCase().contains(query) ||
                    place.category.toLowerCase().contains(query) ||
                    place.description.toLowerCase().contains(query);
              }).toList();
            }

            final bool isSearching = _searchQuery.isNotEmpty;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Subtitle Discovery Header
                  _buildWelcomeHeader(),

                  // Premium Search Entry Point
                  SearchField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    hintText: 'Search by vibe, area, or café name...',
                  ),

                  // Category Vibe shortcuts
                  CategoryRow(
                    selectedCategoryId: _selectedCategory,
                    onSelected: (categoryId) {
                      setState(() {
                        _selectedCategory = categoryId;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  if (isSearching) ...[
                    // Search results mode active
                    _buildSearchResultsSection(explorePlaces),
                  ] else ...[
                    // Standard Discovery flow
                    if (featuredPick != null) ...[
                      HeroCard(place: featuredPick),
                      const SizedBox(height: 16),
                    ],

                    // Curated Horizontal Section 1: Study Vibe
                    _buildCuratedSection('📚 Quiet Study Corners', quietStudyPlaces),

                    // Curated Horizontal Section 2: Coffee & Gems Vibe
                    _buildCuratedSection('✨ Fresh Hidden Gems', artisanGems),

                    // Explore More Grid Section
                    _buildExploreMoreSection(explorePlaces),
                  ],

                  const SizedBox(height: 120), // Bottom navigation padding spacer
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchResultsSection(List<Place> places) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Search Results for "$_searchQuery"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
          ),
        ),
        _buildGridFeed(places),
      ],
    );
  }

  Widget _buildExploreMoreSection(List<Place> places) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'More Places to Explore',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
          ),
        ),
        _buildGridFeed(places),
      ],
    );
  }

  Widget _buildCuratedSection(String title, List<Place> places) {
    if (places.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.3,
                ),
          ),
        ),
        SizedBox(
          height: 185,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return _buildCuratedCard(place);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCuratedCard(Place place) {
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
        width: 140,
        margin: const EdgeInsets.only(right: 12, bottom: 6, top: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [AppShadow.ambient],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PlaceImage(
                    imagePath: place.imagePath,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Consumer<PlaceProvider>(
                      builder: (context, placeProvider, child) {
                        final isSaved = place.isSaved;
                        return Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: IconButton(
                              icon: Icon(
                                isSaved ? Icons.bookmark : Icons.bookmark_border,
                                color: AppTheme.primary,
                                size: 12,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                placeProvider.toggleSavePlace(place.id);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          place.location,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.textMuted,
                                fontSize: 9,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 10),
                          const SizedBox(width: 1),
                          Text(
                            place.rating.toString(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontSize: 9,
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

  Widget _buildGridFeed(List<Place> places) {
    if (places.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppTheme.secondary.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No Spots Found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No hidden spots match "$_searchQuery". Try clearing search or change filters.'
                    : 'No spots available in this category yet.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMuted,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return _buildPlaceCard(place, index);
      },
    );
  }

  Widget _buildPlaceCard(Place place, int index) {
    final height = index % 2 == 0 ? 220.0 : 190.0;
    final imageHeight = height * 0.65;
    
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [AppShadow.ambient],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: PlaceImage(
                    imagePath: place.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<PlaceProvider>(
                    builder: (context, placeProvider, child) {
                      final isSaved = place.isSaved;
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.85),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: AppTheme.primary,
                            size: 16,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            placeProvider.toggleSavePlace(place.id);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 11,
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
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            _getCategoryLabel(place.category).toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.primary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                          ),
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
            ),
          ],
        ),
      ),
    );
  }
}
