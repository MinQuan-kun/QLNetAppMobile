import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'home_screen.dart';
import '../Security.dart';

import '../../API/account_controller.dart';

class SettingScreen extends StatefulWidget {
  final int userID;

  const SettingScreen({super.key, required this.userID});

  @override
  State<StatefulWidget> createState() => _FormSetting();
}

class _SettingItem {
  final String label;
  final String? trailing;
  final Widget? route;

  _SettingItem(this.label, {this.trailing, this.route});
}

class _FormSetting extends State<SettingScreen> {
  final List<_SettingItem> settings = [
    _SettingItem("Quản Lý Tài Khoản", route: SecurityScreen()),
    _SettingItem("Thông báo trong ứng dụng"),
    _SettingItem("Thiết lập Push"),
    _SettingItem("Thiết Lập Hệ Thống"),
    _SettingItem("Phản Hồi"),
    _SettingItem("Quy Định Cộng Đồng"),
    _SettingItem("Thông tin ứng dụng"),
    _SettingItem("Xoá bộ nhớ đệm", trailing: "17,1 MB"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Thiết Lập'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        itemCount: settings.length,
        separatorBuilder: (_, __) => Divider(color: Colors.black),
        itemBuilder: (context, index) {
          final item = settings[index];
          return ListTile(
            title: Text(item.label, style: TextStyle(color: Colors.black)),
            trailing: item.trailing != null
                ? Text(item.trailing!, style: TextStyle(color: Colors.black))
                : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
            onTap: () {
              if (item.route != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.route!),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(userID: widget.userID),
                  ),
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final check = await AccountAPI.logout();
              if(!context.mounted) return;
              if (check == true) {
                currentAccount = null;
                logined = false;
                user = false;
                currentGuestName = null;
                isGuestLogin = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã đăng xuất!'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: Colors.blueAccent.shade100,
              elevation: 4,
              shadowColor: Colors.purpleAccent.shade100,
            ),
            child: Text(
              "Thoát đăng nhập",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
