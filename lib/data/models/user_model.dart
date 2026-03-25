import 'profile_model.dart';

class UserModel extends ProfileModel {
  UserModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.location,
  }) : super(role: 'user');

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = ProfileModel.fromJson(json);
    return UserModel(
      id: profile.id,
      name: profile.name,
      phone: profile.phone,
      location: profile.location,
    );
  }

}
