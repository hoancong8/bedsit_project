class Address {
  final String province;
  final String ward;
  final String district;
  final String street;
  final String numberHouse;
  final String fullPath;
  Address({required this.province, required this.district, required this.ward, required this.street, required this.numberHouse , required this.fullPath});
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      province: json["province"] as String,
      district: json["district"] as String,
      ward: json["ward"] as String,
      street: json["street"],
      numberHouse: json["numberHouse"],
      fullPath: json["address"],
    );
  }
  @override
  String toString() {
    // TODO: implement toString
    return " $fullPath ";
  }
}
