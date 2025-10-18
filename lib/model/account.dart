class AccountUsers {
  final String id;
  String? account;
  String? password;
  String? address;
  String? fullName;
  String? avt, phone;
  AccountUsers({
    required this.id,
    this.account,
    this.password,
    this.address,
    this.fullName,
    this.avt,
    this.phone,
  });
  factory AccountUsers.fromJson(Map<String, dynamic> json) {
    return AccountUsers(
      id: json["id"] as String? ?? "",
      account: json["account"] as String? ?? "",
      password: json["password"] as String? ?? "",
      address: json["address"] as String? ?? "",
      avt: json["avt"] as String? ?? "",
      fullName: json["full_name"] as String? ?? "",
      phone: json["phone"] as String? ?? "",
    );
  }
}
