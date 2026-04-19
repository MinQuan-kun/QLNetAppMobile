class Import {
  final int importId;
  final int? staffId;
  final int? foodId;
  final int? categoryId;
  final int quantum;
  final int sumprice;
  final DateTime importDate;

  Import({
    required this.importId,
    required this.quantum,
    required this.sumprice,
    required this.importDate,
    this.staffId,
    this.foodId,
    this.categoryId
  });

  factory Import.fromJson(Map<String, dynamic> json) {
    return Import(
      importId: json['importID'],
      staffId: json['staffID'],
      foodId: json['foodID'],
      quantum: json['quantum'],
      sumprice: json['sumPrice'],
      importDate: json['importDate'],
      categoryId: json['categoryID'],
    );
  }
}
