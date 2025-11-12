import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thuetro/utils/utils.dart';
import 'package:thuetro/view/home/ItemPost/item_post_horizoncal.dart';
import 'package:thuetro/view/home/ItemPost/item_post_vertical.dart';
import '../model/filter.dart';
import '../provider/search_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  final _minPrice = TextEditingController();
  final _maxPrice = TextEditingController();
  final _minArea = TextEditingController();
  final _maxArea = TextEditingController();

  final List<String> items = [
    "nội thất cao cấp",
    "nội thất đầy đủ",
    "nhà trống",
  ];

  String? selectedItem;
  String? areaLabel;
  String? priceLabel;

  // ===========================================================
  // 🏠 Popup lọc TÌNH TRẠNG NỘI THẤT
  void _showFilterPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Tình trạng nội thất",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ...items.map((e) {
                    return RadioListTile<String>(
                      value: e,
                      groupValue: selectedItem,
                      title: Text(e),
                      onChanged: (value) {
                        setModalState(() => selectedItem = value);
                      },
                    );
                  }),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ref.read(filterParamsProvider.notifier).state = ref
                              .read(filterParamsProvider)
                              .copyWith(selectedFurniture: null);
                          setState(() => selectedItem = null);
                          Navigator.pop(context);
                        },
                        child: const Text("Xóa lọc"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () {
                          ref.read(filterParamsProvider.notifier).state = ref
                              .read(filterParamsProvider)
                              .copyWith(selectedFurniture: selectedItem);
                          Navigator.pop(context);
                        },

                        child: const Text(
                          "Áp dụng",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================
  // 💰 Popup lọc GIÁ
  void _showPrice() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Giá thuê",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPrice,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Tối thiểu',
                        suffixText: 'triệu',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30, child: Center(child: Text("-"))),
                  Expanded(
                    child: TextField(
                      controller: _maxPrice,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Tối đa',
                        suffixText: 'triệu',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ref.read(filterParamsProvider.notifier).state = ref
                          .read(filterParamsProvider)
                          .copyWith(minPrice: 0, maxPrice: 10000000);
                      setState(() => priceLabel = null);
                      Navigator.pop(context);
                    },
                    child: const Text("Xóa lọc"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () {
                      final min = double.tryParse(_minPrice.text) ?? 0;
                      final max = double.tryParse(_maxPrice.text) ?? 10000000;

                      ref.read(filterParamsProvider.notifier).state = ref
                          .read(filterParamsProvider)
                          .copyWith(minPrice: min, maxPrice: max);

                      setState(() {
                        priceLabel = "$min - $max triệu";
                      });

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Áp dụng",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================
  // 📏 Popup lọc DIỆN TÍCH
  void _showArea() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Diện tích",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minArea,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Tối thiểu',
                        suffixText: 'm²',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30, child: Center(child: Text("-"))),
                  Expanded(
                    child: TextField(
                      controller: _maxArea,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Tối đa',
                        suffixText: 'm²',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ref.read(filterParamsProvider.notifier).state = ref
                          .read(filterParamsProvider)
                          .copyWith(minArea: 0, maxArea: 10000000);
                      setState(() => areaLabel = null);
                      Navigator.pop(context);
                    },
                    child: const Text("Xóa lọc"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () {
                      final min = double.tryParse(_minArea.text) ?? 0;
                      final max = double.tryParse(_maxArea.text) ?? 10000000;

                      ref.read(filterParamsProvider.notifier).state = ref
                          .read(filterParamsProvider)
                          .copyWith(minArea: min, maxArea: max);

                      setState(() {
                        areaLabel = "$min - $max m²";
                      });

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Áp dụng",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================
  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(filteredPostsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 8,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              hintText: 'Tìm kiếm...',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Cập nhật search text để provider rebuild
              ref.read(searchTextProvider.notifier).state = _searchController.text;
            },
            child: const Text(
              "Tìm kiếm",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _showPrice,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(6, 12, 6, 12),
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list_outlined),
                      Text(
                        priceLabel ?? "Giá thuê",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _showArea,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(6, 12, 6, 12),
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list_outlined),
                      Text(
                        areaLabel ?? "Diện tích",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _showFilterPopup,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(6, 12, 6, 12),
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list_outlined),
                      Text(
                        selectedItem ?? "tình trạng nội thất",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: postAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return const Center(
                      child: Text("Không có bài đăng phù hợp"),
                    );
                  }
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return ItemPostHorizontal(
                        imageUrl: post["images"][0],
                        title: post["title"],
                        location: post["address"],
                        time: post["created_at"],
                        price: formatMoneyVND(post["price"]),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Lỗi: $err")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
