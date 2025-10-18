import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Address Bottom Sheet',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng tin'),
        backgroundColor: Colors.amber[700],
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Lưu nháp', style: TextStyle(color: Colors.black54)),
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _openAddressSheet(context),
          child: const Text('Mở Địa chỉ'),
        ),
      ),
    );
  }

  void _openAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // để bo góc
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: AddressBottomSheet(),
            ),
          ),
        ),
      ),
    );
  }
}

class AddressBottomSheet extends StatefulWidget {
  const AddressBottomSheet({super.key});
  @override
  State<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  String? province;
  String? district;
  String? ward;
  String? street;
  String? houseNumber;
  bool showHouseNumber = false;

  // ví dụ dữ liệu tĩnh — bạn thay bằng API gọi về sau
  final provinces = ['Chọn tỉnh, thành phố', 'Hà Nội', 'Hồ Chí Minh', 'Đà Nẵng'];
  final districts = ['Chọn quận, huyện, thị xã', 'Quận 1', 'Quận 2', 'Quận 3'];
  final wards = ['Chọn phường, xã, thị trấn', 'Phường A', 'Phường B', 'Xã C'];
  final streets = ['Tên đường', 'Nguyễn Trãi', 'Lý Thường Kiệt', 'Trần Hưng Đạo'];

  bool get canComplete {
    // điều kiện bật nút hoàn thành (ví dụ: cần chọn tỉnh + quận + phường + tên đường)
    return province != null &&
        province != provinces.first &&
        district != null &&
        district != districts.first &&
        ward != null &&
        ward != wards.first &&
        street != null &&
        street != streets.first;
  }

  @override
  void initState() {
    super.initState();
    // khởi tạo hiển thị placeholder
    province = provinces.first;
    district = districts.first;
    ward = wards.first;
    street = streets.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header: close icon + title
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Địa chỉ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            // giữ khoảng trống cân bằng với icon bên trái
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'ĐỊA CHỈ BĐS VÀ HÌNH ẢNH',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _buildDropdown(provinces, province, (v) {
                setState(() {
                  province = v;
                  // khi đổi tỉnh, có thể reset district/ward...
                  district = districts.first;
                  ward = wards.first;
                });
              }),
              const SizedBox(height: 12),
              _buildDropdown(districts, district, (v) {
                setState(() {
                  district = v;
                  ward = wards.first;
                });
              }),
              const SizedBox(height: 12),
              _buildDropdown(wards, ward, (v) => setState(() => ward = v)),
              const SizedBox(height: 12),
              _buildDropdown(streets, street, (v) => setState(() => street = v)),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Số nhà',
                  hintText: 'Số nhà',
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => houseNumber = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                      value: showHouseNumber,
                      onChanged: (v) => setState(() => showHouseNumber = v ?? false)),
                  const Expanded(child: Text('Hiển thị số nhà trong tin rao')),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canComplete
                      ? () {
                          // submit data
                          Navigator.of(context).pop({
                            'province': province,
                            'district': district,
                            'ward': ward,
                            'street': street,
                            'house': houseNumber,
                            'showHouseNumber': showHouseNumber,
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400], // mặc định xám
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ).copyWith(
                    // khi enabled dùng màu chủ đạo
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) return Colors.grey[400];
                      return Colors.amber[700];
                    }),
                  ),
                  child: const Text(
                    'HOÀN THÀNH',
                    style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDropdown(List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem<String>(
                value: e,
                child: Text(
                  e,
                  style: TextStyle(
                    color: e.startsWith('Chọn') || e == 'Tên đường' ? Colors.grey : Colors.black,
                  ),
                ),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
