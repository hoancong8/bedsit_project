import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class ItemPostHorizontal extends ConsumerStatefulWidget {
  String? imageUrl, title, price, location, time;

  ItemPostHorizontal({
    super.key,
    this.price,
    this.title,
    this.location,
    this.imageUrl,
    this.time,
  });

  @override
  ConsumerState createState() => _ItemPostHorizontalState();
}

class _ItemPostHorizontalState extends ConsumerState<ItemPostHorizontal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.fromLTRB(0,12, 0, 0),
      // margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
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
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh sản phẩm
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12),bottom: Radius.circular(12)),
            child: Image.network(
              widget.imageUrl ?? "https://tse3.mm.bing.net/th/id/OIP.0eDamzEphB4k1QjbE9jAHwHaE7?pid=Api&P=0&h=180",
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),

          // Nội dung
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                // mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title ?? "tiêu đề trống",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.price ?? "giá trống",
                    style: const TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.location ?? "địa chị trống",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Text(
                    widget.time ?? "thời gian trống",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
