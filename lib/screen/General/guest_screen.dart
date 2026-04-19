import 'package:flutter/material.dart';
import 'computer_screen.dart';

String? guestname;

class GuestScreen extends StatefulWidget {

  const GuestScreen({super.key});
  @override
  State<StatefulWidget> createState() => _FromGuest();

}

class _FromGuest extends State<GuestScreen> {
  final _usernameController = TextEditingController();
  final _guestkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _guestkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Image.asset(
                  'Img/Logo2.png',
                  height: 200,
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                ),
                Text(
                  "Tạo tên tài khoản",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: "Username",
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _usernameController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _usernameController.clear();
                            },
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Vui lòng nhập Email";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _usernameController.text.isNotEmpty
                      ? () {
                          if (_guestkey.currentState!.validate()) {
                            guestname = _usernameController.text.trim();
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComputerScreen(
                                guestName: guestname,
                                isUser: false,
                                userId: 0,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.shade100,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Tiếp",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
