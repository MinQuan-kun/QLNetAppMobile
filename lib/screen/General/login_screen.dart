import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';

import '../../token_service.dart';
import 'home_screen.dart';
import 'guest_screen.dart';

import '../../entities/user_account.dart';

import '../../api/account_controller.dart';

bool user = false;
String? currentGuestName;
bool isGuestLogin = false;
Accounts? currentAccount;
bool logined = false;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _FormLogin();
}

String md5Hash(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

class _FormLogin extends State<LoginScreen> {
  bool agreeTerms = false;
  bool agreePrivacy = false;
  bool _obscurePassword = true;
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _loginkey = GlobalKey<FormState>();

  Future<void> handleLogin(BuildContext context) async {
    try {
      String hashedPassword = md5Hash(_passwordController.text);
      // showLoading(context);

      // 1. Login → lấy token
      final result = await AccountAPI.loginUser(
        username: _usernameController.text,
        password: hashedPassword,
      );

      if (result != null && result['token'] != null) {
        await StorageService.saveToken(result['token']);
      }

      logined = true;
      // hideLoading(context);

      // 2. Lấy thông tin user hiện tại
      currentAccount = await AccountAPI.infor();
      if (!context.mounted) return;
      if (currentAccount != null) {
        int userID = currentAccount!.idUser;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(userID: userID)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không lấy được thông tin người dùng')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      final errorMsg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _loginkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Nút đóng
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.close, size: 28),
                    onPressed: () {
                      if (Platform.isAndroid) {
                        SystemNavigator.pop();
                      } else if (Platform.isIOS) {
                        exit(0);
                      }
                    },
                  ),
                ),
                Image.asset(
                  'Img/Logo2.png',
                  height: 200,
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                ),
                // Tiêu đề
                Text(
                  "Vui lòng đăng nhập tài khoản",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: "Tên người dùng",
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSaved: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Vui lòng nhập tên tài khoản";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 12),
                // Ô nhập mật khẩu
                TextFormField(
                  controller: _passwordController,
                  autocorrect: false,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Mật khẩu",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSaved: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Hãy nhập mật khẩu";
                    }
                    if (value.length < 5) return "Mật khẩu không hợp lệ";
                    return null;
                  },
                ),
                SizedBox(height: 12),
                // Checkbox điều khoản
                CheckboxListTile(
                  value: agreeTerms,
                  onChanged: (v) => setState(() => agreeTerms = v ?? false),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(text: "Đã đọc và đồng ý với "),
                        TextSpan(
                          text: "Điều Khoản Dịch Vụ Của Forums",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  value: agreePrivacy,
                  onChanged: (v) => setState(() => agreePrivacy = v ?? false),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                          text:
                              "Đồng ý cho phép thu thập và sử dụng thông tin cá nhân theo ",
                        ),
                        TextSpan(
                          text: "Chính Sách Bảo Mật Của Forums",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: 8),
                // // Nút đăng nhập
                ElevatedButton(
                  onPressed: agreeTerms && agreePrivacy
                      ? () {
                          if (_loginkey.currentState!.validate()) {
                            _loginkey.currentState!.save();
                            md5Hash(_passwordController.text);
                            user = true;
                            handleLogin(context);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.grey[agreeTerms && agreePrivacy ? 800 : 300],
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Đăng Nhập",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(height: 12),
                // Liên kết
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuestScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Đăng nhập tư cách khách",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    // TextButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => RegisterEmailScreen(),
                    //       ),
                    //     );
                    //   },
                    //   child: Text(
                    //     "Đăng Ký Ngay",
                    //     style: TextStyle(color: Colors.blue),
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: 20),
                // Hoặc đăng nhập
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("Hoặc đăng nhập bằng cách sau"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 12),
                // Nút mạng xã hội
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(Icons.mail, Colors.black),
                    SizedBox(width: 16),
                    _socialButton(Icons.facebook, Colors.blue),
                    SizedBox(width: 16),
                    _socialButton(Icons.clear, Colors.black),
                    // icon X (Twitter)
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, color: Colors.white),
    );
  }
}
