import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../provider/auth_provider.dart';
import '../provider/home_provider.dart';

class Account extends ConsumerStatefulWidget {
  const Account({super.key});

  @override
  ConsumerState createState() => _AccountState();
}

class _AccountState extends ConsumerState<Account> {
  String? id;

  @override
  Widget build(BuildContext context) {
    final isLogin = ref.watch(loggedInProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLogin ? _buildLoggedUI() : _buildNotLogin(),
    );
  }

  // ================= LOGIN UI =================
  Widget _buildLoggedUI() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),

          // 🔥 HEADER PROFILE
          ref
              .watch(loadAvatar)
              .when(
                data: (data) {
                  id = data.id;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          backgroundImage: data.avt != null
                              ? NetworkImage(data.avt!)
                              : null,
                          child: data.avt == null
                              ? const Icon(Icons.person, size: 30)
                              : null,
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.fullName ?? "Khách",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Xem và chỉnh sửa hồ sơ",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),

                        Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  );
                },
                error: (e, s) => const Text("Lỗi"),
                loading: () => const CircularProgressIndicator(),
              ),

          const SizedBox(height: 12),

          // 🔥 STATS
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _StatItem("0", "Người theo dõi"),
                _StatItem("0", "Đang theo dõi"),
                _StatItem("0", "Tin đã đăng"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔥 TIỆN ÍCH
          _buildSection(
            title: "Tiện ích",
            children: [
              _item(Icons.favorite_border, "Tin yêu thích", () {
                GoRouter.of(context).push("/favourite", extra: id);
              }),
              _item(Icons.bookmark_border, "Tìm kiếm đã lưu", () {}),
              _item(Icons.history, "Lịch sử xem tin", () {
                GoRouter.of(context).push("/history", extra: id);
              }),
              _item(Icons.star_border, "Đánh giá từ tôi", () {}),
            ],
          ),

          // 🔥 KHÁC
          _buildSection(
            title: "Khác",
            children: [
              _item(Icons.settings_outlined, "Cài đặt tài khoản", () {}),
              _item(Icons.help_outline, "Trợ giúp", () {}),
              _item(Icons.feedback_outlined, "Góp ý", () {}),
              _item(Icons.logout, "Đăng xuất", () async {
                await ref.read(authProvider.notifier).signOut(ref, context);

                ref.read(loggedInProvider.notifier).state = false;
                ref.invalidate(authInitProvider);

                if (context.mounted) {
                  context.replace('/');
                }
              }, isLogout: true),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ================= NOT LOGIN =================
  Widget _buildNotLogin() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 10),
          const Text("Bạn chưa đăng nhập"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).go('/sign_in');
            },
            child: const Text("Đăng nhập"),
          ),
        ],
      ),
    );
  }

  // ================= SECTION =================
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  // ================= ITEM =================
  Widget _item(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.black),
      title: Text(
        title,
        style: TextStyle(color: isLogout ? Colors.red : Colors.black),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// ================= STAT ITEM =================
class _StatItem extends StatelessWidget {
  final String number;
  final String label;

  const _StatItem(this.number, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
