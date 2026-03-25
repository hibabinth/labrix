import 'profile_model.dart';

class WorkerModel extends ProfileModel {
  final String category;
  final int experienceYears;
  final String priceRange;
  final bool isOnline;
  final bool isVerified;
  final List<String> skills;
  final String? education;
  final List<String> portfolioUrls;

  WorkerModel({
    required String id,
    required String role,
    required String name,
    required String phone,
    required String location,
    required this.category,
    required this.experienceYears,
    required this.priceRange,
    required this.isOnline,
    required this.isVerified,
    this.skills = const [],
    this.education,
    this.portfolioUrls = const [],
  }) : super(id: id, role: role, name: name, phone: phone, location: location);

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    // Handle nested 'profiles' object from Supabase joins
    final Map<String, dynamic> profileJson = json['profiles'] as Map<String, dynamic>? ?? json;
    
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
      category: json['category'] ?? '',
      experienceYears: json['experience_years'] ?? 0,
      priceRange: json['price_range'] ?? '',
      isOnline: json['is_online'] ?? true,
      isVerified: json['is_verified'] ?? false,
      skills: List<String>.from(json['skills'] ?? []),
      education: json['education'] as String?,
      portfolioUrls: List<String>.from(json['portfolio_urls'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'category': category,
      'experience_years': experienceYears,
      'price_range': priceRange,
      'is_online': isOnline,
      'is_verified': isVerified,
      'skills': skills,
      'education': education,
      'portfolio_urls': portfolioUrls,
    });
    return data;
  }
}
