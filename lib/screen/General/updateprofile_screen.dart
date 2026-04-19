import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';
import '../../api/account_controller.dart';

class UpdateProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FormUpdateProfile();

  const UpdateProfileScreen({super.key});
}

class _FormUpdateProfile extends State<UpdateProfileScreen> {
  File? avatarImage;
  File? backgroundImage;
  bool isUpdated = false;
  final picker = ImagePicker();

  late TextEditingController nicknameController;
  late TextEditingController signatureController;
  late TextEditingController genderController;
  String gender = "";
  String nickname = "";
  String signature = "";

  @override
  void initState() {
    super.initState();

    nickname =
        currentAccount?.userDisplayName ?? currentAccount?.userName ?? "";
    signature = currentAccount?.userSignature ?? "";
    gender = currentAccount?.userGender ?? "";

    nicknameController = TextEditingController(text: nickname);
    signatureController = TextEditingController(text: signature);
    genderController = TextEditingController(text: gender);

    nicknameController.addListener(() => setState(() {}));
    signatureController.addListener(() => setState(() {}));
  }

  void onUpdate() {
    setState(() {
      isUpdated = true;
    });
  }

  @override
  void dispose() {
    nicknameController.dispose();
    signatureController.dispose();
    genderController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        avatarImage = File(picked.path);
      });
    }
  }

  Future<void> _pickBackground() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        backgroundImage = File(picked.path);
      });
    }
  }

  ImageProvider getAvatarProvider() {
    if (avatarImage != null) {
      return FileImage(avatarImage!);
    } else if (currentAccount?.userAvatar != null) {
      try {
        return MemoryImage(currentAccount!.userAvatar!);
      } catch (e) {
        return NetworkImage(_defaultAvatarUrl);
      }
    } else {
      return NetworkImage(_defaultAvatarUrl);
    }
  }

  static const String _defaultAvatarUrl =
      "https://preview.redd.it/a-redraw-of-a-miku-drawing-i-posted-a-few-weeks-ago-i-hope-v0-qv5lah7y8i8a1.jpg?width=1080&crop=smart&auto=webp&s=cf7a6d2052a22471f78c2454aab7fe98fd9aab1f";

  ImageProvider getBackgroundProvider() {
    if (backgroundImage != null) {
      return FileImage(backgroundImage!);
    } else if (currentAccount?.userBackground != null) {
      try {
        return MemoryImage(currentAccount!.userBackground!);
      } catch (e) {
        return NetworkImage(_defaultBackgroundUrl);
      }
    } else {
      return NetworkImage(_defaultBackgroundUrl);
    }
  }

  static const String _defaultBackgroundUrl =
      "https://giffiles.alphacoders.com/133/13336.gif";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context, isUpdated),
        ),
        centerTitle: true,
        title: Text(
          'Thông Tin Cá Nhân',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    // Avatar + Background
                    SizedBox(
                      height: 200,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // background image
                          Image(
                            image: getBackgroundProvider(),
                            fit: BoxFit.cover,
                          ),
                          // avatar
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: getAvatarProvider(),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    // Nút chọn ảnh
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _pickAvatar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text("Chọn Ảnh Đại Diện"),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _pickBackground,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text("Đổi Hình Nền"),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Nickname
                    buildTextField(
                      label: "Nickname",
                      controller: nicknameController,
                      maxLength: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Mỗi tháng có thể chỉnh sửa 1 lần, lượt chỉnh sửa sẽ được làm mới vào ngày 1 hàng tháng (UTC+8), nickname không được chứa ký tự đặc biệt',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Giới tính
                    buildTextField(
                      label: "Giới Tính",
                      controller: genderController,
                      readOnly: true,
                      suffixIcon: Icons.chevron_right,
                      showCounter: false,
                      onTap: () => showModalBottomSheet(
                        context: context,
                        builder: (context) => ListView(
                          shrinkWrap: true,
                          children: [
                            for (var g in ["Nam", "Nữ", "Khác"])
                              ListTile(
                                title: Text(g),
                                onTap: () {
                                  setState(() {
                                    gender = g;
                                    genderController.text = g;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Ký tên
                    buildTextField(
                      label: "Ký Tên",
                      controller: signatureController,
                      maxLines: 2,
                      maxLength: 200,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                onPressed: () async {
                  if (currentAccount == null) return;

                  final success = await AccountAPI.uploadProfile(
                    userId: currentAccount!.idUser,
                    imgAvatar: avatarImage,
                    imgBackground: backgroundImage,
                    signature: signatureController.text.trim(),
                    nickname: nicknameController.text.trim(),
                    gender: gender,
                  );

                  if (success) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("✅ Cập nhật thông tin thành công"),
                        ),
                      );
                      onUpdate();
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("❌ Lưu thất bại, vui lòng thử lại"),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5D7BFF),
                  minimumSize: Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text("Lưu", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? suffixIcon,
    bool readOnly = false,
    int maxLines = 1,
    int? maxLength,
    bool showCounter = true,
    Function()? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: Colors.grey)
                  : null,
              counterText: "",
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          if (showCounter)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${value.text.length}${maxLength != null ? '/$maxLength' : ''}",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
