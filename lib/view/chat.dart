import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thuetro/provider/auth_provider.dart';
import 'package:thuetro/provider/chat_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/utils.dart';

class Chat extends ConsumerWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(listRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tin nhắn"),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () => ref.refresh(listRoomsProvider),
            icon: const Icon(Icons.refresh),
            tooltip: "Làm mới",
          )
        ],
      ),
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text("Lỗi tải danh sách: $err")),
            data: (rooms) {
              if (rooms.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 84, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text("Chưa có phòng chat nào", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(
                          "Bạn chưa có cuộc trò chuyện nào. Hãy tìm người dùng và bắt đầu cuộc trò chuyện.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => GoRouter.of(context).go('/'),
                          icon: const Icon(Icons.search),
                          label: const Text("Tìm người"),
                        )
                      ],
                    ),
                  ),
                );
              }

              return FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final prefs = snapshot.data!;
                  final myId = prefs.getString("uuid");

                  return RefreshIndicator(
                    onRefresh: () async => ref.refresh(listRoomsProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: rooms.length,
                      separatorBuilder: (_, __) => const Divider(height: 0),
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        final users = List<String>.from(room["user"] ?? []);
                        final roomId = room["id"] ?? "";
                        final friendId = users.firstWhere(
                              (id) => id != myId,
                          orElse: () => "",
                        );

                        if (friendId.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final friendAsync = ref.watch(getFriendProvider(friendId));

                        return friendAsync.when(
                          loading: () => const ListTile(
                            leading: CircleAvatar(child: CircularProgressIndicator(strokeWidth: 2)),
                            title: Text("Đang tải..."),
                          ),
                          error: (err, _) => ListTile(title: Text("Lỗi: $err")),
                          data: (friend) {
                            if (friend == null) return const SizedBox.shrink();

                            final lastMsg = room["last_message"] ?? "Chưa có tin nhắn";
                            final lastTime = room["last_time"];
                            final unread = room["unread"] ?? 0;

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 1,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  context.push(
                                    '/chatroom',
                                    extra: {'friend': friend, 'room_id': roomId},
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.grey.shade200,
                                        backgroundImage: (friend["avt"] != null && (friend["avt"] as String).isNotEmpty)
                                            ? NetworkImage(friend["avt"])
                                            : null,
                                        child: (friend["avt"] == null || (friend["avt"] as String).isEmpty)
                                            ? Text(
                                                _initials(friend["full_name"]),
                                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    friend["full_name"] ?? "Không tên",
                                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                if (lastTime != null)
                                                  Text(
                                                    timeAgo(lastTime),
                                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    lastMsg,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(color: Colors.grey.shade700),
                                                  ),
                                                ),
                                                if (unread != null && unread > 0) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.redAccent,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      unread > 99 ? '99+' : unread.toString(),
                                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                                    ),
                                                  )
                                                ]
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  String _initials(dynamic name) {
    try {
      if (name == null) return '';
      final parts = (name as String).trim().split(' ');
      if (parts.isEmpty) return '';
      if (parts.length == 1) return parts[0][0].toUpperCase();
      return (parts[0][0] + parts.last[0]).toUpperCase();
    } catch (_) {
      return '';
    }
  }
}