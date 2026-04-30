enum AttractionCategory { attraction, restaurant, hotel, event }

extension AttractionCategoryX on AttractionCategory {
  String get label {
    switch (this) {
      case AttractionCategory.attraction:
        return 'Attraction';
      case AttractionCategory.restaurant:
        return 'Restaurant';
      case AttractionCategory.hotel:
        return 'Hotel';
      case AttractionCategory.event:
        return 'Event';
    }
  }

  static AttractionCategory fromLabel(String label) {
    return AttractionCategory.values.firstWhere(
      (e) => e.label.toLowerCase() == label.toLowerCase(),
      orElse: () => AttractionCategory.attraction,
    );
  }
}

class Attraction {
  final String id;
  String cityId;
  String name;
  AttractionCategory category;
  String description;
  String imageUrl;
  List<String> gallery;
  String address;
  String phone;
  String website;
  String openingHours;
  double latitude;
  double longitude;

  Attraction({
    required this.id,
    required this.cityId,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    List<String>? gallery,
    this.address = '',
    this.phone = '',
    this.website = '',
    this.openingHours = '',
    required this.latitude,
    required this.longitude,
  }) : gallery = gallery ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'cityId': cityId,
        'name': name,
        'category': category.label,
        'description': description,
        'imageUrl': imageUrl,
        'gallery': gallery,
        'address': address,
        'phone': phone,
        'website': website,
        'openingHours': openingHours,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Attraction.fromJson(Map<String, dynamic> json) => Attraction(
        id: json['id'],
        cityId: json['cityId'],
        name: json['name'],
        category: AttractionCategoryX.fromLabel(json['category']),
        description: json['description'],
        imageUrl: json['imageUrl'],
        gallery: (json['gallery'] as List?)?.map((e) => e.toString()).toList() ?? [],
        address: json['address'] ?? '',
        phone: json['phone'] ?? '',
        website: json['website'] ?? '',
        openingHours: json['openingHours'] ?? '',
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}
