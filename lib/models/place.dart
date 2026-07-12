import 'package:hive/hive.dart';

part 'place.g.dart';

@HiveType(typeId: 0)
class Place extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String imagePath;

  @HiveField(4)
  String location;

  @HiveField(5)
  String category;

  @HiveField(6)
  List<String> tags;

  @HiveField(7)
  double rating;

  @HiveField(8)
  bool isSaved;

  @HiveField(9)
  double latitude;

  @HiveField(10)
  double longitude;

  @HiveField(11)
  DateTime createdAt;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.location,
    required this.category,
    this.tags = const [],
    this.rating = 4.5,
    this.isSaved = false,
    required this.latitude,
    required this.longitude,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get hasPreciseLocation => latitude != 0.0 || longitude != 0.0;

  Place copyWith({
    String? id,
    String? name,
    String? description,
    String? imagePath,
    String? location,
    String? category,
    List<String>? tags,
    double? rating,
    bool? isSaved,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      location: location ?? this.location,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      isSaved: isSaved ?? this.isSaved,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
