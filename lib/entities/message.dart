class Message {
  final int messageID;
  final int sendID;
  final int receiverID;
  final String? senderName;
  final String? receiverName;
  final DateTime sendAt;
  final String messageContent;
  final bool status;

  Message({
    required this.messageID,
    required this.sendID,
    required this.receiverID,
    required this.senderName,
    required this.receiverName,
    required this.sendAt,
    required this.messageContent,
    required this.status,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageID: json['messageID'] ?? 0,
      sendID: json['sendID'] ?? 0,
      receiverID: json['receiverID'] ?? 0,
      senderName: json['senderName'] ?? "",
      receiverName: json['receiverName'] ?? "",
      sendAt: DateTime.tryParse(json['sendAt'].toString()) ?? DateTime.now(),
      messageContent: json['messageContent'] ?? "",
      status: json['status'] ?? false,
    );
  }
}
