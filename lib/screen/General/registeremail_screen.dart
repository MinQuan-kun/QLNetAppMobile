// import 'package:flutter/material.dart';
// import 'emailotp_screen.dart';
//
// class RegisterEmailScreen extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _FormRegisterEmail();
// }
//
// class _FormRegisterEmail extends State<RegisterEmailScreen> {
//   final _emailController = TextEditingController();
//   final _RegisterEmailkey = GlobalKey<FormState>();
//   String? mail;
//
//   @override
//   void initState() {
//     super.initState();
//     _emailController.addListener(() {
//       setState(() {});
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(16),
//           child: Form(
//             key: _RegisterEmailkey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: IconButton(
//                     icon: Icon(Icons.arrow_back_ios, size: 28),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ),
//                 Image.asset(
//                   'Img/Logo2.png',
//                   height: 200,
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   fit: BoxFit.contain,
//                 ),
//                 Text(
//                   "Tạo tài khoản",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   "Dùng để đăng nhập trang web, ứng dụng của Net Home",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 SizedBox(height: 20),
//                 TextFormField(
//                   controller: _emailController,
//                   autocorrect: false,
//                   decoration: InputDecoration(
//                     hintText: "Email",
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 14,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: BorderSide.none,
//                     ),
//                     suffixIcon: _emailController.text.isNotEmpty
//                         ? IconButton(
//                             icon: Icon(Icons.clear),
//                             onPressed: () {
//                               _emailController.clear();
//                             },
//                           )
//                         : null,
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Vui lòng nhập Email";
//                     }
//                     if (!RegExp(
//                       r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                     ).hasMatch(value)) {
//                       return "Email không hợp lệ";
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 40),
//                 ElevatedButton(
//                   onPressed: _emailController.text.isNotEmpty
//                       ? () {
//                           if (_RegisterEmailkey.currentState!.validate()) {
//                             mail = _emailController.text.trim();
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     VerifyOTPScreen(email: mail!),
//                               ),
//                             );
//                           }
//                         }
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent.shade100,
//                     minimumSize: Size(double.infinity, 48),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     "Tiếp",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
