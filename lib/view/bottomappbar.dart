import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thuetro/view/account.dart';
import 'package:thuetro/view/chat.dart';
import 'package:thuetro/view/home/home.dart';

import '../provider/auth_provider.dart';
import '../provider/chat_provider.dart';
import '../provider/home_provider.dart';
import 'manager_post_page/manager_post.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Hide the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Thuê trọ ',
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
    {"screen": const Home(), "title": "Screen A Title"},
    {"screen": const ManagerPost(), "title": "Screen B Title"},
    {"screen": const Chat(), "title": "Screen B Title"},
    {"screen": const Account(), "title": "Screen B Title"},
  ];

  void _selectScreen(int index) {
    if(index==2){
      ref.invalidate(listRoomsProvider);
    }
    else if(index==0){
      ref.invalidate(selectPostProvider);
    }

    setState(() {
      _selectedScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text(_screens[_selectedScreenIndex]["title"])),

      body: IndexedStack(
        index: _selectedScreenIndex,
        children: _screens.map((e) => e["screen"] as Widget).toList(),
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          const SizedBox(height: 25),
          SizedBox(
            height: 45,
            child: FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: () async {
                final result = await ref.read(authInitProvider.future);
                if(result){
                  GoRouter.of(context).push("/post");
                }
                else{
                  GoRouter.of(context).push("/sign_in");
                }
              },
              child: const Icon(Icons.add),
            ),
          ),
          const SizedBox(height: 4),
          const Text("Đăng tin", style: TextStyle(fontSize: 12)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: SizedBox(
        height: 50,
        child: BottomAppBar(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                iconItemBottomAppbar(
                  _selectedScreenIndex,
                  () {
                    _selectScreen(0);
                  },
                  0,
                  Icons.home_outlined,
                  "Trang chủ",
                ),
                // chừa chỗ cho nút giữa
                iconItemBottomAppbar(
                  _selectedScreenIndex,
                  () {
                    _selectScreen(1);
                  },
                  1,
                  Icons.discount_outlined,
                  "Quản lí tin",
                ),

                const SizedBox(width: 60),
                iconItemBottomAppbar(
                  _selectedScreenIndex,
                  () {
                    _selectScreen(2);
                  },
                  2,
                  Icons.chat,
                  "Chat",
                ),
                iconItemBottomAppbar(
                  _selectedScreenIndex,
                  () {
                    _selectScreen(3);
                  },
                  3,
                  Icons.person,
                  "Tài khoản",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



Widget iconItemBottomAppbar(
  int index,
  VoidCallback onTap,
  int currentIndex,
  IconData icon,
  String nameItem,
) {
  return InkWell(
    onTap: () {
      onTap();
    },
    child: SizedBox(
      width: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: index == currentIndex ? Colors.blue : Colors.grey),
          Text(
            nameItem,
            style: TextStyle(
              fontSize: 12,
              height: 1.0,
              color: index == currentIndex ? Colors.blue : Colors.grey,
            ), // height=1 để text dính hơn
          ),
        ],
      ),
    ),
  );
}
