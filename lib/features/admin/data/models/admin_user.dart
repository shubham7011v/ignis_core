class AdminUser {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime lastLogin;

  const AdminUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.isAdmin,
    required this.createdAt,
    required this.lastLogin,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'] ?? 'No Name',
      photoUrl: json['photo_url'] ?? '',
      isAdmin: json['is_admin'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : DateTime.now(),
    );
  }
}
