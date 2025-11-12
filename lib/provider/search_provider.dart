import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/filter.dart';

final supabase = Supabase.instance.client;

// lưu filter trên provider
final filterParamsProvider = StateProvider<FilterParams>((ref) {
  return FilterParams(
    minPrice: null,
    maxPrice: null,
    minArea: null,
    maxArea: null,
    selectedFurniture: null,
  );
});

// lưu search text trên provider
final searchTextProvider = StateProvider<String?>((ref) => null);

// Kết hợp filter + tìm kiếm chữ
final filteredPostsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final params = ref.watch(filterParamsProvider);
    final searchText = ref.watch(searchTextProvider);

    var query = supabase.from('post').select();

    // lọc theo giá
    if (params.minPrice != null) query = query.gte('price', params.minPrice ?? 0);
    if (params.maxPrice != null) query = query.lte('price', params.maxPrice ?? 10000000);

    // lọc theo diện tích
    if (params.minArea != null) query = query.gte('area', params.minArea ?? 0);
    if (params.maxArea != null) query = query.lte('area', params.maxArea ?? 10000000);

    // lọc theo nội thất
    if (params.selectedFurniture != null && params.selectedFurniture!.isNotEmpty) {
      query = query.ilike('status', params.selectedFurniture!);
    }

    // tìm kiếm theo title hoặc address
    if (searchText != null && searchText.isNotEmpty) {
      query = query.or('title.ilike.%$searchText%,address.ilike.%$searchText%');
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print("Lỗi ở filteredPostsProvider: $e");
    return [];
  }
});
