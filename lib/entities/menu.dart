import 'dart:typed_data';
import 'dart:convert';

class Menu {
  final int foodID;
  final int? categoryID;
  final String foodName;
  final int foodPrice;
  final int quantity;
  final Uint8List? foodImage;
  final String? notes;

  Menu({
    required this.foodID,
    this.categoryID,
    required this.foodName,
    required this.foodPrice,
    required this.quantity,
    this.foodImage,
    this.notes,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      foodID: json['foodID'] ?? 0,
      categoryID: json['categoryID'],
      foodName: json['foodName'] ?? '',
      foodPrice: (json['foodPrice'] ?? 0).toInt(),
      quantity: json['quantity'] ?? 0,
      foodImage: json['foodImage'] != null
          ? base64Decode(json['foodImage'])
          : null,
      notes: json['notes'],
    );
  }
}
