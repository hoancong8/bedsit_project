import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thuetro/provider/home_provider.dart';

class ItemPost extends ConsumerStatefulWidget {
  String? imageUrl, title, price, location, time, area,id;
  bool? favourite;

  ItemPost({
    super.key,
    this.price,
    this.title,
    this.location,
    this.imageUrl,
    this.time,
    this.area,
    this.favourite,
    this.id
  });

  @override
  ConsumerState createState() => _ItemPostState();
}

class _ItemPostState extends ConsumerState<ItemPost> {
  bool checkFavourite =false;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12),bottom: Radius.circular(12)),
                child: Image.network(
                  widget.imageUrl ?? "https://tse3.mm.bing.net/th/id/OIP.0eDamzEphB4k1QjbE9jAHwHaE7?pid=Api&P=0&h=180",
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                child: Text(
                  widget.time ?? "",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              Positioned(top:0,right: 0,child: IconButton(onPressed: () async {


                final prefs = await SharedPreferences.getInstance();
                final checkLogin = prefs.getBool("status_login");

                // if (uid == null) return;
                if(checkLogin??false){
                  setState(() => checkFavourite = !checkFavourite);
                  await toggleFavourite(widget.id!, checkFavourite);
                  print("vẫn đc :)))))");
                }
                else{
                  print("ok !!!!!!!!!");
                }

              },
                  icon: checkFavourite?Icon(Icons.favorite_outlined,color: Colors.red,):Icon(Icons.favorite_outline))),
            ],
          ),


          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.price ?? "",
                      style: const TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    Text(
                      "${widget.area??"120"} m²" ?? "",
                      style: const TextStyle(
                        color: Colors.grey,
                        // fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.location ?? "",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Text(
                  widget.time ?? "",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
