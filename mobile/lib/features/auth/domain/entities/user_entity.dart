import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? phoneNumber;
  final bool isVerified;
  final String username;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    this.email,
    this.phoneNumber,
    required this.isVerified,
    required this.username,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, phoneNumber, isVerified, username, avatarUrl];
}
