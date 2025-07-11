class Contact {
  final String id;
  final String name;
  final String avatarUrl;
  final DateTime createdAt;

  Contact({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.createdAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}