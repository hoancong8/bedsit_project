import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thuetro/model/account.dart';
import 'package:thuetro/model/post.dart';

import '../repository/PostRepository.dart';
import '../view/post.dart';
import 'auth_provider.dart';



//get data file tinh_tp.json in assets/json
final provinces = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/json/tinh_tp.json');
  final Map<String, dynamic> data = jsonDecode(jsonStr);
  return data.values.map((e) => e as Map<String, dynamic>).toList();
});

//get data file quan_huyen.json in assets/json (input ui selected provinces)
final districts = FutureProvider.family<List<Map<String, dynamic>>, String>((
  ref,
  provinceId,
) async {
  final jsonStr = await rootBundle.loadString('assets/json/quan_huyen.json');
  final Map<String, dynamic> data = jsonDecode(jsonStr);
  final districts = data.values.map((e) => e as Map<String, dynamic>).toList();
  return districts.where((d) => d["parent_code"] == provinceId).toList();
});

//get data file xa_phuong.json in assets/json (input ui selected districts)
final wards = FutureProvider.family<List<Map<String, dynamic>>, String>((
  ref,
  provinceId,
) async {
  final jsonStr = await rootBundle.loadString('assets/json/xa_phuong.json');
  final Map<String, dynamic> data = jsonDecode(jsonStr);
  final districts = data.values.map((e) => e as Map<String, dynamic>).toList();
  return districts.where((d) => d["parent_code"] == provinceId).toList();
});


//upload img to storage
final uploadImagesProvider = FutureProvider.family<List<String>, List<File>>((
  ref,
  images,
) async {
  final supabase = Supabase.instance.client;
  List<String> urls = [];

  for (var file in images) {
    final fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${file.path.split("/").last}";

    // upload vào bucket "imgthuetro"
    try {
      await supabase.storage
          .from('imgthuetro')
          .upload("imgthuetro/$fileName", file);
      final publicUrl = supabase.storage
          .from('imgthuetro')
          .getPublicUrl('imgthuetro/$fileName');
      urls.add(publicUrl);
      print("upload thành công !!!");
    } catch (e) {
      print("Lỗi upload ở đây: ${e.toString()}");
    }
  }
  return urls;
});


//upload post to db in supabase
final uploadPost = FutureProvider.family<void, PostModel>((ref, post) async {

    try {
      await supabase.from('post').insert({
        'user_id': post.userId,
        'title': post.title,
        'description': post.description,
        'price': post.price,
        'area': post.area,
        'address': post.address,
        'province': post.province,
        'district': post.district,
        'ward': post.ward,
        'images': post.images,
        'status': post.status,
        'deposit': post.deposit,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("lỗi upload post ở đây: ${e.toString()}");
    }
});

//get image to gallery return list file image
Future<List<File>> pickImages() async {

  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: true, // chọn nhiều ảnh
  );
  if (result != null) {
    return result.paths.map((path) => File(path!)).toList();
    // setState(() {
    //   _images = result.paths.map((path) => File(path!)).toList();
    // });
  }
  else
    {
      return [];
    }
}







//update post
final uploadPostUpdate = FutureProvider.family<void, PostModel>((ref, post) async {

  try {
    print("post id ơ đây :${post.postId!}");
    await supabase.from('post').update({
      'user_id': post.userId,
      'title': post.title,
      'description': post.description,
      'price': post.price,
      'area': post.area,
      'address': post.address,
      'province': post.province,
      'district': post.district,
      'ward': post.ward,
      'images': post.images,
      'status': post.status,
      'deposit': post.deposit,
      'created_at': DateTime.now().toIso8601String(),
    }).eq('id', post.postId!);
  } catch (e) {
    print("lỗi upload post ở đây: ${e.toString()}");
  }
});









