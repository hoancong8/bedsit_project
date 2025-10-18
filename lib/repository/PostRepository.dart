//
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:thuetro/model/account.dart';
// import 'package:thuetro/model/post.dart';
//
// class PostRepository {
//   final supabase = Supabase.instance.client;
//   Future<List<Post>> getPosts() async {
//     final response = await supabase.from('posts').select();
//     return (response as List)
//         .map((row) => Post.fromJson(row as Map<String, dynamic>))
//         .toList();
//   }
//  
//   Future<List<Account>> getAccount() async {
//     final response = await supabase.from('accounts').select();
//     return (response as List)
//         .map((row) => Account.fromJson(row as Map<String, dynamic>))
//         .toList();
//   }
// }
//
