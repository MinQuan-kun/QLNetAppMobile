class ServiceDetail {
  final int detailID;
  final int? serviceID;
  final int serviceType;
  final int? computerID;
  final int? foodID;
  final int quantity;
  final double price;
  final DateTime? startTime;
  final DateTime? endTime;
  final double totalPrice;
  final int totalReceived;

  ServiceDetail({
    required this.detailID,
    this.serviceID,
    required this.serviceType,
    this.computerID,
    this.foodID,
    required this.quantity,
    required this.price,
    this.startTime,
    this.endTime,
    required this.totalPrice,
    required this.totalReceived
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      detailID: json['detailID'] as int,
      serviceID: json['serviceID'] as int?,
      serviceType: (json['serviceType'] as int),
      computerID: json['computerID'] as int?,
      foodID: json['foodID'] as int?,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      totalReceived: (json['totalReceived'] as num).toInt()
    );
  }
}
