import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thuetro/provider/favourite_provider.dart';
import 'package:thuetro/provider/home_provider.dart';

class ItemPost extends ConsumerWidget {
  final String? imageUrl, title, price, location, time, area, id;

  const ItemPost({
    super.key,
    this.price,
    this.title,
    this.location,
    this.imageUrl,
    this.time,
    this.area,
    this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userFavourites = ref.watch(userFavouritesProvider);

    return userFavourites.when(
      data: (favs) {
        final isFav = favs.contains(id);

        return Container(
          width: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12), bottom: Radius.circular(12)),
                    child: Image.network(
                      imageUrl ??
                          "https://tse3.mm.bing.net/th/id/OIP.0eDamzEphB4k1QjbE9jAHwHaE7?pid=Api&P=0&h=180",
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final checkLogin = prefs.getBool("status_login");

                        if (checkLogin ?? false) {
                          if (isFav) {
                            await ref.read(removeFavourite(id).future);
                          } else {
                            await ref.read(addFavourite(id).future);
                          }

                          // làm mới lại danh sách yêu thích
                          ref.invalidate(userFavouritesProvider);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Vui lòng đăng nhập trước!")),
                          );
                        }
                      },
                      icon: Icon(
                        isFav
                            ? Icons.favorite_outlined
                            : Icons.favorite_outline,
                        color: isFav ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(price ?? "",
                            style: const TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text("${area ?? '120'} m²",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(location ?? "",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(time ?? "",
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Lỗi: $e'),
    );
  }
}
