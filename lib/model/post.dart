class PostModel {
  String? postId;
  final String userId;
  final String title;
  final double price, area, deposit;
  final String address, description, province, district, ward;
  final List<String> images;
  final String status;

  PostModel({
    this.postId,
    required this.userId,
    required this.title,
    required this.price,
    required this.address,
    required this.images,
    required this.description,
    required this.area,
    required this.deposit,
    required this.district,
    required this.province,
    required this.status,
    required this.ward,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      userId: json['user_id'] as String? ?? "null",
      title: json['title'] as String? ?? "null",
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? "null",
      images: (json['images'] as List).map((e) => e as String).toList(),
      description: json['description'] as String? ?? "null",
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      deposit: (json['deposit'] as num?)?.toDouble() ?? 0.0,
      district: json['district'] as String? ?? "null",
      province: json['province'] as String? ?? "null",
      status: json['status'] as String? ?? "null",
      ward: json['ward'] as String? ?? "null",
    );
  }

  @override
  String toString() {
    return '''
Post(
  userId: $userId,
  title: $title,
  description: $description,
  price: $price,
  area: $area,
  deposit: $deposit,
  address: $address,
  province: $province,
  district: $district,
  ward: $ward,
  images: $images,
  status: $status
)''';
  }
}
