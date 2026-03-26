import 'profile_model.dart';

class WorkerModel extends ProfileModel {
  final String category;
  final String? subcategory;
  final int experienceYears;
  final String priceRange;
  final bool isOnline;
  final bool isVerified;
  final List<String> skills;
  final String? education;
  final List<String> portfolioUrls;
  final double rating;
  final int ratingCount;

  WorkerModel({
    required super.id,
    required super.role,
    required super.name,
    required super.phone,
    required super.location,
    required this.category,
    this.subcategory,
    required this.experienceYears,
    required this.priceRange,
    required this.isOnline,
    required this.isVerified,
    this.skills = const [],
    this.education,
    this.portfolioUrls = const [],
    super.imageUrl,
    super.followers,
    super.following,
    super.aboutMe,
    super.interests,
    super.coverImageUrl,
    super.headline,
    super.dob,
    this.rating = 0.0,
    this.ratingCount = 0,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    // Handle nested 'profiles' object from Supabase joins
    final Map<String, dynamic> profileJson =
        json['profiles'] as Map<String, dynamic>? ?? json;

    // Ensure ID is available for ProfileModel parsing
    final safeProfileJson = Map<String, dynamic>.from(profileJson);
    safeProfileJson['id'] ??= json['id'];

    final profile = ProfileModel.fromJson(safeProfileJson);

    return WorkerModel(
      id: profile.id,
      role: profile.role,
      name: profile.name,
      phone: profile.phone,
      location: profile.location,
      imageUrl: profile.imageUrl,
      followers: profile.followers,
      following: profile.following,
      aboutMe: profile.aboutMe,
      interests: profile.interests,
      coverImageUrl: profile.coverImageUrl,
      headline: profile.headline,
      dob: profile.dob,
      category: json['category'] ?? '',
      subcategory: json['subcategory'] as String?,
      experienceYears: json['experience_years'] ?? 0,
      priceRange: json['price_range'] ?? '',
      isOnline: json['is_online'] ?? true,
      isVerified: json['is_verified'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      skills: List<String>.from(json['skills'] ?? []),
      education: json['education'] as String?,
      portfolioUrls: List<String>.from(json['portfolio_urls'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toProfileJson();
    json.addAll({
      'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      'experience_years': experienceYears,
      'price_range': priceRange,
      'is_online': isOnline,
      'is_verified': isVerified,
      'skills': skills,
      if (education != null) 'education': education,
      'portfolio_urls': portfolioUrls,
      'rating': rating,
      'rating_count': ratingCount,
    });
    return json;
  }
}
