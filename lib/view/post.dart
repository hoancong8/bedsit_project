import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thuetro/model/post.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thuetro/model/address.dart';
import 'package:thuetro/provider/post_provider.dart';

import '../provider/auth_provider.dart';

class Post extends ConsumerStatefulWidget {
  const Post({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostState();
}

class _PostState extends ConsumerState<Post> {
  List<File> _images = [];

  String? selectStatus;
  Address? address;
  final areaController = TextEditingController();
  final depositCotroller = TextEditingController();
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  String? errorTitle,
      errorAddress,
      errorDeposit,
      errorPrice,
      errorDescription,
      errorArea;

  // Post _post = Post()
  List<String> listsStatus = [
    "Nội thất cao cấp",
    "Nội thất đầy đủ",
    "Nhà trống",
  ];
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    areaController.dispose();
    depositCotroller.dispose();
    titleController.dispose();
    priceController.dispose();
    depositCotroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Đăng tin"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Lưu nháp",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ref.watch(loggedInProvider.notifier).state
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ĐỊA CHỈ VÀ HÌNH ẢNH",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Address selector
                    InkWell(
                      onTap: () async {
                        final fullAddress = await showModalBottomSheet<Address>(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) {
                            return const AddressBottomSheet();
                          },
                        );
                        if (fullAddress != null) {
                          setState(() {
                            address = fullAddress;
                            errorAddress = null;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: errorAddress != null
                                ? Colors.red
                                : Colors.grey,
                            width: 1,
                          ),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                errorAddress != null
                                    ? errorAddress!
                                    : (address == null
                                          ? "Chọn địa chỉ"
                                          : address.toString()),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: address == null
                                      ? Colors.grey.shade700
                                      : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Images area
                    const Text(
                      "Hình ảnh",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _images.isEmpty
                        ? GestureDetector(
                            onTap: () async {
                              final imgs = await pickImages();
                              setState(() {
                                _images = imgs;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                color: Colors.grey.shade50,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 32,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 6),
                                  Text("Chọn ảnh (tối thiểu 1)"),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 1,
                                    ),
                                itemCount: _images.length,
                                itemBuilder: (context, idx) {
                                  final file = _images[idx];
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          file,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _images.removeAt(idx);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final imgs = await pickImages();
                                      setState(() {
                                        _images.addAll(imgs);
                                      });
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text("Thêm ảnh"),
                                  ),
                                  const SizedBox(width: 12),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _images = [];
                                      });
                                    },
                                    child: const Text(
                                      'Xoá tất cả',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                    const SizedBox(height: 16),
                    const Text(
                      "THÔNG TIN KHÁC",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Status dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        color: Colors.white,
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectStatus,
                        items: listsStatus
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => selectStatus = val),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Tình trạng nội thất",
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      "DIỆN TÍCH & GIÁ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    textfieldPost(
                      "Diện tích",
                      TextInputType.number,
                      areaController,
                      errorArea,
                      (value) {
                        setState(() {
                          errorArea = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    textfieldPost(
                      "Giá thuê",
                      TextInputType.number,
                      priceController,
                      errorPrice,
                      (value) {
                        setState(() {
                          errorPrice = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    textfieldPost(
                      "Tiền cọc",
                      TextInputType.number,
                      depositCotroller,
                      errorDeposit,
                      (value) {
                        setState(() {
                          errorDeposit = null;
                        });
                      },
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      "TIÊU ĐỀ TIN ĐĂNG VÀ MÔ TẢ CHI TIẾT",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    textfieldPost(
                      "Tiêu đề tin đăng",
                      TextInputType.text,
                      titleController,
                      errorTitle,
                      (value) {
                        setState(() {
                          errorTitle = null;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      minLines: 8,
                      maxLines: 12,
                      decoration: InputDecoration(
                        hintText: "Mô tả chi tiết về phòng/trọ...",
                        errorText: errorDescription,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          errorDescription = null;
                        });
                      },
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "XEM TRƯỚC TIN",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              bool checkPost = true;
                              List<String> list = await ref.read(
                                uploadImagesProvider(_images).future,
                              );
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final uid = await prefs.getString("uuid");

                              if (titleController.text.isEmpty) {
                                setState(() {
                                  errorTitle = "không được để trống";
                                  checkPost = false;
                                });
                              }
                              if (double.tryParse(priceController.text) ==
                                  null) {
                                setState(() {
                                  errorPrice = "không được để trống";
                                  checkPost = false;
                                });
                              }
                              if (address == null) {
                                setState(() {
                                  errorAddress = "không được để trống";
                                  checkPost = false;
                                });
                              }
                              if (list.isEmpty) {
                                checkPost = false;
                              }
                              if (descriptionController.text.isEmpty) {
                                setState(() {
                                  checkPost = false;
                                  errorDescription = "không được để trống";
                                });
                              }
                              if (double.tryParse(areaController.text) ==
                                  null) {
                                setState(() {
                                  errorArea =
                                      "không được để trống hoặc ghi chữ";
                                  checkPost = false;
                                });
                              }
                              if (double.tryParse(depositCotroller.text) ==
                                  null) {
                                setState(() {
                                  errorDeposit = "không được để trống";
                                  checkPost = false;
                                });
                              }
                              final PostModel post = PostModel(
                                userId: uid ?? "null",
                                title: titleController.text,
                                price:
                                    double.tryParse(priceController.text) ?? 0,
                                address: address.toString() ?? "",
                                images: list,
                                description: descriptionController.text,
                                area: double.tryParse(areaController.text) ?? 0,
                                deposit:
                                    double.tryParse(depositCotroller.text) ?? 0,
                                district: address?.district ?? "null",
                                province: address?.province ?? "null",
                                status: selectStatus ?? "null",
                                ward: address?.ward ?? "null",
                              );
                              if (checkPost) {
                                await ref.read(uploadPost(post).future);
                              }

                              print("đang chạy đến 279 ...");
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "ĐĂNG TIN",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            )
          : Center(
              child: ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go("/");
                },
                child: const Text("Đăng nhập"),
              ),
            ),
    );
  }
}

Widget textfieldPost(
  String label,
  TextInputType a,
  TextEditingController textController,
  String? error,
  void Function(String)? onChanged,
) {
  return TextField(
    controller: textController,
    keyboardType: a,
    decoration: InputDecoration(
      labelText: label,
      errorText: error,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    ),
    onChanged: onChanged,
  );
}

class AddressBottomSheet extends ConsumerStatefulWidget {
  const AddressBottomSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddressBottomSheetState();
}

class _AddressBottomSheetState extends ConsumerState<AddressBottomSheet> {
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;
  String? selectedProvinceName;
  String? selectedDistrictName;
  String? selectedWardName;
  String? selectStreet;
  String? fullPath;

  @override
  Widget build(BuildContext context) {
    final streetController = TextEditingController();
    final houseController = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, //tránh bàn phím che
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text("Địa chỉ", style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Provinces
                  adressDropdown(ref.watch(provinces), (val, name, path) {
                    setState(() {
                      selectedProvinceName = name;
                      selectedProvince = val;
                    });
                  }),
                  const SizedBox(height: 12),
                  adressDropdown(
                    ref.watch(districts(selectedProvince ?? "1")),
                    (val, name, path) {
                      setState(() {
                        selectedDistrictName = name;
                        selectedDistrict = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  adressDropdown(ref.watch(wards(selectedDistrict ?? "1")), (
                    val,
                    name,
                    path,
                  ) {
                    setState(() {
                      selectedWardName = name;
                      selectedWard = val;
                      fullPath = path;
                    });
                  }),
                  const SizedBox(height: 12),
                  TextField(
                    controller: streetController,
                    decoration: InputDecoration(
                      labelText: "số đường",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 20,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: houseController,
                    decoration: InputDecoration(
                      labelText: "số nhà",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 20,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      final Address fullAddress = Address(
                        province: selectedProvinceName ?? "null",
                        district: selectedDistrictName ?? "null",
                        ward: selectedWardName ?? "null",
                        street: streetController.text,
                        numberHouse: houseController.text,
                        fullPath: fullPath ?? "null",
                      );
                      Navigator.pop(context, fullAddress);
                    },
                    child: Text("Hoàn thành"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget adressDropdown(
  AsyncValue<List<Map<String, dynamic>>> adressAsync,
  void Function(String?, String?, String?) onSelected,
) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.blue, width: 2),
      borderRadius: BorderRadius.circular(12), // bo góc
    ),
    child: adressAsync.when(
      data: (list) => DropdownButtonFormField<String>(
        items: list
            .map(
              (d) => DropdownMenuItem(
                value: d["code"].toString(),
                child: Text(d["name"]),
              ),
            )
            .toList(),
        onChanged: (val) {
          final name = list.firstWhere((d) => d["code"].toString() == val);
          final path = list.firstWhere((d) => d["code"].toString() == val);
          onSelected(
            val,
            name["name"].toString(),
            path["path_with_type"].toString(),
          );
        },
        decoration: const InputDecoration(
          labelText: "Chọn Quận/Huyện",
          border: InputBorder.none,
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text("Lỗi: $e"),
    ),
  );
}
