import 'profile_model.dart';

class WorkerModel extends ProfileModel {
  final String category;
  final int experienceYears;
  final String priceRange;
  final bool isOnline;
  final bool isVerified;

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
  }) : super(id: id, role: role, name: name, phone: phone, location: location);

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    final profile = ProfileModel.fromJson(json);
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
    });
    return data;
  }
}
