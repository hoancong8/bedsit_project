import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'message.dart'; // Sử dụng Message Model đã được định nghĩa

class AppService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _password = '1'; // Mật khẩu chung

  // SỬA: Dùng email khác nhau và AuthResponse cho đúng cú pháp
  Future<void> _createUser(int i) async {
    final email = 'user$i@chat.com'; // Dùng email duy nhất

    // Cố gắng đăng ký user
    final AuthResponse response =
    await _supabase.auth.signUp(email: email, password: _password);

    if (response.user != null) {
      // Chèn vào bảng 'contact' (giả định là bảng chứa profiles)
      // Bỏ .execute() thừa
      await _supabase
          .from('contact')
          .insert({'id': response.user!.id, 'username': 'User $i'});
    }
  }

  Future<void> createUsers() async {
    await _createUser(1);
    await _createUser(2);
  }

  // SỬA: Phải dùng signInWithPassword để đăng nhập
  Future<void> signIn(int i) async {
    final email = 'admin@gmail.com'; // Email user đã tạo
    await _supabase.auth.signInWithPassword(email: email, password: _password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // SỬA: Thêm .limit(1) và bỏ .execute()
  Future<String> _getUserTo() async {
    final response = await _supabase
        .from('contact')
        .select('id')
        .not('id', 'eq', getCurrentUserId())
        .limit(1); // Chỉ lấy một người dùng

    if (response.isNotEmpty) {
      // Ép kiểu List<dynamic>
      final data = response as List<dynamic>;
      return data[0]['id'];
    }
    throw Exception("Không tìm thấy người dùng khác để chat.");
  }

  // SỬA QUAN TRỌNG: Cú pháp Realtime Stream mới
  Stream<List<Message>> getMessages() {
    return _supabase
        .from('message')
        .stream(primaryKey: ['id']) // Cú pháp stream đúng
        .order('created_at', ascending: true)
        .map((maps) => (maps as List<dynamic>)
        .map((item) => Message.fromJson(item as Map<String, dynamic>, getCurrentUserId()))
        .toList());
  }

  Future<void> saveMessage(String content) async {
    final userTo = await _getUserTo();

    // Sử dụng constructor Message.create
    final message = Message.create(
        content: content, userFrom: getCurrentUserId(), userTo: userTo);

    // Bỏ .execute() thừa
    await _supabase.from('message').insert(message.toMap());
  }

  Future<void> markAsRead(String messageId) async {
    // Bỏ .execute() thừa và sửa lỗi cú pháp trước đó
    await _supabase
        .from('message')
        .update({'mark_as_read': true})
        .eq('id', messageId);
  }

  // SỬA: Tên hàm đúng chính tả
  bool isAuthenticated() => _supabase.auth.currentUser != null;

  String getCurrentUserId() =>
      isAuthenticated() ? _supabase.auth.currentUser!.id : '';

  String getCurrentUserEmail() =>
      isAuthenticated() ? _supabase.auth.currentUser!.email ?? '' : '';
}