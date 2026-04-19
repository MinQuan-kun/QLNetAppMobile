class Service {
  final int serviceID;
  final int? userID;
  final String? guestName;
  final int? staffID;
  final double billTotalAmount;
  final DateTime billCreatedAt;
  final String billStatus;
  final String serviceStatus;

  Service({
    required this.serviceID,
    this.userID,
    this.guestName,
    this.staffID,
    required this.billTotalAmount,
    required this.billCreatedAt,
    required this.billStatus,
    required this.serviceStatus,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceID: json['serviceID'] as int,
      userID: json['userID'] as int?,
      guestName: json['guestName'] as String?,
      staffID: json['staffID'] as int?,
      billTotalAmount: (json['billTotalAmount'] as num?)?.toDouble() ?? 0.0,
      billCreatedAt: DateTime.parse(json['billCreatedAt']),
      billStatus: json['billStatus'] as String,
      serviceStatus: json['serviceStatus'] as String,
    );
  }
}
