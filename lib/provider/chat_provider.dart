import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'auth_provider.dart';


//get list user messenger with you
final listFriendsChatProvider =
FutureProvider<List<Map<String, dynamic>>>((
    ref,
    ) async {
  final supabase = Supabase.instance.client;
  final pref =await SharedPreferences.getInstance();
  final user = pref.getString("uuid");
  // gọi query tới Supabase
  if (user == null) {
    print("Chưa có UUID — chưa đăng nhập hoặc SharedPreferences chưa load xong");
    return [];
  }
  final response = await supabase
      .from('friends_view')
      .select()
      .eq('me', user);
      // .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
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
