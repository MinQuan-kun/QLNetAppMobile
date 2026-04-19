import 'package:flutter/material.dart';

import '../../entities/message.dart';

class ChatDialog extends StatefulWidget {
  final int currentId; // ID người gửi
  final int receiverId; // ID người nhận
  final String senderName;
  final String receiverName;
  final List<Message> initialMessages;

  const ChatDialog({
    super.key,
    required this.currentId,
    required this.receiverId,
    required this.senderName,
    required this.receiverName,
    this.initialMessages = const [],
  });

  @override
  State<StatefulWidget> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    messages = List.from(widget.initialMessages);
  }

  // void sendMessage() {
  //   final text = _messageController.text.trim();
  //   if (text.isEmpty) return;
  //
  //   setState(() {
  //     messages.add("${widget.senderName}: $text");
  //     _messageController.clear();
  //   });
  //
  //   // TODO: Gọi api gửi tin nhắn đến receiverId
  //   debugPrint("Gửi '$text' từ ${widget.currentId} tới ${widget.receiverId}");
  // }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 400,
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Chat với ${widget.receiverName}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Divider(),

            // List tin nhắn
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: messages.length,
                itemBuilder: (_, index) {
                  final msg = messages[index];
                  final isSender = msg.sendID == widget.currentId;

                  // Format thời gian
                  final timeString =
                      "${msg.sendAt.hour.toString().padLeft(2, '0')}:${msg.sendAt.minute.toString().padLeft(2, '0')} ${msg.sendAt.day.toString().padLeft(2, '0')}/${msg.sendAt.month.toString().padLeft(2, '0')}/${msg.sendAt.year}";

                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    margin: EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: isSender
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: isSender
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${msg.senderName ?? 'Người lạ'}: ${msg.messageContent}",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Text(
                          timeString,
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Divider(),

            // Input
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Nhập tin nhắn...",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      //TODO: Gọi API GỬI TIN NHẮN
                    },
                    child: Text("Gửi"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Cách gọi:
void showChatDialog(
  BuildContext context,
  int currentId,
  String senderName,
  int receiverId,
  String receiverName,
) {
  showDialog(
    context: context,
    builder: (_) => ChatDialog(
      currentId: currentId,
      receiverId: receiverId,
      senderName: senderName,
      receiverName: receiverName,
    ),
  );
}
