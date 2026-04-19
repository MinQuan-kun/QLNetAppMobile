// import 'package:flutter/material.dart';
// import 'package:crypto/crypto.dart';
// import 'dart:convert';
// import 'package:dio/dio.dart';
//
// import 'login_screen.dart';
//
// class RegisterScreen extends StatefulWidget {
//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   final _fullnameController = TextEditingController();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//
//   bool _obscurePassword = true;
//   bool _confirmPassword = true;
//   bool _activated = true;
//   String? _avatarUrl;
//   String? _name;
//   String? _username;
//   String? _password;
//
//   String md5Hash(String input) {
//     return md5.convert(utf8.encode(input)).toString();
//   }
//
//   Future<void> registerUser(Map<String, dynamic> userData) async {
//     try {
//       final dio = Dio(
//         BaseOptions(
//           baseUrl: 'http://10.0.2.2:39553',
//           connectTimeout: Duration(milliseconds: 5000),
//           sendTimeout: Duration(milliseconds: 5000),
//           receiveTimeout: Duration(milliseconds: 10000),
//         ),
//       );
//
//       print("Sending data: ${jsonEncode(userData)}");
//
//       final response = await dio.post(
//         '/api/users/register',
//         data: jsonEncode(userData),
//         options: Options(headers: {'Content-Type': 'application/json'}),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Đăng ký thành công')));
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => LoginScreen()),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Đăng ký thất bại: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Lỗi kết nối tới server: $e')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         child: SingleChildScrollView(
//           child: Stack(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color.fromRGBO(120, 255, 153, 1),
//                       Color.fromRGBO(120, 220, 153, 1),
//                       Color.fromRGBO(120, 200, 153, 1),
//                     ],
//                   ),
//                 ),
//                 width: double.infinity,
//                 height: 350,
//               ),
//               SafeArea(
//                 child: Container(
//                   margin: EdgeInsets.only(top: 40),
//                   width: double.infinity,
//                   child: Icon(Icons.person_pin, color: Colors.white, size: 120),
//                 ),
//               ),
//               Column(
//                 children: [
//                   SizedBox(height: 250),
//                   Container(
//                     margin: EdgeInsets.symmetric(horizontal: 30),
//                     width: double.infinity,
//                     height: 580,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(25),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 15,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         SizedBox(height: 10),
//                         Text(
//                           "Register",
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Container(
//                           child: Form(
//                             key: _formKey,
//                             child: Column(
//                               children: [
//                                 TextFormField(
//                                   controller: _fullnameController,
//                                   autocorrect: false,
//                                   decoration: InputDecoration(
//                                     enabledBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: Colors.purple.shade100,
//                                       ),
//                                     ),
//                                     focusedBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: Colors.blueAccent.shade100,
//                                         width: 3,
//                                       ),
//                                     ),
//                                     labelText: "Full Name",
//                                     prefixIcon: Icon(Icons.person_pin),
//                                   ),
//                                   onSaved: (value) {
//                                     _name = value;
//                                   },
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty)
//                                       return "Vui lòng nhập họ và tên!";
//                                     return null;
//                                   },
//                                   keyboardType: TextInputType.name,
//                                 ),
//                                 SizedBox(height: 8),
//                                 TextFormField(
//                                   controller: _phoneController,
//                                   autocorrect: false,
//                                   decoration: InputDecoration(
//                                     enabledBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: Colors.purple.shade100,
//                                       ),
//                                     ),
//                                     focusedBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: Colors.blueAccent.shade100,
//                                         width: 3,
//                                       ),
//                                     ),
//                                     labelText: "Phone",
//                                     prefixIcon: Icon(Icons.phone),
//                                   ),
//                                   keyboardType: TextInputType.phone,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty)
//                                       return "Vui lòng nhập SĐT!";
//                                     if (!RegExp(
//                                       r'^\+?[0-9]{10,12}$',
//                                     ).hasMatch(value))
//                                       return "Số điện thoại không hợp lệ";
//                                     return null;
//                                   },
//                                 ),
//                                 SizedBox(height: 10),
//                                 TextFormField(
//                                   controller: _emailController,
//                                   autocorrect: false,
//                                   decoration: InputDecoration(
//                                     enabledBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: Colors.purple.shade100,
//                                       ),
//                                     ),
//                                     focusedBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: Colors.blueAccent.shade100,
//                                         width: 3,
//                                       ),
//                                     ),
//                                     labelText: "Email",
//                                     prefixIcon: Icon(Icons.mail),
//                                   ),
//                                   keyboardType: TextInputType.emailAddress,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return "Vui lòng nhập Email";
//                                     }
//                                     if (!RegExp(
//                                       r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                                     ).hasMatch(value)) {
//                                       return "Email không hợp lệ";
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 SizedBox(height: 10),
//                                 TextFormField(
//                                   controller: _usernameController,
//                                   autocorrect: false,
//                                   decoration: InputDecoration(
//                                     enabledBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: Colors.purple.shade100,
//                                       ),
//                                     ),
//                                     focusedBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: Colors.blueAccent.shade100,
//                                         width: 3,
//                                       ),
//                                     ),
//                                     labelText: "Username",
//                                     prefixIcon: Icon(Icons.account_box),
//                                   ),
//                                   onSaved: (value) {
//                                     _username = value;
//                                   },
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty)
//                                       return "Vui lòng nhập Username!";
//                                     return null;
//                                   },
//                                 ),
//                                 SizedBox(height: 15),
//                                 TextFormField(
//                                   controller: _passwordController,
//                                   autocorrect: false,
//                                   decoration: InputDecoration(
//                                     enabledBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: Colors.purple.shade100,
//                                       ),
//                                     ),
//                                     focusedBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: Colors.blueAccent.shade100,
//                                         width: 3,
//                                       ),
//                                     ),
//                                     labelText: "Password",
//                                     prefixIcon: Icon(Icons.lock),
//                                     suffixIcon: IconButton(
//                                       icon: Icon(
//                                         _obscurePassword
//                                             ? Icons.visibility
//                                             : Icons.visibility_off,
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           _obscurePassword = !_obscurePassword;
//                                         });
//                                       },
//                                     ),
//                                   ),
//                                   onSaved: (value) {
//                                     _password = value;
//                                   },
//                                   obscureText: _obscurePassword,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty)
//                                       return "Hãy nhập mật khẩu";
//                                     if (value.length < 6)
//                                       return "Mật khẩu không hợp lệ";
//                                     return null;
//                                   },
//                                 ),
//                                 SizedBox(height: 10),
//                                 TextFormField(
//                                   autocorrect: false,
//                                   controller: _confirmPasswordController,
//                                   decoration: InputDecoration(
//                                     enabledBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: Colors.purple.shade100,
//                                       ),
//                                     ),
//                                     focusedBorder: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: Colors.blueAccent.shade100,
//                                         width: 3,
//                                       ),
//                                     ),
//                                     labelText: "ConfirmPassword",
//                                     prefixIcon: Icon(Icons.password_sharp),
//                                     suffixIcon: IconButton(
//                                       icon: Icon(
//                                         _confirmPassword
//                                             ? Icons.visibility
//                                             : Icons.visibility_off,
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           _confirmPassword = !_confirmPassword;
//                                         });
//                                       },
//                                     ),
//                                   ),
//                                   obscureText: _confirmPassword,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty)
//                                       return "Vui lòng nhập lại";
//                                     if (value != _passwordController.text)
//                                       return "Mật khẩu nhập lại phải giống ở trên";
//                                     return null;
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                     const SizedBox(height: 30),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () async {
//                             if (_formKey.currentState!.validate()) {
//                               _formKey.currentState!.save();
//
//                               String fullName = _fullnameController.text.trim();
//                               List<String> nameParts = fullName.split(
//                                 RegExp(r'\s+'),
//                               );
//
//                               String firstName = '';
//                               String lastName = '';
//                               if (nameParts.length >= 2) {
//                                 firstName = nameParts.last;
//                                 lastName = nameParts
//                                     .sublist(0, nameParts.length - 1)
//                                     .join(' ');
//                               } else if (nameParts.length == 1) {
//                                 firstName = nameParts[0];
//                                 lastName = '';
//                               }
//
//                               String hashedPassword = md5Hash(
//                                 _passwordController.text,
//                               );
//
//                               String right = "user";
//                               bool active = true;
//                               int currentUnixTime =
//                                   DateTime.now().millisecondsSinceEpoch ~/ 1000;
//                               Map<String, dynamic> userData = {
//                                 'Username': _usernameController.text,
//                                 'Password': hashedPassword,
//                                 'Email': _emailController.text,
//                                 'FirstName': firstName,
//                                 'LastName': lastName,
//                                 'Phone': _phoneController.text,
//                                 'Rights': right,
//                                 'Activated': active,
//                                 'Avatar': '',
//                                 'LastLogin': 0,
//                                 'DateCreated': currentUnixTime,
//                                 'DateModified': currentUnixTime,
//                               };
//
//                               await registerUser(userData);
//                             }
//                           },
//                           child: Text("Đăng ký"),
//                         ),
//                         SizedBox(height: 10),
//                         ElevatedButton(
//                           onPressed: () {
//                             Navigator.pop(
//                                 context
//                             );
//                           },
//                           child: Text("Quay lại"),
//                         ),
//                       ],
//                     ),
//                 ],
//               )
//             ],
//           ),
//
//         ),
//       ),
//     );
//   }
// }
