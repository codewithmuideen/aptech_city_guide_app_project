class Review {
  final String id;
  String attractionId;
  String userId;
  String userName;
  double rating;
  String comment;
  DateTime createdAt;
  List<String> likedBy;

  Review({
    required this.id,
    required this.attractionId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    List<String>? likedBy,
  }) : likedBy = likedBy ?? [];

  int get likeCount => likedBy.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'attractionId': attractionId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
        'likedBy': likedBy,
      };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'],
        attractionId: json['attractionId'],
        userId: json['userId'],
        userName: json['userName'],
        rating: (json['rating'] as num).toDouble(),
        comment: json['comment'],
        createdAt: DateTime.parse(json['createdAt']),
        likedBy: (json['likedBy'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
}
