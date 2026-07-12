import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/place.dart';
import '../services/location_service.dart';

class PlaceProvider with ChangeNotifier {
  late Box<Place> _placesBox;
  List<Place> _places = [];
  final LocationService _locationService = LocationService();
  Position? _currentPosition;

  List<Place> get places => _places;
  List<Place> get savedPlaces => _places.where((p) => p.isSaved).toList();
  Position? get currentPosition => _currentPosition;

  PlaceProvider() {
    _init();
  }

  Future<void> _init() async {
    _placesBox = await Hive.openBox<Place>('places');
    _loadPlaces();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<Position?> refreshCurrentLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      debugPrint('Error refreshing location: $e');
      rethrow;
    }
  }

  void _loadPlaces() {
    _places = _placesBox.values.toList();
    
    if (_places.isEmpty) {
      _initializeSampleData();
    }
    
    notifyListeners();
  }

  void _initializeSampleData() {
    final samplePlaces = [
      Place(
        id: '1',
        name: 'The Velvet Grain',
        description: 'A minimalist high-end cafe with warm oak wood furniture and soft sunlight streaming through floor-to-ceiling windows.',
        imagePath: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800',
        location: 'Shoreditch',
        category: 'coffee',
        tags: ['Hidden Gem', 'Quiet'],
        rating: 4.8,
        latitude: 51.5268,
        longitude: -0.0826,
      ),
      Place(
        id: '2',
        name: 'Petals & Flour',
        description: 'A boutique pastry shop with warm lighting illuminating artisanal flaky croissants and delicate fruit tarts.',
        imagePath: 'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800',
        location: 'Marylebone',
        category: 'coffee',
        tags: ['Cozy', 'Artisan'],
        rating: 4.6,
        latitude: 51.5176,
        longitude: -0.1606,
      ),
      Place(
        id: '3',
        name: 'Roast & Theory',
        description: 'Bright and airy coffee shop with distinct ceramic mugs of latte art and scattered coffee beans on rustic wooden table.',
        imagePath: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800',
        location: 'Peckham',
        category: 'coffee',
        tags: ['Roastery'],
        rating: 4.7,
        latitude: 51.4738,
        longitude: -0.0693,
      ),
      Place(
        id: '4',
        name: 'The Hidden Leaf',
        description: 'A minimalist architectural detail of a cafe\'s secret courtyard entrance with lush green vines crawling down a clean white brick wall.',
        imagePath: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
        location: 'Soho',
        category: 'quiet',
        tags: ['Secret Garden'],
        rating: 4.9,
        latitude: 51.5133,
        longitude: -0.1321,
      ),
    ];

    for (var place in samplePlaces) {
      _placesBox.put(place.id, place);
    }

    _places = _placesBox.values.toList();
    notifyListeners();
  }

  void toggleSavePlace(String placeId) {
    final place = _placesBox.get(placeId);
    if (place != null) {
      place.isSaved = !place.isSaved;
      place.save();
      _loadPlaces();
    }
  }

  Future<void> addPlace(Place place) async {
    await _placesBox.put(place.id, place);
    _loadPlaces();
  }

  Future<void> deletePlace(String placeId) async {
    await _placesBox.delete(placeId);
    _loadPlaces();
  }

  List<Place> getPlacesByCategory(String categoryId) {
    if (categoryId == 'all') return _places;
    return _places.where((place) => place.category == categoryId).toList();
  }

  Future<List<Place>> getNearbyPlaces(double radiusInKm) async {
    if (_currentPosition == null) return _places;
    
    List<Place> nearbyPlaces = [];
    
    for (var place in _places) {
      final distance = await _locationService.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        place.latitude,
        place.longitude,
      );
      
      if (distance <= radiusInKm * 1000) {
        nearbyPlaces.add(place);
      }
    }
    
    return nearbyPlaces;
  }
}
