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
      body: Column(
        children: [
          const SizedBox(height: 30),
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              widget.acc["avt"],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.acc["full_name"],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Xử lý khi nhấn Follow
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent, // Màu hồng
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
                  // Xử lý khi nhấn Message
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

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Người theo dõi 0", style: TextStyle(fontSize: 12)),
              const SizedBox(width: 10),
              Text("Đang theo dõi 0", style: TextStyle(fontSize: 12)),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("Bài đã đăng"),
          ),
          Expanded(
            child: ref.watch(selectUserPostProvider(widget.acc["id"]))
                .when(
              data: (data) {
                print("user id ở đây--: ${widget.acc["id"]} data:$data");
                if(data.isNotEmpty){
                  return RefreshIndicator(
                    onRefresh: () async {
                      // gọi lại provider hoặc API để load dữ liệu mới
                      ref.refresh(selectUserPostProvider(widget.acc["id"]));
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(8),
                          sliver: SliverGrid(
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.75,
                            ),
                            delegate: SliverChildBuilderDelegate((
                                ctx,
                                index,
                                ) {
                              final post = data[index];

                              final imageUrl =
                              (post["images"] != null &&
                                  post["images"].isNotEmpty)
                                  ? post["images"][0]
                                  : null;

                              return InkWell(
                                onTap: () {
                                  GoRouter.of(
                                    context,
                                  ).push('/detail', extra: post);
                                },
                                child: ItemPost(
                                  imageUrl: imageUrl,
                                  title: post["title"]?.toString(),
                                  price: formatMoneyVND(post["price"]),
                                  location: post["address"]?.toString(),
                                  time: timeAgo(post["created_at"]),
                                  id: post["id"].toString(),
                                ),
                              );
                            }, childCount: data.length),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                else {
                  return Center(child: Text("Không có bài đăng nào"),);
                }
              },
              error: (err, stack) => Center(child: Text("Lỗi: $err")),
              loading: () => const Center(child: CircularProgressIndicator(),),
            ),
          )
        ],
      ),
    );
  }
}
