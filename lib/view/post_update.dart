import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thuetro/model/post.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thuetro/model/address.dart';
import 'package:thuetro/provider/post_provider.dart';

import '../provider/auth_provider.dart';

class PostUpdate extends ConsumerStatefulWidget {
  final Map<String, dynamic> post;
  // String? address,
  //     title,
  //     description,
  //     deposit,
  //     price,
  //     area,
  //     status,
  //     province,
  //     district,
  //     ward,
  //     street;
  // List<String>? listImg;
  PostUpdate({super.key,required this.post});

  @override
  ConsumerState<PostUpdate> createState() => _PostUpdateState();
}

class _PostUpdateState extends ConsumerState<PostUpdate> {
  List<File> _images = [];
  List<String> img =[];
  String? postId;
  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true, // chọn nhiều ảnh
    );
    if (result != null) {
      setState(() {
        _images = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

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
    "nội thất cao cấp",
    "nội thất đầy đủ",
    "nhà trống",
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initPostData();
  }
  void _initPostData() {
    final post = widget.post;
    postId = post["id"].toString();
    // Gán text field
    titleController.text = post["title"] ?? "";
    descriptionController.text = post["description"] ?? "";
    priceController.text = post["price"]?.toString() ?? "";
    depositCotroller.text = post["deposit"]?.toString() ?? "";
    areaController.text = post["area"]?.toString() ?? "";

    // Gán tình trạng
    selectStatus = post["status"];

    // Gán địa chỉ (nếu có)
    address = Address(
      province: post["province"] ?? "",
      district: post["district"] ?? "",
      ward: post["ward"] ?? "",
      street: post["street"] ?? "",
      numberHouse: post["number_house"] ?? "",
      fullPath: post["address"] ?? "",
    );
    img=List<String>.from(post["images"] ?? []);
    // Gán hình ảnh (dạng URL từ server)
    // (Dữ liệu server trả về là list URL)
    // Ở phần hiển thị bạn dùng: (widget.post["images"] ?? [])
    // nên ở đây có thể không cần setState.
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Đăng tin"),
        centerTitle: true,

        actions: [
          TextButton(
            onPressed: () {},

            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              // padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text("lưu nháp"),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ref.watch(loggedInProvider.notifier).state
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ĐỊA CHỈ VÀ HÌNH ẢNH"),
                    const SizedBox(height: 6),
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
                            return AddressBottomSheet();
                          },
                        );
                        if (fullAddress != null) {
                          print("địa chỉ : ${fullAddress.toString()}");
                          setState(() {
                            address = fullAddress;
                            errorAddress = null;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: errorAddress != null
                                ? Colors.red
                                : Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: errorAddress != null
                              ? Text(
                                  errorAddress!,
                                  style: TextStyle(color: Colors.red),
                                )
                              : Text(
                                  address == null
                                      ? "Địa chỉ"
                                      : address.toString(),
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    img.isEmpty
                        ? InkWell(
                            onTap: _pickImages,
                            child: Container(
                              width: double.infinity,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.camera_alt_outlined),
                                  Text("chọn ảnh"),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ...(img).map((url) {
                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            url,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                img.remove(url);
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                Icons.close,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Positioned(
                                        //   bottom: 4,
                                        //   left: 0,
                                        //   right: 0,
                                        //   child: ElevatedButton(
                                        //     onPressed: () async {
                                        //       await ref.watch(uploadImagesProvider(_images));
                                        //     },
                                        //     child: const Text("test upload"),
                                        //   ),
                                        // ),
                                      ],
                                    );
                                  }).toList(),
                                  ..._images.map((file) {
                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            file,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _images.remove(file);
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                Icons.close,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Positioned(
                                        //   bottom: 4,
                                        //   left: 0,
                                        //   right: 0,
                                        //   child: ElevatedButton(
                                        //     onPressed: () async {
                                        //       await ref.watch(uploadImagesProvider(_images));
                                        //     },
                                        //     child: const Text("test upload"),
                                        //   ),
                                        // ),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),

                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: _pickImages,
                                icon: const Icon(Icons.add),
                                label: const Text("Thêm ảnh"),
                              ),
                            ],
                          ),
                    const SizedBox(height: 15),
                    Text("THÔNG TIN KHÁC"),
                    const SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      width: 200,
                      // height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey, width: 1),
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
                        onChanged: (val) {
                          setState(() => selectStatus = val);
                        },
                        decoration: const InputDecoration(
                          hintText: "Tình trạng nội thất",
                          border: InputBorder.none, // bỏ gạch dưới
                          enabledBorder: InputBorder.none, // bỏ khi chưa focus
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text("DIỆN TÍCH & GIÁ"),
                    const SizedBox(height: 6),
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
                    const SizedBox(height: 15),
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
                    const SizedBox(height: 15),
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
                    const SizedBox(height: 15),
                    Text("TIÊU ĐỀ TIN ĐĂNG VÀ MÔ TẢ CHI TIẾT"),
                    const SizedBox(height: 10),
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
                      minLines: 10,
                      maxLines: 11,
                      decoration: InputDecoration(
                        label: Text("Tiêu đề tin đăng"),
                        hint: Text("data"),
                        errorText: errorDescription,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8), // bo góc
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.blue, // màu khi focus
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(color: Colors.grey, width: 1),
                            ),
                          ),
                          child: Text("XEM TRƯỚC TIN"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            bool checkPost = true;
                            List<String> list = await ref.read(
                              uploadImagesProvider(_images).future,
                            );
                            final prefs = await SharedPreferences.getInstance();
                            final uid = await prefs.getString("uuid");

                            if (titleController.text.isEmpty) {
                              setState(() {
                                errorTitle = "không được để trống";
                                checkPost = false;
                              });
                            }
                            if (double.tryParse(priceController.text) == null) {
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
                            // if (list.isEmpty) {
                            //   // setState(() {
                            //   //
                            //   // });
                            //   checkPost = false;
                            // }
                            if (descriptionController.text.isEmpty) {
                              setState(() {
                                checkPost = false;
                                errorDescription = "không được để trống";
                              });
                            }
                            if (double.tryParse(areaController.text) == null) {
                              setState(() {
                                errorArea = "không được để trống hoặc ghi chữ";
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
                            final allImg = [...list,...img];
                            final PostModel post = PostModel(
                              userId: uid ?? "null",
                              title: titleController.text,
                              price: double.tryParse(priceController.text) ?? 0,
                              address: address.toString() ?? "",
                              images: allImg,
                              description: descriptionController.text,
                              area: double.tryParse(areaController.text) ?? 0,
                              deposit:
                                  double.tryParse(depositCotroller.text) ?? 0,
                              district: address?.district ?? "null",
                              province: address?.province ?? "null",
                              status: selectStatus ?? "null",
                              ward: address?.ward ?? "null",
                              postId:postId
                            );
                            print("post id nè: $postId");
                            print("đang chạy đến 277 ...");
                            // if (checkPost) {
                              print("post id nè: $postId 11");
                              await ref.read(uploadPostUpdate(post).future);
                            // }

                            // await ref.read(selectPost);
                            print("đang chạy đến 279 ...");

                          },

                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(
                            "ĐĂNG TIN",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go("/");
                },
                child: Text("Đăng nhập"),
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
      label: Text(label),
      errorText: error,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // bo góc
        borderSide: BorderSide(color: Colors.grey, width: 1),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Colors.blue, // màu khi focus
          width: 1.5,
        ),
      ),
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
