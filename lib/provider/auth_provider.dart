import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thuetro/model/account.dart';
import 'package:thuetro/provider/home_provider.dart';

import 'chat_provider.dart';
import 'manager_post_provider.dart';

final supabase = Supabase.instance.client;
final loggedInProvider   = StateProvider<bool>((ref) => false);

final authInitProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final uuid = prefs.getString("uuid");
  final statusLogin = prefs.getBool("status_login") ?? false;
  if (uuid != null && statusLogin) {
    ref.read(loggedInProvider.notifier).state = true;
    return true;
  }
  return false;
});


// Provider quản lý trạng thái đăng nhập
final authProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(),
);
class AuthController extends StateNotifier<bool> {
  AuthController() : super(false);
  Future<bool> signUp(
    String email,
    String pass,
    String name,
    String phone,
  ) async {
    try {
      final res = await supabase.auth.signUp(password: pass, email: email);

      await uploadAcc(AccountUsers(id: res.user!.id, account: email, password: pass,phone: phone,fullName: name));

      if (res.user != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("lỗi đăng kí ở đây !!!!!!!!! ${e.toString()}");
      return false;
    }
  }


  Future<void> uploadAcc(AccountUsers user)async{
    try {
      await supabase.from('users').insert({
        'id':user.id,
        'email':user.account,
        'password':user.password,
        'full_name':user.fullName,
        'phone':user.phone,
        'avt':user.avt,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("lỗi upload acc ở đây: ${e.toString()}");
    }
  }

  //get information user
  Future<Map<String,dynamic>> getAcc(String id)async{
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', id)
          .single();
      return response;
    } catch (e) {
      print("lỗi get acc ở đây: ${e.toString()}");
      return {};
    }
  }

  Future<bool> signIn(String email, String password,WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user != null) {
        final response = await getAcc(res.user!.id);
        prefs.setBool("status_login",true);
        prefs.setString("uuid", res.user!.id);
        prefs.setString("avt",response["avt"]??"null".toString());
        prefs.setString("full_name",response["full_name"]??"null".toString());
        prefs.setString("phone",response["phone"]??"null".toString());
        prefs.setString("address",response["address"]??"null".toString());

        print("data account login ở đây : ${response}");
        print("pref ở đây: ${prefs.getString("avt")}");
        print("uid ở đây: ${prefs.getString("uuid")}");
        print("status: ${prefs.getBool("status_login")}");
        ref.invalidate(loggedInProvider);
        //Các provider khác có dữ liệu user, reset hết
        ref.invalidate(selectPostProviderApproval("duyệt"));
        ref.invalidate(selectPostProviderApproval("đang duyệt"));
        ref.invalidate(selectPostProviderApproval("từ chối"));
        ref.invalidate(listFriendsChatProvider);
        ref.invalidate(messagesProvider);
        ref.invalidate(getFriendProvider);
        ref.invalidate(authProvider);
        ref.invalidate(loadAvatar);
        return true;
      } else {
        prefs.setBool("status_login",false);
        return false;
      }
    } catch (e) {
      // state = AsyncValue.error(e, st);
      print("sai ở auth_provider 31 !!!!!!!!!! ${e.toString()}");
      return false;
    }
  }

  Future<void> signOut(WidgetRef ref, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Đăng xuất khỏi Supabase
    await supabase.auth.signOut();
    // Xóa toàn bộ thông tin user trong SharedPreferences
    await prefs.clear();
    // Reset toàn bộ provider phụ thuộc user (rất quan trọng)
    ref.invalidate(loggedInProvider);
    //Các provider khác có dữ liệu user, reset hết
    ref.invalidate(selectPostProviderApproval("duyệt"));
    ref.invalidate(selectPostProviderApproval("đang duyệt"));
    ref.invalidate(selectPostProviderApproval("từ chối"));
    ref.invalidate(listFriendsChatProvider);
    ref.invalidate(messagesProvider);
    ref.invalidate(getFriendProvider);
    ref.invalidate(authProvider);
    ref.invalidate(loadAvatar);
  }

}
