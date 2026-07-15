import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    super.phoneNumber,
    required super.isVerified,
    required super.username,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>?;
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      username: profile != null ? (profile['username'] as String? ?? '') : '',
      avatarUrl: profile != null ? (profile['avatarUrl'] as String?) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
      'profile': {
        'username': username,
        'avatarUrl': avatarUrl,
      },
    };
  }
}
