import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'General/login_screen.dart';

class SecurityScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _FormSecurity();
}

String maskEmail(String? email) {
  if (email == null || !email.contains("@")) return "";
  var parts = email.split("@");
  var namePart = parts[0];
  if (namePart.length <= 2) return "***@${parts[1]}";
  return '${namePart.substring(0, 2)}***@${parts[1]}';
}

String maskPhone(String? phone) {
  if (phone == null || phone.length < 4) return "Chưa liên kết";
  return "${phone.substring(0, 3)}****${phone.substring(phone.length - 2)}";
}

String maskUsername(String username) {
  if (username.length <= 2) return "***";
  return "${username.substring(0, 1)}***${username.substring(username.length - 2)}";
}

class _FormSecurity extends State<SecurityScreen> {
  bool _showBanner = true;
  Timer? _bannerTimer;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _showVerificationBox = false;
  String _verificationType = "";
  TextEditingController _codeController = TextEditingController();



  @override
  void initState() {
    super.initState();
    _setupBannerTimer();
  }
  void _verifyAndContinue(String method, String type) async {
    String maskedEmail = maskEmail(currentAccount?.userEmail);
    TextEditingController _codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          titlePadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.all(16),
          actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Xác Nhận An Toàn", style: TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, color: Colors.grey),
              )
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bạn có thể dùng những cách sau để tiến hành xác nhận"),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: "Xác Nhận Hòm Thư",
                items: [
                  DropdownMenuItem(value: "Xác Nhận Hòm Thư", child: Text("Xác Nhận Hòm Thư")),
                ],
                onChanged: (_) {},
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Text("Nhấn để nhận mã xác nhận, thư xác nhận sẽ gửi về hòm thư của bạn."),
              const SizedBox(height: 4),
              Text(
                maskedEmail,
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        hintText: "Mã Xác Nhận",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Gửi mã xác nhận tới email thật
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Mã xác nhận đã gửi!")),
                      );
                    },
                    child: Text("Gửi"),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // TODO: kiểm tra mã xác nhận thật ở đây
                bool isCodeValid = _codeController.text == "123456"; // test tạm

                if (isCodeValid) {
                  Navigator.of(context).pop();
                  _showChangeDialog(type);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Mã xác nhận không đúng!")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text("Bước Tiếp Theo"),
            ),
          ],
        );
      },
    );
  }



  void _showChangeDialog(String type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          titlePadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.all(16),
          actionsPadding: const EdgeInsets.all(8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type == "email"
                    ? "Đổi Email"
                    : type == "phone"
                    ? "Liên Kết Số Điện Thoại"
                    : "Đổi Mật Khẩu",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: Colors.grey),
              )
            ],
          ),
          content: _buildDialogContent(type),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Hủy", style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () {
                // Xử lý
                if (type == "email") {
                  print("Email mới: ${_emailController.text}");
                } else if (type == "phone") {
                  print("SĐT mới: ${_phoneController.text}");
                } else if (type == "password") {
                  print("Mật khẩu cũ: ${_currentPasswordController.text}");
                  print("Mật khẩu mới: ${_newPasswordController.text}");
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Xác nhận"),
            )
          ],
        );
      },
    );
  }

  void _setupBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(Duration(minutes: 5), (_) {
      setState(() {
        _showBanner = true;
      });
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thiết lập an toàn tài khoản"),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          if (_showBanner)
            Container(
              height: 30,
              color: Colors.blue.shade100,
              child: Row(
                children: [
                  Expanded(
                    child: Marquee(
                      text:
                      ' Vui lòng cập nhật thông tin mỗi tháng 1 lần để bảo mật tài khoản tốt hơn!! ',
                      style: TextStyle(fontSize: 14),
                      velocity: 30.0,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _showBanner = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.tag_faces, color: Colors.white),
                  ),
                  title: Text("Tên Người Dùng"),
                  subtitle: Text(maskUsername(currentAccount?.userName ?? "")),
                  trailing: OutlinedButton(
                    onPressed: null,
                    child: Text("Đã Liên Kết"),
                  ),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.email, color: Colors.white),
                  ),
                  title: Text("Email"),
                  subtitle: Text(maskEmail(currentAccount?.userEmail)),
                  trailing: OutlinedButton(
                    onPressed: () {
                      _verifyAndContinue("email", "email");
                    },
                    child: Text("Đổi Liên Kết"),
                  ),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.phone, color: Colors.white),
                  ),
                  title: Text("Số điện thoại"),
                  subtitle: Text(currentAccount?.userPhone == null
                      ? "Chưa liên kết"
                      : maskPhone(currentAccount?.userPhone)),
                  trailing: OutlinedButton(
                    onPressed: () {
                      _showChangeDialog("phone");
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                    child: const Text("Hủy Liên Kết"),
                  ),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                  title: Text("Đổi Mật Khẩu"),
                  trailing: OutlinedButton(
                    onPressed: () {
                      _showChangeDialog("password");
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                    child: const Text("Đổi"),
                  ),

                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(child: Text("Xóa Tài Khoản")),
                      OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                titlePadding: EdgeInsets.only(left: 16, right: 16, top: 16),
                                contentPadding: EdgeInsets.all(16),
                                actionsPadding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Xoá Tài Khoản",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: Icon(Icons.close, color: Colors.grey),
                                    )
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Sau khi hoàn thành xoá, tài khoản của bạn sẽ bị xoá bỏ, hãy thao tác thận trọng.",
                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      "Xin được thông báo rằng sau khi hoàn tất quy trình xoá, dữ liệu tài khoản của bạn và dữ liệu sử dụng được tạo ra sau khi đăng nhập vào sản phẩm thông qua tài khoản này, "
                                          "sẽ bị xoá vĩnh viễn và không thể khôi phục, vui lòng lựa chọn và thao tác thận trọng.",
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Hủy", style: TextStyle(color: Colors.blue)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: chức năng xóa tài khoản
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    child: Text("Tiếp"),
                                  )
                                ],
                              );
                            },
                          );
                        },
                        child: Text("Yêu Cầu Xóa"),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildFooterButton("Điều Khoản Dịch Vụ", () {}),
                          _verticalDivider(),
                          _buildFooterButton("Chính Sách Quyền Riêng Tư", () {}),
                          _verticalDivider(),
                          _buildFooterButton("FAQ", () {}),
                          _verticalDivider(),
                          _buildFooterButton("Liên Hệ CSKH", () {}),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Copyright © . All Rights Reserved.",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );

  }
  Widget _buildFooterButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(Colors.grey),
        overlayColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.2)),
      ),
      child: SizedBox(
        width: 66,
        child: Text(
          text,
          textAlign: TextAlign.center,
          softWrap: true,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 35,
      width: 1,
      color: Colors.grey,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _buildDialogContent(String type) {
    if (type == "email") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Nhập email mới:"),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      );
    } else if (type == "phone") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Nhập số điện thoại mới:"),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
          ),
        ],
      );
    } else if (type == "password") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Nhập mật khẩu hiện tại:"),
          const SizedBox(height: 8),
          TextField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          const Text("Nhập mật khẩu mới:"),
          const SizedBox(height: 8),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

