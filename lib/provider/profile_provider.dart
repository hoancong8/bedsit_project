import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';


//get post of user by user id
final selectUserPostProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      userId,
    ) async {
      final supabase = Supabase.instance.client;

      // gọi query tới Supabase
      final response = await supabase
          .from('post')
          .select()
          .eq('status_post', "duyệt")
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    });
