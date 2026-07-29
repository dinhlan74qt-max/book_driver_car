class UserEntity {
  final int id;
  final String fullname;
  final String email;
  final String phone;
  final String? cccd;
  final String? address;
  final String? avatar;
  final String role;

  UserEntity({
    required this.id,
    required this.fullname,
    required this.email,
    required this.phone,
    this.cccd,
    this.address,
    this.avatar,
    required this.role,
  });
}
