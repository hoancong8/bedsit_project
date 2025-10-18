import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thuetro/utils/utils.dart';

import '../provider/auth_provider.dart';


class DetailPost extends ConsumerStatefulWidget {
  final Map<String, dynamic> post;

  const DetailPost({super.key, required this.post});

  @override
  ConsumerState<DetailPost> createState() => _DetailPostState();
}

class _DetailPostState extends ConsumerState<DetailPost> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Map<String, dynamic>? postUser;

  void _loadUser() async {
    final res = await ref
        .read(authProvider.notifier)
        .getAcc(widget.post["user_id"].toString());
    setState(() {
      postUser = res;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    // final List images = widget.post["images"] ?? [];
    final List images = List.from(widget.post["images"] ?? []);
    // if(widget.post["img360"]!=null){
      images.add("360");
    // }
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (images.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FullScreenImagePage(
                                  images: images,
                                  initialIndex: _currentIndex,
                                ),
                          ),
                        );
                      }
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.isNotEmpty ? images.length : 1,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final img = images.isNotEmpty
                            ? images[index]
                            : "https://via.placeholder.com/400x300.png?text=No+Image";
                        if(images[index]=="360"){
                          return InkWell(
                            onTap: () {
                              GoRouter.of(context).push("/panorama_screen");
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Ảnh nền
                                Image.asset(
                                  "assets/image/canh1.jpg",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),

                                // Lớp phủ đen mờ
                                Container(
                                  color: Colors.black.withOpacity(0.4),
                                ),

                                // Chữ hiển thị giữa ảnh
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.threesixty, color: Colors.white, size: 40),
                                    SizedBox(height: 8),
                                    Text(
                                      "Xem ảnh 360 độ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );

                        }
                        return Image.network(img, fit: BoxFit.cover);
                      },
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentIndex == index ? 10 : 6,
                            height: _currentIndex == index ? 10 : 6,
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? Colors.white
                                  : Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post["title"] ?? "Tiêu đề phòng trọ",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "${formatMoneyVND(widget.post["price"] ?? "2,7 triệu/tháng")}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text("${widget.post["area"] ?? "18"} m²",style: TextStyle(color: Colors.grey),),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.post["address"] ??
                        "Ngõ 151, Nguyễn Đức Cảnh, Hoàng Mai, Hà Nội",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Đăng ${timeAgo(widget.post["updated_at"] ?? "4 ngày trước")}",
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Người cho thuê
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: (postUser?["avt"] != null && postUser!["avt"]
                    .toString()
                    .isNotEmpty)
                    ? NetworkImage(postUser!["avt"].toString())
                    : null,
                child: (postUser?["avt"] == null || postUser!["avt"]
                    .toString()
                    .isEmpty)
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              title: Text(postUser?["full_name"] ?? "Người đăng"),
              subtitle: const Text("Hoạt động 4 ngày trước"),
              onTap: (){
                GoRouter.of(context).push("/profile",extra: postUser);
              },
            ),

            const Divider(height: 1),

            // Đặc điểm bất động sản
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Đặc điểm bất động sản",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.aspect_ratio,
                    "Diện tích",
                    "${widget.post["area"] ?? "18"} m²",
                  ),
                  _buildInfoRow(
                    Icons.chair,
                    "Tình trạng nội thất",
                    widget.post["status"] ?? "Nhà trống",
                  ),
                  _buildInfoRow(
                    Icons.key,
                    "Số tiền cọc",
                    "${formatMoneyVND(widget.post["deposit"] ?? "2.700.000 đ/tháng) ")}",
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Mô tả chi tiết
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mô tả chi tiết",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.post["description"] ??
                        "Không gian sân vườn rộng thoáng... phòng trọ mới riêng biệt. Khu phụ nóng lạnh đầy đủ",
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "SĐT liên hệ: ${postUser?["phone"]?? "097221****"}",
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Gọi ngay"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Bình luận
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bình luận",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: const [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 40,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 6),
                        Text("Chưa có bình luận nào."),
                        Text("Hãy để lại bình luận cho người bán."),

                      ],
                    ),
                  ),
                  ref
                      .watch(loggedInProvider.notifier)
                      .state ?
                  TextField():
                  Container(width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text("vui long dag nhap de binh luan"),)
                      ,
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

      // Thanh nút dưới
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                ),
                onPressed: () {},
                child: const Text("SMS"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                ),
                onPressed: () {},
                child: const Text("Chat"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {},
                child: const Text("Gọi"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label:",
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}


//zoom image
class FullScreenImagePage extends StatefulWidget {
  final List images;
  final int initialIndex;

  const FullScreenImagePage({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}
class _FullScreenImagePageState extends State<FullScreenImagePage> {
  late PageController _controller;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
    _current = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) {
              setState(() {
                _current = i;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _current == i ? 10 : 6,
                    height: _current == i ? 10 : 6,
                    decoration: BoxDecoration(
                      color: _current == i ? Colors.white : Colors.white54,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
