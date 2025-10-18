import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/filter.dart';

final supabase = Supabase.instance.client;

//save filter on provider
final filterParamsProvider = StateProvider<FilterParams>((ref) {
  return FilterParams(
    minPrice: null,
    maxPrice: null,
    minArea: null,
    maxArea: null,
    selectedFurniture: null,
  );
});

//filter by price,area,status interior
final filteredPostsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final params = ref.watch(filterParamsProvider);
    var query = supabase.from('post').select();
    if (params.minPrice != null) query = query.gte('price', params.minPrice??0);
    if (params.maxPrice != null) query = query.lte('price', params.maxPrice??0);
    if (params.minArea != null) query = query.gte('area', params.minArea??0);
    if (params.maxArea != null) query = query.lte('area', params.maxArea??0);
    if (params.selectedFurniture != null && params.selectedFurniture!.isNotEmpty) {
      query = query.ilike('status', params.selectedFurniture??"status");
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print("Lỗi ở search_provider: $e");
    return [];
  }
});
