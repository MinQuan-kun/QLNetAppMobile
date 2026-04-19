import 'dart:io';
import 'package:flutter/material.dart';

import '../screen/General/login_screen.dart';
import '../screen/General/updateprofile_screen.dart';
import '../screen/General/setting_screen.dart';
import '../screen/Admin/messageuser_screen.dart';
import '../screen/My_Inventory.dart';

import '../entities/user_account.dart';

import '../api/account_controller.dart';

import 'deposit.dart';
import 'message.dart' hide ChatDialog;

bool isLoggedIn() => currentAccount != null;

SliverAppBar buildSliverAppBar({
  required BuildContext context,
  File? backgroundImage,
  File? avatarImage,
  required VoidCallback onEditPressed,
  Accounts? account,
  required VoidCallback onAvatarTap,
}) {
  ImageProvider avatarProvider;
  try {
    if (avatarImage != null) {
      avatarProvider = FileImage(avatarImage);
    } else if (account?.userAvatar != null) {
      avatarProvider = MemoryImage(account!.userAvatar!);
    } else {
      avatarProvider = NetworkImage(
        "https://preview.redd.it/a-redraw-of-a-miku-drawing-i-posted-a-few-weeks-ago-i-hope-v0-qv5lah7y8i8a1.jpg?width=1080&crop=smart&auto=webp&s=cf7a6d2052a22471f78c2454aab7fe98fd9aab1f",
      );
    }
  } catch (e) {
    avatarProvider = NetworkImage(
      "https://preview.redd.it/a-redraw-of-a-miku-drawing-i-posted-a-few-weeks-ago-i-hope-v0-qv5lah7y8i8a1.jpg?width=1080&crop=smart&auto=webp&s=cf7a6d2052a22471f78c2454aab7fe98fd9aab1f",
    );
  }

  ImageProvider backgroundProvider;
  try {
    if (backgroundImage != null) {
      backgroundProvider = FileImage(backgroundImage);
    } else if (account?.userBackground != null) {
      backgroundProvider = MemoryImage(account!.userBackground!);
    } else {
      backgroundProvider = NetworkImage(
        "https://giffiles.alphacoders.com/133/13336.gif",
      );
    }
  } catch (e) {
    backgroundProvider = NetworkImage(
      "https://giffiles.alphacoders.com/133/13336.gif",
    );
  }

  return SliverAppBar(
    expandedHeight: 200,
    pinned: true,
    backgroundColor: Colors.black,
    actions: [
      IconButton(
        icon: Icon(Icons.inventory_2_outlined, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(0),
              child: Stack(
                children: [
                  MyInventoryScreen(),
                  Positioned(
                    top: 45,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      IconButton(
        onPressed: () {
          if (logined) {
            int userID = currentAccount!.idUser;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingScreen(userID: userID),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }
        },
        icon: Icon(Icons.settings, color: Colors.white),
      ),
    ],
    flexibleSpace: FlexibleSpaceBar(
      background: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image(
            image: backgroundProvider,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black54],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (!isLoggedIn()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      ).then((_) => (context as Element).markNeedsBuild());
                    } else {
                      onAvatarTap();
                    }
                  },
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: isLoggedIn() ? avatarProvider : null,
                    child: !isLoggedIn()
                        ? Icon(Icons.person, size: 30, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoggedIn()
                            ? (currentAccount!.userDisplayName?.isNotEmpty ??
                                      false
                                  ? currentAccount!.userDisplayName!
                                  : currentAccount!.userName)
                            : "Khách",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isLoggedIn()
                                  ? "UserID: ${currentAccount!.idUser}"
                                  : "Chưa đăng nhập",
                              style: TextStyle(color: Colors.white70),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: onEditPressed,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Chỉnh Sửa",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isLoggedIn()
                            ? (currentAccount!.userSignature ?? "")
                            : "",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

void updateProfile(
  BuildContext context,
  Function({required bool isAvatar}) onPickImage,
) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => UpdateProfileScreen()),
  );
}

Widget buildAccountItem(
  BuildContext context,
  Accounts user,
  int index,
    {required VoidCallback onDelete, VoidCallback? onResetPassword}
) {
  bool check = false;
  if (currentAccount?.userRole == "Admin") {
    check = true;
  }

  bool use = false;
  if (user.userRole == "User") {
    use = true;
  }

  ImageProvider avatarProvider;
  if (user.userAvatar != null && user.userAvatar!.isNotEmpty) {
    avatarProvider = MemoryImage(user.userAvatar!);
  } else {
    avatarProvider = NetworkImage(
      "https://preview.redd.it/a-redraw-of-a-miku-drawing-i-posted-a-few-weeks-ago-i-hope-v0-qv5lah7y8i8a1.jpg?width=1080&crop=smart&auto=webp&s=cf7a6d2052a22471f78c2454aab7fe98fd9aab1f",
    );
  }

  ImageProvider backgroundProvider;
  if (user.userBackground != null && user.userBackground!.isNotEmpty) {
    backgroundProvider = MemoryImage(user.userBackground!);
  } else {
    backgroundProvider = NetworkImage(
      "https://giffiles.alphacoders.com/133/13336.gif",
    );
  }

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: EdgeInsets.symmetric(vertical: 6),
    child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: backgroundProvider,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withValues(alpha: 0.4),
            BlendMode.dstATop,
          ),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: avatarProvider,
            ),
            SizedBox(width: 8),

            // Thông tin user
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (user.userDisplayName != null &&
                            user.userDisplayName!.isNotEmpty)
                        ? user.userDisplayName!
                        : user.userName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("ID: ${user.idUser}"),
                  Text(
                    "Trạng thái: ${user.userStatus ? 'Online' : 'Offline'}",
                    style: TextStyle(
                      color: user.userStatus ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () async {
                final senderId = currentAccount?.idUser ?? 0;
                final senderName =
                    (currentAccount?.userDisplayName?.isNotEmpty == true)
                    ? currentAccount!.userDisplayName!
                    : (currentAccount?.userName ?? "");

                final receiverId = user.idUser;
                final receiverName = (user.userDisplayName?.isNotEmpty == true)
                    ? user.userDisplayName!
                    : user.userName;

                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                try {
                  final messages = await GetMessages.fetchConversation(
                    senderId,
                    receiverId,
                  );

                  // Mở dialog chat
                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => ChatDialog(
                        currentId: senderId,
                        senderName: senderName,
                        receiverId: receiverId,
                        receiverName: receiverName,
                        initialMessages: messages,
                      ),
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text("Lỗi tải tin nhắn: $e")),
                  );
                }
              },
              icon: Icon(Icons.more),
            ),

            SizedBox(width: 8),
            // Cột nút Reset và Xóa tài khoản và nạp tiền
            IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: onResetPassword,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withValues(alpha: 0.15),
                            // ✅ sửa withOpacity
                            border: Border.all(color: Colors.orangeAccent),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Reset mật khẩu",
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      if (use) ...[
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            showDepositDialog(
                              context,
                              userName: user.userName,
                              userID: user.idUser,
                              staffid: currentAccount?.idUser ?? 0,
                              onConfirm: (amount) {
                                final messenger = ScaffoldMessenger.of(context);
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "💰 Nạp $amount VNĐ cho ${user.userName} thành công!",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purpleAccent.withValues(
                                alpha: 0.15,
                              ),
                              border: Border.all(color: Colors.purpleAccent),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Nạp tiền",
                              style: TextStyle(
                                color: Colors.purpleAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (check) ...[
                    SizedBox(height: 8),
                    InkWell(
                      onTap: onDelete, // ✅ gọi callback truyền từ UserListScreen
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          border: Border.all(color: Colors.redAccent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Xóa tài khoản",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}