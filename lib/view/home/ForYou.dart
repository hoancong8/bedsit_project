import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thuetro/provider/history_provider.dart';

import '../../provider/home_provider.dart';
import '../../utils/utils.dart';
import 'ItemPost/item_post_vertical.dart';

class Foryou extends ConsumerStatefulWidget {
  const Foryou({super.key});

  @override
  ConsumerState createState() => _ForyouState();
}

class _ForyouState extends ConsumerState<Foryou> {

  @override
  Widget build(BuildContext context) {
    var post =  ref.watch(selectPostProvider);
    return post
        .when(
      data: (data) {
        return RefreshIndicator(
          onRefresh: () async {
            // gọi lại provider hoặc API để load dữ liệu mới
            ref.refresh(selectPostProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverGrid(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate((
                      ctx,
                      index,
                      ) {
                    final post = data[index];

                    final imageUrl =
                    (post["images"] != null &&
                        post["images"].isNotEmpty)
                        ? post["images"][0]
                        : null;

                    return InkWell(
                      onTap: () {
                        ref.read(addHistory(post["id"]));
                        GoRouter.of(
                          context,
                        ).push('/detail', extra: post);
                      },
                      child: ItemPost(
                        imageUrl: imageUrl,
                        title: post["title"]?.toString(),
                        price: formatMoneyVND(post["price"]),
                        location: post["address"]?.toString(),
                        time: timeAgo(post["created_at"]),
                        id: post["id"].toString(),
                        area: post["area"].toString(),
                      ),
                    );
                  }, childCount: data.length),
                ),
              ),
            ],
          ),
        );
      },
      error: (err, stack) => Center(child: Text("Lỗi: $err")),
      loading: () =>
      const Center(child: CircularProgressIndicator()),
    );
  }
}
