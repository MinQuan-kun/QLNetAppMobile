import 'package:flutter/material.dart';

import '../../Funtions/message.dart';

import '../../widget/button_custom.dart';
import '../../widget/appbar_custom.dart';
import '../../widget/bottomnavigator_custom.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userID;
  final String? guestName;

  const HomeScreen({super.key, required this.userID, this.guestName});

  @override
  State<StatefulWidget> createState() => _FormHome();
}

class _FormHome extends State<HomeScreen> {
  final _homeKey = GlobalKey<FormState>();
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(
        selectedIndex: selectedTab,
        onTabSelected: (i) => setState(() => selectedTab = i),
        tabs: const [
          TabItem(label: "Trang chủ", icon: Icons.home),
          TabItem(label: "Sự kiện", icon: Icons.event),
        ],
      ),
      body: Column(
        key: _homeKey,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 👉 Nội dung theo tab
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selectedTab == 0 ? Icons.home : Icons.event,
                    size: 80,
                    color: Colors.lightBlueAccent,
                  ),
                  SizedBox(height: 20),
                  Text(
                    selectedTab == 0
                        ? 'Chào mừng bạn đến với Trang Chủ!'
                        : 'Sự kiện đang được cập nhật...',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: (currentAccount?.userRole == "User")
          ? FloatingButtonCustom(
              onPressed: () {
                final senderName =
                    currentAccount?.userDisplayName?.isNotEmpty == true
                    ? currentAccount!.userDisplayName!
                    : (currentAccount?.userName ?? "");
                final userId = currentAccount?.idUser ?? 0;

                showDialog(
                  context: context,
                  builder: (_) => ChatDialog(
                    userId: userId,
                    senderName: senderName,
                    initialMessages: [],
                  ),
                );
              },
              avatar: AssetImage("Img/Headset.png"),
              size: 45,
            )
          : null,
      bottomNavigationBar: buildBottomNavigationBar(context, 0),
    );
  }
}
