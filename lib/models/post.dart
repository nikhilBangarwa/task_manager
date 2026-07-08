class Post {
  final int id;
  final int userId;
  final String title;
  final String body;
  bool isFavorite;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.isFavorite = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }
}
