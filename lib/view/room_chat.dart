import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth_provider.dart';
import '../provider/chat_provider.dart';

class RoomChat extends ConsumerStatefulWidget {
  final Map<String, dynamic> friend;
  final String roomId;

  const RoomChat({super.key, required this.friend, required this.roomId});
  @override
  ConsumerState createState() => _RoomChatState();
}

class _RoomChatState extends ConsumerState<RoomChat> {
  final TextEditingController _controller = TextEditingController();
  late final String myId;
  final ScrollController _scrollController = ScrollController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    myId = supabase.auth.currentUser!.id;
    _controller.addListener(() {
      setState(() {
        _canSend = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTime(dynamic ts) {
    try {
      if (ts == null) return '';
      DateTime dt;
      if (ts is DateTime)
        dt = ts;
      else
        dt = DateTime.parse(ts.toString());
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.roomId));
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.friend["avt"] != null
                  ? NetworkImage(widget.friend["avt"])
                  : const AssetImage('assets/default_avatar.png')
                        as ImageProvider,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.friend["full_name"] ?? "Không tên",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.friend["status"] ?? "Đang hoạt động",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                // scroll to bottom when new messages come in
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender_id'] == myId;

                    final bubbleColor = isMe ? primary : Colors.grey.shade200;
                    final textColor = isMe ? Colors.white : Colors.black87;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 14,
                              backgroundImage: widget.friend["avt"] != null
                                  ? NetworkImage(widget.friend["avt"])
                                  : const AssetImage(
                                          'assets/default_avatar.png',
                                        )
                                        as ImageProvider,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.68,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: bubbleColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(isMe ? 12 : 4),
                                  topRight: Radius.circular(isMe ? 4 : 12),
                                  bottomLeft: const Radius.circular(12),
                                  bottomRight: const Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    msg['content'] ?? '',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatTime(msg['created_at']),
                                        style: TextStyle(
                                          color: textColor.withOpacity(0.8),
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (isMe)
                                        Icon(
                                          Icons.check_circle,
                                          size: 14,
                                          color: textColor.withOpacity(0.9),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isMe) const SizedBox(width: 8),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Lỗi: $err")),
            ),
          ),

          // input area
          SafeArea(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.add_circle_outline, color: primary),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              minLines: 1,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: "Nhập tin nhắn...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.emoji_emotions_outlined,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: _canSend ? primary : Colors.grey.shade300,
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: _canSend ? Colors.white : Colors.grey.shade600,
                      ),
                      onPressed: _canSend
                          ? () async {
                              final text = _controller.text.trim();
                              if (text.isEmpty) return;
                              await sendMessage(widget.roomId, myId, text);
                              _controller.clear();
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
