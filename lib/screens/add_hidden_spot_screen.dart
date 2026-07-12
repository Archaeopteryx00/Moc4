import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/place.dart';
import '../providers/place_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/place_image.dart';

class AddHiddenSpotScreen extends StatefulWidget {
  const AddHiddenSpotScreen({super.key});

  @override
  State<AddHiddenSpotScreen> createState() => _AddHiddenSpotScreenState();
}

class _AddHiddenSpotScreenState extends State<AddHiddenSpotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCategory = 'coffee';
  String? _imagePath;
  double? _selectedLatitude;
  double? _selectedLongitude;
  bool _isFetchingLocation = false;
  bool _isSubmitting = false;

  final ImagePicker _imagePicker = ImagePicker();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Listen to changes in PlaceProvider to center the map on the current location once resolved
    final provider = context.read<PlaceProvider>();
    if (provider.currentPosition == null) {
      provider.addListener(_onProviderUpdate);
    }
  }

  void _onProviderUpdate() {
    final provider = context.read<PlaceProvider>();
    if (provider.currentPosition != null && mounted) {
      _mapController.move(
        LatLng(provider.currentPosition!.latitude, provider.currentPosition!.longitude),
        14.5,
      );
      // Remove listener after setting
      provider.removeListener(_onProviderUpdate);
    }
  }

  @override
  void dispose() {
    try {
      context.read<PlaceProvider>().removeListener(_onProviderUpdate);
    } catch (_) {}
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
      );
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _captureCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });
    try {
      final position = await context.read<PlaceProvider>().refreshCurrentLocation();
      if (position != null) {
        setState(() {
          _selectedLatitude = position.latitude;
          _selectedLongitude = position.longitude;
          _isFetchingLocation = false;
        });
        _mapController.move(LatLng(position.latitude, position.longitude), 14.5);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location captured successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception('Location sensor returned null');
      }
    } catch (e) {
      setState(() {
        _isFetchingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch location: $e. You can manually tap coordinates on the map.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _submitPlace() async {
    if (_isSubmitting) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        // Use explicitly picked coordinates, otherwise save 0.0 to indicate "Not set"
        final double lat = _selectedLatitude ?? 0.0;
        final double lng = _selectedLongitude ?? 0.0;

        final place = Place(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          description: _descriptionController.text,
          imagePath: _imagePath ?? 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800',
          location: _locationController.text,
          category: _selectedCategory,
          tags: [_selectedCategory],
          latitude: lat,
          longitude: lng,
        );

        await context.read<PlaceProvider>().addPlace(place);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved "${place.name}" at coordinates: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context);
          } else {
            // Clear fields if it's inside tab
            _nameController.clear();
            _descriptionController.clear();
            _locationController.clear();
            setState(() {
              _imagePath = null;
              _selectedLatitude = null;
              _selectedLongitude = null;
              _isSubmitting = false;
            });
          }
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save place: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Add Hidden Spot'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Upload
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: _imagePath != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.large - 1.5),
                            child: PlaceImage(
                              imagePath: _imagePath!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _imagePath = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _buildUploadPlaceholder(),
              ),
            ),
            const SizedBox(height: 24),
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Place Name',
                hintText: 'e.g., The Velvet Grain',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a place name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe this hidden spot...',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Category
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: const [
                DropdownMenuItem(value: 'coffee', child: Text('Coffee')),
                DropdownMenuItem(value: 'quiet', child: Text('Quiet')),
                DropdownMenuItem(value: 'late_night', child: Text('Late Night')),
                DropdownMenuItem(value: 'artisan', child: Text('Artisan')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location Address',
                hintText: 'e.g., Shoreditch, London',
                prefixIcon: Icon(Icons.location_on, size: 20),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Map Location Picker Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.map_outlined, size: 18, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Set Map Coordinate',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap map or capture GPS location.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                  ],
                ),
                _isFetchingLocation
                    ? const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                        ),
                      )
                    : TextButton.icon(
                        onPressed: _captureCurrentLocation,
                        icon: const Icon(Icons.my_location, size: 14),
                        label: const Text('Capture', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          foregroundColor: AppTheme.primary,
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 10),
            // Inline Map Picker Widget
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.large),
                border: Border.all(color: AppTheme.borderSubtle, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Consumer<PlaceProvider>(
                builder: (context, placeProvider, child) {
                  final currentPos = placeProvider.currentPosition;
                  final double initialLat = _selectedLatitude ?? currentPos?.latitude ?? 51.5156;
                  final double initialLng = _selectedLongitude ?? currentPos?.longitude ?? -0.1278;

                  return FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(initialLat, initialLng),
                      initialZoom: 14.5,
                      onTap: (tapPosition, latLng) {
                        setState(() {
                          _selectedLatitude = latLng.latitude;
                          _selectedLongitude = latLng.longitude;
                        });
                        _mapController.move(latLng, 14.5);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          if (_selectedLatitude != null && _selectedLongitude != null)
                            Marker(
                              point: LatLng(
                                _selectedLatitude!,
                                _selectedLongitude!,
                              ),
                              width: 36,
                              height: 36,
                              alignment: Alignment.bottomCenter,
                              child: const Icon(
                                Icons.location_pin,
                                color: AppTheme.primary,
                                size: 36,
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedLatitude != null && _selectedLongitude != null
                        ? 'Captured: ${_selectedLatitude!.toStringAsFixed(5)}, ${_selectedLongitude!.toStringAsFixed(5)}'
                        : 'No precise coordinates captured',
                    style: TextStyle(
                      color: _selectedLatitude != null && _selectedLongitude != null ? AppTheme.primary : AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: _selectedLatitude != null && _selectedLongitude != null ? FontWeight.bold : FontWeight.normal,
                      fontFamily: _selectedLatitude != null && _selectedLongitude != null ? 'monospace' : null,
                    ),
                  ),
                  if (_selectedLatitude == null || _selectedLongitude == null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'You can save this spot without coordinates.',
                      style: TextStyle(
                        color: AppTheme.textMuted.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPlace,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: _isSubmitting ? AppTheme.textMuted.withOpacity(0.3) : AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.capsule),
                ),
                elevation: 1,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Add Hidden Spot',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 80), // Extra bottom padding for floating bar
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            size: 32,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to upload spot photo',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Supports JPG, PNG up to 10MB',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
      ],
    );
  }
}
