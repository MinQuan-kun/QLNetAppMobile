import 'package:flutter/material.dart';
import '../../api/account_controller.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';


class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountForm();
}

class _CreateAccountForm extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool isUpdated = false;

  bool _obscurePassword = true;
  String _role = "User";
  String _gender = "Khác";
  String? _errorMessage;

  String md5Hash(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  void onUpdate() {
    setState(() {
      isUpdated = true;
    });
  }

  Future<void> _handleRegister(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameCtrl.text.trim();
    final password = md5Hash(_passwordCtrl.text.trim());
    final phone = _phoneCtrl.text.trim();

    final message = await AccountAPI.createAccount(
      username: username,
      password: password,
      phone: phone,
      role: _role,
      gender: _gender,
    );

    if (!mounted) return;

    if (message.contains("thành công")) {
      setState(() => _errorMessage = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      onUpdate();
    } else {
      setState(() => _errorMessage = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Đăng ký"),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context, isUpdated),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                ],
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: InputDecoration(
                    hintText: "Tên đăng nhập",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Nhập tên đăng nhập";
                    }
                    if (val.length < 4) {
                      return "Tên đăng nhập phải ≥ 4 ký tự";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
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
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Nhập mật khẩu";
                    }
                    if (val.length < 6) {
                      return "Mật khẩu phải ≥ 6 ký tự";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Số điện thoại",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Nhập số điện thoại";
                    }
                    final regex = RegExp(r'^[0-9]{9,11}$');
                    if (!regex.hasMatch(val)) {
                      return "Số điện thoại không hợp lệ";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Gender
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Nam"),
                        value: "Nam",
                        groupValue: _gender,
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Nữ"),
                        value: "Nữ",
                        groupValue: _gender,
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Khác"),
                        value: "Khác",
                        groupValue: _gender,
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Role
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Khách hàng"),
                        value: "User",
                        groupValue: _role,
                        onChanged: (v) => setState(() => _role = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Nhân viên"),
                        value: "Nhân viên",
                        groupValue: _role,
                        onChanged: (v) => setState(() => _role = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _handleRegister(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Đăng ký",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}