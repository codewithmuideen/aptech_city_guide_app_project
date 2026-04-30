class AppUser {
  final String id;
  String name;
  String email;
  String passwordHash;
  String phone;
  String? profileImage;
  bool isAdmin;
  List<String> favoriteAttractions;
  bool notificationsEnabled;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.phone = '',
    this.profileImage,
    this.isAdmin = false,
    List<String>? favoriteAttractions,
    this.notificationsEnabled = true,
  }) : favoriteAttractions = favoriteAttractions ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'phone': phone,
        'profileImage': profileImage,
        'isAdmin': isAdmin,
        'favoriteAttractions': favoriteAttractions,
        'notificationsEnabled': notificationsEnabled,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        passwordHash: json['passwordHash'],
        phone: json['phone'] ?? '',
        profileImage: json['profileImage'],
        isAdmin: json['isAdmin'] ?? false,
        favoriteAttractions:
            (json['favoriteAttractions'] as List?)?.map((e) => e.toString()).toList() ?? [],
        notificationsEnabled: json['notificationsEnabled'] ?? true,
      );
}
