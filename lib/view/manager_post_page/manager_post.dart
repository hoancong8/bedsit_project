import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thuetro/provider/auth_provider.dart';
import 'package:thuetro/provider/manager_post_provider.dart';
import 'package:thuetro/view/manager_post_page/pending_review_post.dart';
import 'package:thuetro/view/manager_post_page/show_post.dart';

class ManagerPost extends ConsumerStatefulWidget {
  const ManagerPost({super.key});

  @override
  ConsumerState createState() => _ManagerPostState();
}

class _ManagerPostState extends ConsumerState<ManagerPost> {
  String formatPrice(num price) {
    return "${price.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")} đ";
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          title: Text("Quản lý tin đăng"),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.search_outlined)),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_outlined),
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: "Đang hiển thị"),
              Tab(text: "Tin nháp"),
              Tab(text: "Chờ duyệt"),
              Tab(text: "Bị từ chối"),
            ],
          ),
        ),

        body: ref
            .watch(authInitProvider)
            .when(
              data: (check) {
                if (check) {
                  return TabBarView(
                    children: [
                      ShowPost(),
                      Center(child: Text("Danh sách tin chờ duyệt")),
                      PendingReviewPost(),
                      Center(child: Text("Danh sách tin bị từ chối")),
                    ],
                  );
                } else {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        GoRouter.of(context).go('/sign_in');
                      },
                      child: Text("Đăng nhập"),
                    ),
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Lỗi: $e'))),

      ),
    );
  }
}
