import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thuetro/provider/auth_provider.dart';
import 'package:thuetro/provider/chat_provider.dart';

class Chat extends ConsumerWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.refresh(listFriendsChatProvider);
    final friendsAsync = ref.watch(listFriendsChatProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách bạn bè")),
      body: ref
          .watch(authInitProvider)
          .when(
            data: (data) {
              if (data) {
                return friendsAsync.when(
                  data: (friends) {
                    if (friends.isEmpty) {
                      return const Center(child: Text("Chưa có bạn nào "));
                    }
                    return ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        String friendId = friends[index]["friend"];
                        String roomId = friends[index]["room_id"];

                        // Lấy thông tin bạn
                        var friendAsync = ref.watch(
                          getFriendProvider(friendId),
                        );

                        return friendAsync.when(
                          data: (friend) {
                            if (friend == null) {
                              return const SizedBox();
                            }

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: friend["avt"] != null
                                    ? NetworkImage(friend["avt"])
                                    : const AssetImage(
                                            'assets/default_avatar.png',
                                          )
                                          as ImageProvider,
                              ),
                              title: Text(friend["full_name"] ?? "Không tên"),
                              subtitle: Text("Room: $roomId"),
                              onTap: () {
                                // sang trang chat cụ thể
                                print(
                                  "Vào chat với ${friend["full_name"]} - $roomId",
                                );
                                context.push(
                                  '/chatroom',
                                  extra: {'friend': friend, 'room_id': roomId},
                                );
                              },
                            );
                          },
                          loading: () => const ListTile(
                            leading: CircleAvatar(
                              child: CircularProgressIndicator(),
                            ),
                            title: Text("Đang tải..."),
                          ),
                          error: (err, _) => ListTile(title: Text("Lỗi: $err")),
                        );
                      },
                    );
                  },
                  error: (err, _) =>
                      Center(child: Text("Lỗi tải danh sách: $err")),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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
            error: (e, _) => Center(child: Text('Lỗi: $e')),
          ),
    );
  }
}
