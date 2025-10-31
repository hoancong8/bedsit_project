import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thuetro/model/account.dart';
import 'package:thuetro/model/post.dart';
import 'package:thuetro/utils/utils.dart';
import 'package:thuetro/view/home/ForYou.dart';
import 'package:thuetro/view/home/ItemPost/item_post_vertical.dart';
import '../../provider/home_provider.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  bool _collapsed = false;
  AccountUsers? user;
  final ScrollController _scrollController = ScrollController();
  String? url;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      final newCollapsed = offset > 110;
      if (newCollapsed != _collapsed) {
        setState(() => _collapsed = newCollapsed);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                expandedHeight: 250,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 160,
                        decoration: const BoxDecoration(
                          color: Colors.amberAccent,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: Row(
                                children: [
                                  ref
                                      .watch(loadAvatar)
                                      .when(
                                        data: (data) {
                                          return Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(48),
                                                child: Container(
                                                  width: 45,
                                                  height: 45,
                                                  color: Colors.blue,
                                                  child: Image.network(
                                                    data.avt ??
                                                        "https://tse3.mm.bing.net/th/id/OIP.0eDamzEphB4k1QjbE9jAHwHaE7?pid=Api&P=0&h=180",
                                                    fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Icon(Icons.person_outlined);
                                                  },),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data.fullName!=null?"Xin chào ${data.fullName}":"khách",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Bạn muốn thuê trọ như nào?",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                        error: (err, stack) =>
                                            Center(child: Text("Lỗi: $err")),
                                        loading: () => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.headphones_outlined),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.notifications_outlined,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 125,
                        right: 10,
                        left: 10,
                        child: InkWell(
                          onTap: () {
                            GoRouter.of(context).push("/search");
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Tìm trọ ..."),
                                  Icon(Icons.search_outlined),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Column(
                    children: [
                      if (_collapsed)
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            ref.watch(loadAvatar).when(data: (data){
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(48),
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  color: Colors.blue,
                                  child: Image.network(
                                    data.avt ??
                                        "https://tse3.mm.bing.net/th/id/OIP.0eDamzEphB4k1QjbE9jAHwHaE7?pid=Api&P=0&h=180",
                                    fit: BoxFit.cover,errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.person_outlined);
                                    },
                                  ),
                                ),
                              );
                            }, error: (err, stack) =>
                                Center(child: Text("Lỗi: $err")),
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: (){
                                  GoRouter.of(context).push("/search");
                                },
                                child: Container(
                                  height: 45,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Tìm trọ ..."),
                                        Icon(Icons.search_outlined),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.headphones_outlined),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.notifications_outlined),
                            ),
                          ],
                        ),
                      const TabBar(
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.black54,
                        tabs: [
                          Tab(text: "Dành cho bạn"),
                          Tab(text: "Gần bạn"),
                          Tab(text: "Mới nhất"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              Foryou(),
              const Center(child: Text("Nội dung Tab 2")),
              const Center(child: Text("Nội dung Tab 3")),
            ],
          ),
        ),
      ),
    );
  }
}
