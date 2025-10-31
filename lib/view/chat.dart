import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thuetro/provider/auth_provider.dart';
import 'package:thuetro/provider/chat_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends ConsumerWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(listRoomsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách phòng chat")),
      body: ref.watch(authInitProvider).when(
        data: (data) {
          if (!data) {
            return Center(
              child: ElevatedButton(
                onPressed: () => GoRouter.of(context).go('/sign_in'),
                child: const Text("Đăng nhập"),
              ),
            );
          }

          return roomsAsync.when(
            data: (rooms) {
              if (rooms.isEmpty) {
                return const Center(child: Text("Chưa có phòng chat nào"));
              }

              return FutureBuilder(
                future: SharedPreferences.getInstance(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final prefs = snapshot.data!;
                  final myId = prefs.getString("uuid");

                  return ListView.builder(
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      final users = List<String>.from(room["user"] ?? []);
                      final roomId = room["id"] ?? "";
                      final friendId = users.firstWhere(
                            (id) => id != myId,
                        orElse: () => "",
                      );

                      if (friendId.isEmpty) {
                        return const SizedBox(); // không có người còn lại
                      }

                      final friendAsync = ref.watch(getFriendProvider(friendId));

                      return friendAsync.when(
                        data: (friend) {
                          if (friend == null) return const SizedBox();

                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(48),
                              child: Container(
                                width: 45,
                                height: 45,
                                color: Colors.blue,
                                child: Image.network(
                                  friend["avt"] ?? "",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person_outlined),
                                ),
                              ),
                            ),
                            title: Text(friend["full_name"] ?? "Không tên"),
                            subtitle: Text("Phòng: $roomId"),
                            onTap: () {
                              print("Vào chat với ${friend["full_name"]} - $roomId");
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
                        error: (err, _) =>
                            ListTile(title: Text("Lỗi: $err")),
                      );
                    },
                  );
                },
              );
            },
            error: (err, _) =>
                Center(child: Text("Lỗi tải danh sách: $err")),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}
