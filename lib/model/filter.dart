class FilterParams {
  final double? minPrice;
  final double? maxPrice;
  final double? minArea;
  final double? maxArea;
  final String? selectedFurniture;

  FilterParams({
    this.minPrice,
    this.maxPrice,
    this.minArea,
    this.maxArea,
    this.selectedFurniture,
  });

  FilterParams copyWith({
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    String? selectedFurniture,
  }) {
    return FilterParams(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      selectedFurniture: selectedFurniture ?? this.selectedFurniture,
    );
  }
}
