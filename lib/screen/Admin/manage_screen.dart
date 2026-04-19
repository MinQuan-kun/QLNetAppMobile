import 'package:flutter/material.dart';


import 'userlist_screen.dart';
import 'manageservice_screen.dart';
import 'statistic_screen.dart';

import '../../widget/button_custom.dart';
import '../../widget/bottomnavigator_custom.dart';

class ManageScreen extends StatefulWidget {
  final int userId;

  const ManageScreen({super.key, required this.userId});

  @override
  State<StatefulWidget> createState() => _FormManage();
}

class _FormManage extends State<ManageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Quản lý hệ thống",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Quản lý tài khoản
            InkWellCustom(
              title: "Quản lý tài khoản",
              iconPath: "Img/User.png",
              color: Colors.blueAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserListScreen(userId: widget.userId),
                  ),
                );
              },
            ),

            SizedBox(height: 20),
            // Quản lý dịch vụ
            InkWellCustom(
              title: "Quản lý dịch vụ",
              iconPath: "Img/Check Dollar.png",
              color: Colors.orangeAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ManageServiceScreen(userID: widget.userId),
                  ),
                );
              },
            ),

            SizedBox(height: 20),
            // Thống kê doanh thu
            InkWellCustom(
              title: "Thống kê doanh thu",
              iconPath: "Img/Analytics.png",
              color: Colors.greenAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StatisticScreen(userID: widget.userId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, 2),
    );
  }
}
