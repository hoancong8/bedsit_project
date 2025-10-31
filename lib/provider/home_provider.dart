import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:thuetro/model/account.dart';
import 'auth_provider.dart';

//get list post of all user
final selectPostProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = Supabase.instance.client;
  // gọi query tới Supabase
  final response = await supabase
      .from('post')
      .select()
      .eq('status_post', "duyệt")
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

//add user id to liked post
Future<void> toggleFavourite(String postId, bool isLiked) async {
  final prefs = await SharedPreferences.getInstance();
  final uid = prefs.getString("uuid");

  try {
    final postIdStr = postId.toString();
    final userIdStr = uid.toString();

    if (isLiked) {
      print("add_favourite: $postIdStr | $userIdStr");
      await supabase.rpc(
        'add_favourite',
        params: {'post_id': postIdStr, 'user_id': userIdStr},
      );
    } else {
      print("remove_favourite: $postIdStr | $userIdStr");
      await supabase.rpc(
        'remove_favourite',
        params: {'post_id': postIdStr, 'user_id': userIdStr},
      );
    }
  } catch (e, s) {
    print("Lỗi RPC favourite: $e");
    print(s);
  }
}

//get information user to SharedPreferences
final loadAvatar = FutureProvider<AccountUsers>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  String id = prefs.getString("uuid") ?? "trống";
  String avt = prefs.getString("avt") ?? "trống";
  String? full_name = prefs.getString("full_name");
  String phone = prefs.getString("phone") ?? "trống";
  String address = prefs.getString("address") ?? "trống";

  AccountUsers user = AccountUsers(
    id: id,
    avt: avt,
    fullName: full_name,
    address: address,
    phone: phone,
  );

  return user;
});


