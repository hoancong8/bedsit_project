import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../provider/home_provider.dart';
import '../../utils/utils.dart';
import 'ItemPost/item_post_vertical.dart';

class NearMe extends ConsumerWidget {
  const NearMe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearPosts = ref.watch(nearPostProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Bài đăng gần tôi")),
      body: nearPosts.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text("Không có bài đăng nào gần bạn"));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(nearPostProvider),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final post = data[index];

                        final imageUrl = (post["images"] != null && post["images"].isNotEmpty)
                            ? post["images"][0]
                            : null;

                        final distanceKm = (post["distance"] != null)
                            ? (post["distance"] / 1000).toStringAsFixed(2)
                            : "0.0";
                        print("distance-------------------------: ${distanceKm}+${post["distance"]}");
                        // 🔍 Log kiểm tra created_at
                        // print("⏰ NearMe created_at = ${post["created_at"]}");

                        return InkWell(
                          onTap: () {
                            // post.remove('distance');
                            print("post: ${post}");
                            GoRouter.of(context).push('/detail', extra: post);
                          },
                          child: ItemPost(
                            imageUrl: imageUrl,
                            title: post["title"]?.toString(),
                            price: formatMoneyVND(post["price"]),
                            location: "${post["address"] ?? ""} (${distanceKm} km)",
                            time: timeAgo(post["created_at"]),
                            id: post["id"].toString(),
                            area: post["area"].toString(),
                          ),
                        );
                      },
                      childCount: data.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        error: (e, _) => Center(child: Text("Lỗi: $e")),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
