class ProfileModel {
  static const String roleUser = 'user';
  static const String roleWorker = 'worker';
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'super_admin';

  final String id;
  final String role;
  final String name;
  final String phone;
  final String location;
  final String? companyName;
  final String? details;
  final String? imageUrl;
  final int followers;
  final int following;
  final String? aboutMe;
  final List<String> interests;
  final String? coverImageUrl;
  final String? headline;
  final String? dob;
  final String? email;
  final double? latitude;
  final double? longitude;

  ProfileModel({
    required this.id,
    required this.role,
    required this.name,
    required this.phone,
    required this.location,
    this.companyName,
    this.details,
    this.imageUrl,
    this.followers = 0,
    this.following = 0,
    this.aboutMe,
    this.interests = const [],
    this.coverImageUrl,
    this.headline,
    this.dob,
    this.email,
    this.latitude,
    this.longitude,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      role: json['role'] ?? 'user',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      companyName: json['company_name'],
      details: json['details'],
      imageUrl: json['image_url'],
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      aboutMe: json['about_me'],
      interests: List<String>.from(json['interests'] ?? []),
      coverImageUrl: json['cover_image_url'],
      headline: json['headline'],
      dob: json['dob'],
      email: json['email'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toProfileJson() {
    return {
      'id': id,
      'role': role,
      'name': name,
      'phone': phone,
      'location': location,
      if (companyName != null) 'company_name': companyName,
      if (details != null) 'details': details,
      if (imageUrl != null) 'image_url': imageUrl,
      'followers': followers,
      'following': following,
      if (aboutMe != null) 'about_me': aboutMe,
      'interests': interests,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (headline != null) 'headline': headline,
      if (dob != null) 'dob': dob,
      if (email != null) 'email': email,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  Map<String, dynamic> toJson() => toProfileJson();

  bool get isAdmin => role == roleAdmin || role == roleSuperAdmin;
  bool get isSuperAdmin => role == roleSuperAdmin;
  bool get isWorker => role == roleWorker;
}
