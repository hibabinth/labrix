class ProfileModel {
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
    );
  }

  Map<String, dynamic> toJson() {
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
    };
  }
}
