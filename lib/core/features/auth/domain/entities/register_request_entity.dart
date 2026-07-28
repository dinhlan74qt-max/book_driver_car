class RegisterRequestEntity {
  final String fullname;
  final String email;
  final String password;
  final String phone;
  final String cccd;
  final String address;

  RegisterRequestEntity({
    required this.fullname,
    required this.email,
    required this.password,
    required this.phone,
    required this.cccd,
    required this.address,
  });
}