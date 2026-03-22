class ProfileModel {
  final String id;
  final String role;
  final String name;
  final String phone;
  final String location;
  final String? companyName;
  final String? details;

  ProfileModel({
    required this.id,
    required this.role,
    required this.name,
    required this.phone,
    required this.location,
    this.companyName,
    this.details,
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
    };
  }
}
