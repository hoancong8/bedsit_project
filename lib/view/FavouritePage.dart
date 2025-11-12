import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/favourite_provider.dart';
import '../provider/historys_provider.dart';
import '../utils/utils.dart';
import 'home/ItemPost/item_post_vertical.dart';

class FavouritePage extends ConsumerWidget {
  final String userId;
  const FavouritePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.invalidate(favouritePostsProvider(userId));
    final histories = ref.watch(favouritePostsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Bài đăng yêu thích')),
      body: histories.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text("Chưa có bài đăng yêu thích"));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ItemPost(
                id: post['id'],
                title: post['title'],
                imageUrl: (post['images'] as List?)?.first ?? "",
                price: "${post['price']} triệu",
                area: "${post['area']}",
                location: post['address'],
                time: timeAgo(post['created_at']),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Lỗi: $err")),
      ),
    );
  }
}
