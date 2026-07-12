class Category {
  final String id;
  final String name;
  final String icon;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class CategoryConstants {
  static const List<Category> categories = [
    Category(id: 'all', name: 'All Spots', icon: 'all_inclusive'),
    Category(id: 'quiet', name: 'Quiet', icon: 'volume_off'),
    Category(id: 'coffee', name: 'Coffee', icon: 'coffee'),
    Category(id: 'late_night', name: 'Late Night', icon: 'nights_stay'),
    Category(id: 'artisan', name: 'Artisan', icon: 'auto_awesome'),
  ];
}
