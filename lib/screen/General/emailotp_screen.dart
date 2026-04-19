import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyOTPScreen extends StatefulWidget {
  final String email;

  const VerifyOTPScreen({super.key, required this.email});

  @override
  State<StatefulWidget> createState() => _FormVerifyOTP();
}

class _FormVerifyOTP extends State<VerifyOTPScreen> {
  int _secondsRemaining = 60;
  Timer? _timer;
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts[0].length > 1) {
      return '${parts[0][0]}****@${parts[1]}';
    }
    return email;
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        // Bàn phím số
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Chỉ nhập số
        ],
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Nút back
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 20),
            // Icon Email
            const Icon(Icons.email_outlined, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            // Tiêu đề
            const Text(
              "Xác Minh Bảo Mật",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Vui lòng nhập mã xác nhận từ email\n${_maskEmail(widget.email)}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            // 6 ô nhập OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _otpBox(index)),
            ),
            const SizedBox(height: 20),
            // Countdown hoặc nút resend
            _secondsRemaining > 0
                ? Text(
                    "Nhận mã xác nhận (${_secondsRemaining}s)",
                    style: const TextStyle(
                      color: Colors.black87,
                    ), // đổi màu dễ nhìn
                  )
                : GestureDetector(
                    onTap: () {
                      _startCountdown();
                    },
                    child: const Text(
                      "Gửi lại mã xác nhận",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
