import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

final supabase = Supabase.instance.client;
final addHistory = FutureProvider.family<void, String?>((ref, id_post) async {
  try {
    final pref = await SharedPreferences.getInstance();
    final id_user = pref.getString("uuid");
    await supabase.from('history').insert({
      'id_post': id_post,
      'id_user': id_user,
      'created_at': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    print("lỗi upload post ở đây: ${e.toString()}");
  }
});

// final selectHistoryByIdUser = FutureProvider<List<Map<String, dynamic>>>((
//   ref,
// ) async {
//   try {
//     final pref = await SharedPreferences.getInstance();
//     final id_user = pref.getString("uuid");
//     final response = await supabase
//         .from('history')
//         .select()
//         .eq('id_user', id_user!)
//         .order('created_at', ascending: false);
//     return List<Map<String, dynamic>>.from(response);
//   } catch (e) {
//     print("error : get data history history_provider ${e.toString()}");
//     return [];
//   }
// });
//
// final selectPostById = FutureProvider.family<Map<String, dynamic>?, String>(
//   (ref, id_post) async {
//     try{
//       final response = await supabase.from('post').select().eq('id', id_post).maybeSingle();
//       return response;
//     }catch(e){
//       print("error : get data post history_provider ${e.toString()}");
//       return {};
//     }
//   },
// );
