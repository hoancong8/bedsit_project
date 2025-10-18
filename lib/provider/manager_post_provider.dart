import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

//get list information post by status of post(eg:status:"duyệt")
final selectPostProviderApproval =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      status,
    ) async {
      final prefs = await SharedPreferences.getInstance();

      final supabase = Supabase.instance.client;
      try {
        final response = await supabase
            .from('post')
            .select()
            .eq('status_post', status)
            .eq('user_id', prefs.getString("uuid")!)
            .order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      } catch (e) {
        print("lỗi trang đang hiển thị ở đây: ${e.toString()}");
        return [];
      }
    });

//delete post by post id
final deletePost = FutureProvider.family<void, String>((ref, postId) async {
  final prefs = await SharedPreferences.getInstance();

  final supabase = Supabase.instance.client;
  try {
    final response = await supabase.from('post').delete().eq('id', postId);
    if (response.isEmpty) {
      print('Không có bài nào bị xóa (id có thể sai)');
    } else {
      print('Xóa bài viết thành công');
    }
  } catch (e) {
    print("lỗi trang chờ duyệt ở đây: ${e.toString()}");
  }
});
