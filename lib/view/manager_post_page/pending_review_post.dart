import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/manager_post_provider.dart';
import '../../utils/utils.dart';

class PendingReviewPost extends ConsumerStatefulWidget {
  const PendingReviewPost({super.key});

  @override
  ConsumerState createState() => _PendingReviewPostState();
}

class _PendingReviewPostState extends ConsumerState<PendingReviewPost> {
  Future<void> confirmDeleteSheet(BuildContext context, WidgetRef ref, String postId) async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bạn có chắc chắn muốn xóa?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Xóa'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      await ref.read(deletePost(postId).future);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa bài viết thành công')),
      );
    }
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(selectPostProviderApproval("chờ duyệt"));
    });
  }
  @override
  Widget build(BuildContext context) {
    return ref
          .watch(selectPostProviderApproval("chờ duyệt"))
          .when(
        data: (data) {
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final post = data[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // ảnh
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        child: Image.network(
                          post["images"][0],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) {
                            return Image.network(
                              "https://mvhldwmcuhdjbkgsgyib.supabase.co/storage/v1/object/public/imgthuetro/imgthuetro/avt13.jpg", // ảnh fallback
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // nội dung
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              post["title"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatMoneyVND(post["price"]),
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              post["status"],
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () async {
                                    // xử lý xóa
                                    final confirm = await showModalBottomSheet<bool>(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                      builder: (context) => Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text('Bạn có chắc chắn muốn xóa?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                OutlinedButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('Hủy'),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Xóa'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );

                                    if (confirm == true) {
                                      data.remove(post);
                                      await ref.watch(deletePost(post["id"]));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Đã xóa bài viết thành công')),
                                      );
                                    }

                                  },
                                  child: const Text("Xóa"),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    // xử lý tiếp tục đăng tin
                                  },
                                  child: const Text(
                                    "đang chờ duyệt ",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Center(child: Text("Lỗi: $err")),
      );
  }
}
