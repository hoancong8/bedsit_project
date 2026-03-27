import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:thuetro/view/account.dart';
import 'package:thuetro/view/chat.dart';
import 'package:thuetro/view/home/home.dart';
import 'manager_post_page/manager_post.dart';

import '../provider/auth_provider.dart';
import '../provider/chat_provider.dart';
import '../provider/home_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  int _selectedScreenIndex = 0;

  final List<Map<String, dynamic>> _screens = [
    {"screen": const Home()},
    {"screen": const ManagerPost()},
    {"screen": const Chat()},
    {"screen": const Account()},
  ];

  void _selectScreen(int index) {
    if (index == 2) {
      ref.invalidate(listRoomsProvider);
    } else if (index == 0) {
      ref.invalidate(selectPostProvider);
    }

    setState(() {
      _selectedScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // ================= BODY =================
      body: IndexedStack(
        index: _selectedScreenIndex,
        children: _screens.map((e) => e["screen"] as Widget).toList(),
      ),

      // ================= FLOAT BTN =================
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 10),
        child: SizedBox(
          height: 60,
          width: 60,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            elevation: 6,
            backgroundColor: Colors.orange,
            onPressed: () async {
              final result = await ref.read(authInitProvider.future);
              if (result) {
                GoRouter.of(context).push("/post");
              } else {
                GoRouter.of(context).push("/sign_in");
              }
            },
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ================= BOTTOM BAR =================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20), 
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 12,
            elevation: 100,
            color: Colors.white,
            child: SizedBox(
              height: 65,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _item(0, Icons.home_outlined, "Trang chủ"),
                      _item(1, Icons.description_outlined, "Quản lý"),
                    ],
                  ),

                  Row(
                    children: [
                      _item(2, Icons.chat_bubble_outline, "Chat"),
                      _item(3, Icons.person_outline, "Tài khoản"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= ITEM =================
  Widget _item(int index, IconData icon, String label) {
    final isActive = _selectedScreenIndex == index;

    return InkWell(
      onTap: () => _selectScreen(index),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isActive ? Colors.blue : Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.blue : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
