import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class FavouriteRepository {
  final supabase = Supabase.instance.client;

  // Lấy danh sách post yêu thích theo user
  Future<List<Map<String, dynamic>>> getFavouritePosts(String userId) async {
    final response = await supabase
        .from('favourite')
        .select('id_post, post(*)') // join bảng post
        .eq('id_user', userId)
        .order('created_at', ascending: false);

    // Trả về danh sách post
    return (response as List)
        .map((item) => item['post'] as Map<String, dynamic>)
        .toList();
  }
}
final favouriteRepositoryProvider = Provider((ref) => FavouriteRepository());

final favouritePostsProvider =
FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final repo = ref.watch(favouriteRepositoryProvider);
  return repo.getFavouritePosts(userId);
});

final supabase = Supabase.instance.client;
final addFavourite = FutureProvider.family<void, String?>((ref, id_post) async {
  try {
    final pref = await SharedPreferences.getInstance();
    final id_user = pref.getString("uuid");
    await supabase.from('favourite').insert({
      'id_post': id_post,
      'id_user': id_user,
      'created_at': DateTime.now().toIso8601String(),
    });
    print("ok add");
  } catch (e) {
    print("lỗi upload favourite ở đây: ${e.toString()}");
  }
});

final removeFavourite = FutureProvider.family<void, String?>((ref, id_post) async {
  try {
    final pref = await SharedPreferences.getInstance();
    final id_user = pref.getString("uuid");
    await supabase
        .from('favourite')
        .delete()
        .eq('id_post', id_post!)
        .eq('id_user', id_user!);
    print("ok delete");
  } catch (e) {
    print("Lỗi xóa favourite: ${e.toString()}");
  }
});

final userFavouritesProvider = FutureProvider<List<String>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final idUser = prefs.getString("uuid");

  if (idUser == null) return [];

  final response = await supabase
      .from('favourite')
      .select('id_post')
      .eq('id_user', idUser);

  return response.map<String>((e) => e['id_post'] as String).toList();
});