import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thuetro/provider/profile_provider.dart';
import 'package:thuetro/view/account.dart';

import '../utils/utils.dart';
import 'home/ItemPost/item_post_vertical.dart';

class Profile extends ConsumerStatefulWidget {
  final Map<String, dynamic> acc;
  const Profile({super.key, required this.acc});

  @override
  ConsumerState createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(48),
            child: Container(
              width: 45,
              height: 45,
              color: Colors.blue,
              child: Image.network(
                widget.acc["avt"] ??
                    "https://tse3.mm.bing.net/th/id/OIP.0eDamzEphB4k1QjbE9jAHwHaE7?pid=Api&P=0&h=180",
                fit: BoxFit.cover,errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.person_outlined);
              },
              ),
            ),
          ),

            // Tên người dùng
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.acc["full_name"],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Nút Theo dõi / Nhắn tin
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Theo dõi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    // Chỗ này bạn thêm route chat room sau nhé
                    GoRouter.of(context).go("/");
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Nhắn tin',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Dòng mô tả
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Người theo dõi 0", style: TextStyle(fontSize: 12)),
                SizedBox(width: 10),
                Text("Đang theo dõi 0", style: TextStyle(fontSize: 12)),
              ],
            ),

            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("Bài đã đăng", style: TextStyle(fontWeight: FontWeight.bold)),
            ),


            ref.watch(selectUserPostProvider(widget.acc["id"])).when(
              data: (data) {
                if (data.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(data.length, (index) {
                          final post = data[index];
                          final imageUrl = (post["images"] != null && post["images"].isNotEmpty)
                              ? post["images"][0]
                              : null;

                          return InkWell(
                            onTap: () {
                              GoRouter.of(context).push('/detail', extra: post);
                            },
                            child: SizedBox(
                              width: (MediaQuery.of(context).size.width - 8 * 3) / 2,
                              child: ItemPost(
                                imageUrl: imageUrl,
                                title: post["title"]?.toString(),
                                price: formatMoneyVND(post["price"]),
                                location: post["address"]?.toString(),
                                time: timeAgo(post["created_at"]),
                                id: post["id"].toString(),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text("Không có bài đăng nào")),
                  );
                }
              },
              error: (err, stack) => Center(child: Text("Lỗi: $err")),
              loading: () => const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
