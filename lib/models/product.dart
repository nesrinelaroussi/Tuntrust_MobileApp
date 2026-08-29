class Product {
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.category,
    required this.benefits,
    required this.targetUsers,
    required this.icon,
    required this.simplifiedFeatures,
    required this.features,
    required this.image,
    required this.url,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final description = (json['description'] ?? '').toString();
    final shortDescription = (json['shortDescription'] ?? '').toString();
    final category = (json['category'] ?? '').toString();
    final benefits = _parseStringList(json['benefits']);
    final targetUsers = _parseStringList(json['targetUsers']);
    final icon = (json['icon'] ?? '').toString();
    final simplifiedFeatures = _parseStringList(json['simplifiedFeatures']);
    final features = _parseStringList(json['features']);
    final image = (json['image'] ?? '').toString();
    final url = (json['url'] ?? '').toString();

    return Product(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: (json['name'] ?? '').toString(),
      description: description.isNotEmpty ? description : shortDescription,
      shortDescription: shortDescription.isNotEmpty ? shortDescription : description,
      category: category.isNotEmpty ? category : 'Certification',
      benefits: benefits.isNotEmpty ? benefits : <String>[],
      targetUsers: targetUsers.isNotEmpty ? targetUsers : <String>[],
      icon: icon.isNotEmpty ? icon : '✅',
      simplifiedFeatures: simplifiedFeatures.isNotEmpty ? simplifiedFeatures : <String>[],
      features: features.isNotEmpty ? features : (simplifiedFeatures.isNotEmpty ? simplifiedFeatures : <String>[]),
      image: image,
      url: url,
    );
  }

  final String id;
  final String name;
  final String description;
  final String shortDescription;
  final String category;
  final List<String> benefits;
  final List<String> targetUsers;
  final String icon;
  final List<String> simplifiedFeatures;
  final List<String> features;
  final String image;
  final String url;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'shortDescription': shortDescription,
      'category': category,
      'benefits': benefits,
      'targetUsers': targetUsers,
      'icon': icon,
      'simplifiedFeatures': simplifiedFeatures,
      'features': features,
      'image': image,
      'url': url,
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
    }
    return <String>[];
  }
}
