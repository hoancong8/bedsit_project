import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thuetro/model/account.dart';

import '../provider/auth_provider.dart';

class Account extends ConsumerStatefulWidget {
  const Account({super.key});

  @override
  ConsumerState createState() => _AccountState();
}

class _AccountState extends ConsumerState<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ref.watch(loggedInProvider)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    "https://kynguyenlamdep.com/wp-content/uploads/2022/08/anh-gai-xinh-che-mat-cuc-dep.jpg",
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Nguyễn Công Hoan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Người theo dõi 0", style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 10),
                    Text("Đang theo dõi 0", style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text(
                      "Tiện ích",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  width: double.infinity,
                  // height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.favorite_border),
                          title: Text("Tin đăng đã lưu"),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(Icons.bookmark_border),
                          title: Text("Tìm kiếm đã lưu"),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(Icons.history),
                          title: Text("Lịch sử xem tin"),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(Icons.star_border),
                          title: Text("Đánh giá từ tôi"),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text(
                      "Khác",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  width: double.infinity,
                  // height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.settings_outlined),
                          title: Text("Caì đặt tài khoản"),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(Icons.help_center_outlined),
                          title: Text("Trợ giúp"),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(Icons.headphones_outlined),
                          title: Text("Đóng góp ý kiến"),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.login_outlined,
                            color: Colors.red,
                          ),
                          title: Text(
                            "Đăng xuất",
                            style: TextStyle(color: Colors.red),
                          ),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () async {
                            await ref.read(authProvider.notifier).signOut(ref,context);

                            // Reset lại trạng thái đăng nhập
                            ref.read(loggedInProvider.notifier).state = false;

                            // Làm mới provider khởi tạo nếu cần
                            ref.invalidate(authInitProvider);

                            // Quay về trang đăng nhập nếu bạn muốn
                            if (context.mounted) {
                              context.replace('/');

                            }
                          },

                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
