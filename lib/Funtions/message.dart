import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../entities/message.dart';

class ChatDialog extends StatefulWidget {
  final int userId;
  final String senderName;
  final List<String> initialMessages;

  const ChatDialog({
    super.key,
    required this.userId,
    required this.senderName,
    this.initialMessages = const [],
  });

  @override
  State<ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  String? selectedReceiver;
  List<String> messages = [];
  List<String> availableUsers = [];

  @override
  void initState() {
    super.initState();
    messages = List.from(widget.initialMessages);

    fetchUsers();
  }

  void fetchUsers() async {
    try {
      final list = await GetListAdmin.fetchListAdmin();
      if (list.isNotEmpty) {
        setState(() {
          availableUsers = list;
          selectedReceiver = availableUsers.first;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải danh sách người nhận: $e');
      // fallback nếu api lỗi
      setState(() {
        availableUsers = ['Admin1', 'Staff1'];
        selectedReceiver = availableUsers.first;
      });
    }
  }

  void sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || selectedReceiver == null) return;

    setState(() {
      messages.add("${widget.senderName}: $text");
      _messageController.clear();
    });

    // TODO: Gọi api gửi tin nhắn tới selectedReceiver
    debugPrint("Gửi '$text' tới $selectedReceiver");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 400,
        child: Column(
          children: [
            // Header chọn người nhận
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    "Người nhận: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedReceiver,
                      isExpanded: true,
                      items: availableUsers
                          .map(
                            (user) => DropdownMenuItem(
                              value: user,
                              child: Text(user),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedReceiver = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            Divider(),

            // Hộp thoại tin nhắn
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: messages.length,
                itemBuilder: (_, index) => Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  margin: EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: messages[index].startsWith(widget.senderName)
                        ? Colors.blue.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(messages[index]),
                ),
              ),
            ),

            Divider(),

            // Input gửi tin nhắn
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
                  ElevatedButton(onPressed: sendMessage, child: Text("Gửi")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GetListAdmin {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:39553',
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  static Future<List<String>> fetchListAdmin() async {
    try {
      final response = await _dio.get('/api/mess/getlistadmin');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data['data'];
        return jsonList.map((e) => e.toString()).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Không thể tải danh sách admin: $e');
    }
  }
}

class GetMessages {
  static final _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:39553'));

  static Future<List<Message>> fetchConversation(
    int senderId,
    int receiverId,
  ) async {
    final response = await _dio.post(
      '/api/mess/getconversation',
      data: {"SendID": senderId, "ReceiverID": receiverId},
    );

    final List<dynamic> jsonList = response.data['data'];
    return jsonList.map((e) => Message.fromJson(e)).toList();
  }
}
