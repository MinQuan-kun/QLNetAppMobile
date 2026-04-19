class Computer {
  final int idComputer;
  final String computerName;
  final int? idUser;
  final String? username;
  final String? computerIP;
  final String? computerMac;
  final String description;
  final DateTime? useStartTime;
  final DateTime? useEndTime;
  bool computerStatus;

  Computer({
    required this.idComputer,
    required this.computerName,
    this.idUser,
    this.username,
    this.computerIP,
    this.computerMac,
    required this.description,
    this.useStartTime,
    this.useEndTime,
    required this.computerStatus,
  });

  factory Computer.fromJson(Map<String, dynamic> json) {
    return Computer(
      idComputer: json['computerID'],
      idUser: json['userID'],
      username: json['userName'] as String?,
      computerName: json['computerName'] ?? '',
      computerIP: json['computerIP'] as String?,
      computerMac: json['computerMac'] as String?,
      description: json['computerDescription'] ?? '',
      useStartTime: json['useStartTime'] != null
          ? DateTime.parse(json['useStartTime'])
          : null,
      useEndTime: json['useEndTime'] != null
          ? DateTime.parse(json['useEndTime'])
          : null,
      computerStatus:
      json['computerStatus'] == 1 || json['computerStatus'] == true,
    );
  }
}
