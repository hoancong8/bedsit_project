import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thuetro/model/account.dart';
import 'package:thuetro/provider/home_provider.dart';

import '../provider/auth_provider.dart';

class Account extends ConsumerStatefulWidget {
  const Account({super.key});
  @override
  ConsumerState createState() => _AccountState();
}

class _AccountState extends ConsumerState<Account> {
  String? id;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ref.watch(loggedInProvider)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                ref.watch(loadAvatar).when(data: (data){
                  id = data.id;
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(48),
                        child: Container(
                          width: 45,
                          height: 45,
                          color: Colors.blue,
                          child: Image.network(
                            data.avt ??
                                "https://tse3.mm.bing.net/th/id/OIP.0eDamzEphB4k1QjbE9jAHwHaE7?pid=Api&P=0&h=180",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person_outlined);
                            },),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data.fullName??"Khách",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                }, error: (err, stack) => Center(child: Text("Lỗi: $err")),
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),),

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
                          title: Text("Tin yêu thích"),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            GoRouter.of(context).push("/favourite",extra:id );
                          },
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
                          onTap: () {
                            GoRouter.of(context).push("/history",extra:id );
                          },
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
                  GoRouter.of(context).go('/sign_in');
                },
                child: Text("Đăng nhập"),
              ),
            ),
    );
  }
}
