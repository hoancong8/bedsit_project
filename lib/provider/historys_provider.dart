import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class FavouriteRepository {
  final supabase = Supabase.instance.client;

  // Lấy danh sách post yêu thích theo user
  Future<List<Map<String, dynamic>>> getHistoryPosts(String userId) async {
    final response = await supabase
        .from('history')
        .select('id_post, post(*)') // join bảng post
        .eq('id_user', userId)
        .order('created_at', ascending: false);

    // Trả về danh sách post
    return (response as List)
        .map((item) => item['post'] as Map<String, dynamic>)
        .toList();
  }
}
final HistoryRepositoryProvider = Provider((ref) => FavouriteRepository());

final HistoryPostsProvider =
FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final repo = ref.watch(HistoryRepositoryProvider);
  return repo.getHistoryPosts(userId);
});