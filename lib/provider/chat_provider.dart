import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'auth_provider.dart';


//get list user messenger with you
// 📦 Lấy danh sách phòng chat mà user hiện tại tham gia
final listRoomsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final supabase = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("uuid");

    if (userId == null) {
      print("⚠️ Chưa có UUID — có thể chưa đăng nhập");
      return [];
    }

    // 🔍 Lấy danh sách phòng chat mà user đang tham gia
    final response = await supabase
        .from('rooms')
        .select()
        .contains('user', [userId]) // kiểm tra user có trong mảng users
        .order('created_at', ascending: false);

    if (response.isEmpty) {
      print("ℹ️ Chưa có phòng chat nào");
      return [];
    }

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print("❌ Lỗi khi lấy danh sách phòng: $e");
    return [];
  }
});


//check room
final addNewRoomProvider = FutureProvider.family<String, String>((ref, targetUserId) async {
  final supabase = Supabase.instance.client;
  final prefs = await SharedPreferences.getInstance();
  final currentUserId = prefs.getString("uuid");

  // nếu chưa đăng nhập hoặc target trống
  if (currentUserId == null || targetUserId.isEmpty) {
    throw Exception("Thiếu user id hoặc target id");
  }

  // kiểm tra xem đã có phòng giữa 2 user chưa
  final existingRooms = await supabase
      .from('rooms')
      .select()
      .contains('user', [currentUserId, targetUserId]);

  if (existingRooms.isNotEmpty) {
    final roomId = existingRooms.first['id'] as String;
    print("Phòng đã tồn tại: $roomId");
    return roomId;
  }

  // nếu chưa có phòng thì tạo mới
  final insertResponse = await supabase
      .from('rooms')
      .insert({
    'user': [currentUserId, targetUserId],
    'name': 'Chat giữa $currentUserId và $targetUserId',
  })
      .select()
      .single();

  final newRoomId = insertResponse['id'] as String;
  print("Tạo phòng mới: $newRoomId");
  return newRoomId;
});



//get information user
final getFriendProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, idfriend) async {
  final res = await ref.read(authProvider.notifier).getAcc(idfriend);
  return res;
});


// Provider load tin nhắn
final messagesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, roomId) {
  final stream = supabase
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('room_id', roomId)
      .order('created_at', ascending: true);
  return stream;
});
// Gửi tin nhắn
Future<void> sendMessage(String roomId, String senderId, String content) async {
  if (content.trim().isEmpty) return;
  await supabase.from('messages').insert({
    'room_id': roomId,
    'sender_id': senderId,
    'content': content,
  });
}
