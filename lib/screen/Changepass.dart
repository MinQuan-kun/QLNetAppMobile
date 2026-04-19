import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String selectedMethod = 'Email';
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi Mật Khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mật khẩu cũ'),
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Mật khẩu mới'),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Xác nhận mật khẩu mới'),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Xác nhận qua'),
              DropdownButton<String>(
                value: selectedMethod,
                items: ['Email', 'Số điện thoại']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedMethod = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                selectedMethod == 'Email'
                    ? 'mi****05@gmail.com'
                    : '09*******35',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập mã xác thực',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: gửi mã xác thực
                    },
                    child: const Text('Gửi mã'),
                  )
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: xử lý đổi mật khẩu
                  },
                  child: const Text('Đổi Mật Khẩu'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
