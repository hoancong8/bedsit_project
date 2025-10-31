import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thuetro/utils/utils.dart';

import '../../provider/manager_post_provider.dart';

class ShowPost extends ConsumerStatefulWidget {
  const ShowPost({super.key});

  @override
  ConsumerState createState() => _ShowPostState();
}

class _ShowPostState extends ConsumerState<ShowPost> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(selectPostProviderApproval("duyệt"));
    });
  }
  @override
  Widget build(BuildContext context) {
    return ref
        .watch(selectPostProviderApproval("duyệt"))
        .when(
      data: (data) {
        if(data.isEmpty){
          return Center(child: Text("Bạn chưa có bài đăng nào"),);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: data.length,
          itemBuilder: (context, index) {
            var post = data[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                vertical: 6,
              ),
              child: InkWell(
                onTap: () {
                  GoRouter.of(context).push(
                    '/detail_edit_post',
                    extra: post,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Ảnh
                      Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: post["images"][0] != null
                            ? Image.network(
                          post["images"][0],
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                              context,
                              error,
                              stackTrace,
                              ) {
                            return Image.network(
                              "https://taoanhdep.com/wp-content/uploads/2022/10/Butterfly-x-Allain.jpeg", // ảnh fallback
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                            : const Center(
                          child: Text("Ảnh"),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Thông tin
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              post["title"],
                              style: const TextStyle(
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Giá thuê: ${formatMoneyVND(post["price"])}",
                            ),
                            Text(post["address"]),
                            Text(
                              "Trạng thái: ${post["status"]}",
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons
                            .keyboard_arrow_right_outlined,
                      ),
                    ],
                  ),
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
