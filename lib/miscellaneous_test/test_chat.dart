import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../provider/auth_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://mvhldwmcuhdjbkgsgyib.supabase.co', // Project URL
    anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im12aGxkd21jdWhkamJrZ3NneWliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY1NTc4ODIsImV4cCI6MjA3MjEzMzg4Mn0.zxqJ9CuzW3Bt8tquKBHBopgYUVYSEw-kDWqd9RdvxnI', // Anon public key
  );

  runApp(
    const ProviderScope( // ✅ Bọc toàn bộ app trong ProviderScope
      child: MaterialApp(home: ChatListPage(),),
    ),
  );
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Supabase Chat",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const ChatScreen(
        conversationId: 'e2a3df51-2e5e-4c5d-b87b-0f81a81b5b1b', // tạm gắn cứng, lát dynamic
        friendName: '4c322a8a-cc93-42ef-bc7a-21a74ab3fad4',
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String friendName;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.friendName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final supabase = Supabase.instance.client;
  final controller = TextEditingController();

  late final Stream<List<Map<String, dynamic>>> messageStream;
  String? myId;

  @override
  void initState() {
    super.initState();
    myId = supabase.auth.currentUser?.id;

    messageStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', widget.conversationId)
        .order('created_at', ascending: true)
        .map((rows) => rows);
  }

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    controller.clear();

    await supabase.from('messages').insert({
      'conversation_id': widget.conversationId,
      'sender_id': '4c322a8a-cc93-42ef-bc7a-21a74ab3fad4',
      'content': text,
    });
  }

  Widget _bubble(Map<String, dynamic> msg) {
    bool isMe = msg['sender_id'] == myId;
    final time = DateFormat('HH:mm').format(DateTime.parse(msg['created_at']));

    return Align(
      alignment: !isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[400] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: !isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: !isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg['content'] ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black45,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 8),
            Text(widget.friendName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: messageStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, i) => _bubble(messages[i]),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
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
class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  // Sử dụng một Future để FutureBuilder có thể theo dõi
  late final Future<List<Map<String, dynamic>>> _friendsFuture;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    // Gán Future một lần duy nhất trong initState
    _friendsFuture = _getChatFriends();
  }

  /// Hàm lấy danh sách bạn bè từ Supabase RPC
  Future<List<Map<String, dynamic>>> _getChatFriends() async {
    try {
      // Dòng này chỉ nên dùng để test. Trong app thực tế, bạn cần đảm bảo người dùng đã đăng nhập từ trước.
      await ref.read(authProvider.notifier).signIn("admin@gmail.com", "1");

      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        // Ném lỗi một cách rõ ràng nếu người dùng chưa đăng nhập
        throw Exception("Người dùng chưa đăng nhập. Vui lòng đăng nhập để tiếp tục.");
      }

      final userId = currentUser.id;
      print('Đang lấy danh sách bạn bè cho user ID: $userId');

      // Gọi RPC function
      final response = await supabase.rpc(
        'get_chat_friends',
        params: {'p_user_id': userId},
      );

      // RPC có thể trả về lỗi dưới dạng PostgrestException, sẽ được catch ở dưới
      // Chuyển đổi kết quả trả về thành một danh sách các Map
      return List<Map<String, dynamic>>.from(response);

    } on PostgrestException catch (error) {
      // Bắt lỗi cụ thể từ Supabase để debug dễ hơn
      print('Lỗi Supabase: ${error.message}');
      throw Exception('Không thể tải danh sách bạn bè: ${error.message}');
    } catch (e) {
      // Bắt các lỗi khác
      print('Lỗi không xác định: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách trò chuyện"),
      ),
      // Sử dụng FutureBuilder để tự động xử lý các trạng thái của Future
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _friendsFuture, // Cung cấp Future cần theo dõi
        builder: (context, snapshot) {
          // 1. Trạng thái đang chờ (loading)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Trạng thái có lỗi
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Đã xảy ra lỗi: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // 3. Trạng thái có dữ liệu nhưng là null hoặc rỗng
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Bạn chưa có cuộc trò chuyện nào.'),
            );
          }

          // 4. Trạng thái có dữ liệu, hiển thị danh sách
          final friends = snapshot.data!;
          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              final fullName = friend['full_name'] as String? ?? 'Người dùng không tên';
              final email = friend['email'] as String? ?? 'Không có email';

              return ListTile(
                leading: CircleAvatar(
                  // Hiển thị ảnh đại diện nếu có
                  backgroundImage: friend['avt'] != null ? NetworkImage(friend['avt']) : null,
                  child: friend['avt'] == null ? const Icon(Icons.person) : null,
                ),
                title: Text(fullName),
                subtitle: Text(email),
                onTap: () {
                  // Điều hướng đến màn hình chat với `friend['friend_id']`
                  print('Mở màn hình chat với user ID: ${friend['friend_id']}');
                },
              );
            },
          );
        },
      ),
    );
  }
}