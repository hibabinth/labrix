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
  final String? idDocumentUrl;
  final String? certDocumentUrl;
  final String workingStart;
  final String workingEnd;

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
    this.idDocumentUrl,
    this.certDocumentUrl,
    this.workingStart = '08:00 AM',
    this.workingEnd = '05:00 PM',
    super.latitude,
    super.longitude,
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
      latitude: profile.latitude,
      longitude: profile.longitude,
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
      idDocumentUrl: json['id_document_url'] as String?,
      certDocumentUrl: json['cert_document_url'] as String?,
      workingStart: json['working_start'] ?? '08:00 AM',
      workingEnd: json['working_end'] ?? '05:00 PM',
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
      if (idDocumentUrl != null) 'id_document_url': idDocumentUrl,
      if (certDocumentUrl != null) 'cert_document_url': certDocumentUrl,
      'working_start': workingStart,
      'working_end': workingEnd,
    });
    return json;
  }

  WorkerModel copyWith({
    String? id,
    String? role,
    String? name,
    String? phone,
    String? location,
    String? category,
    String? subcategory,
    int? experienceYears,
    String? priceRange,
    bool? isOnline,
    bool? isVerified,
    List<String>? skills,
    String? education,
    List<String>? portfolioUrls,
    String? imageUrl,
    int? followers,
    int? following,
    String? aboutMe,
    List<String>? interests,
    String? coverImageUrl,
    String? headline,
    String? dob,
    double? rating,
    int? ratingCount,
    String? idDocumentUrl,
    String? certDocumentUrl,
    String? workingStart,
    String? workingEnd,
    double? latitude,
    double? longitude,
  }) {
    return WorkerModel(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      experienceYears: experienceYears ?? this.experienceYears,
      priceRange: priceRange ?? this.priceRange,
      isOnline: isOnline ?? this.isOnline,
      isVerified: isVerified ?? this.isVerified,
      skills: skills ?? this.skills,
      education: education ?? this.education,
      portfolioUrls: portfolioUrls ?? this.portfolioUrls,
      imageUrl: imageUrl ?? this.imageUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      aboutMe: aboutMe ?? this.aboutMe,
      interests: interests ?? this.interests,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      headline: headline ?? this.headline,
      dob: dob ?? this.dob,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      certDocumentUrl: certDocumentUrl ?? this.certDocumentUrl,
      workingStart: workingStart ?? this.workingStart,
      workingEnd: workingEnd ?? this.workingEnd,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
