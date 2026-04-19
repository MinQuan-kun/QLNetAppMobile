import 'package:flutter/material.dart';

import '../General/login_screen.dart';

import '../../Funtions/account_funtions.dart';

import '../../entities/user_account.dart';

import '../../api/account_controller.dart';
import '../../widget/loading_custom.dart';
import 'createaccount_screen.dart';

class UserListScreen extends StatefulWidget {
  final int userId;

  const UserListScreen({super.key, required this.userId});

  @override
  State<StatefulWidget> createState() => _FormUserList();
}

class _FormUserList extends State<UserListScreen> {
  late int userID;
  bool isLoading = true;
  List<Accounts> accounts = [];
  String? selectedStatus;
  String? selectedRole;

  @override
  void initState() {
    super.initState();
    loadUser();
    userID = widget.userId;
  }

  Future<void> loadUser() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await AccountAPI.fetchByroleAccounts(widget.userId);
      if (!mounted) return;
      setState(() {
        accounts = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Loi: $e')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<Accounts> get filteredAccounts {
    return accounts.where((user) {
      if (selectedStatus != null) {
        if (selectedStatus == 'Online' && user.userStatus != true) return false;
        if (selectedStatus == 'Offline' && user.userStatus != false) return false;
      }

      if (selectedRole != null) {
        if (user.userRole != selectedRole) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,

        title: Row(
          children: [
            Icon(Icons.account_box, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text(
              "Quản lý tài khoản",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withValues(alpha: 38),
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.blue),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateAccountScreen(),
                  ),
                );

                if (result == true) {
                  loadUser();
                }
              },
              child: Text(
                "Tạo tài khoản",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh tìm kiếm
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Tìm kiếm",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.search),
                              onPressed: () {
                                // Xử lý tìm kiếm
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Bộ lọc + Nút tạo tài khoản
              Row(
                children: [
                  // Dropdown trạng thái
                  Spacer(),
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Trạng thái',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: ['Tất cả', 'Online', 'Offline']
                          .map(
                            (value) => DropdownMenuItem(
                              value: value == 'Tất cả' ? null : value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8),

                  // Dropdown chức vụ (chỉ Admin)
                  if (currentAccount?.userRole == 'Admin') ...[
                    SizedBox(
                      width: 140,
                      child: DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Chức vụ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: ['Tất cả', 'Admin', 'Nhân viên', 'User']
                            .map(
                              (value) => DropdownMenuItem(
                                value: value == 'Tất cả' ? null : value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ],
              ),
              // Danh sách user
              Expanded(
                child: isLoading
                    ? const Center(child: CustomLoading())
                    : filteredAccounts.isEmpty
                    ? const Center(child: Text("Không có tài khoản nào!"))
                    : ListView.builder(
                        itemCount: filteredAccounts.length,
                        itemBuilder: (context, index) {
                          final user = filteredAccounts[index];
                          return buildAccountItem(
                            context,
                            user,
                            index,
                            onDelete: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                await AccountAPI.deleteuser(
                                  userId: user.idUser,
                                );
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text("Xóa tài khoản thành công"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                setState(() {
                                  accounts.removeWhere(
                                    (element) => element.idUser == user.idUser,
                                  );
                                });
                              } catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text("❌ $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            onResetPassword: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                final result =
                                    await AccountAPI.resetUserPassword(
                                      idUser: user.idUser,
                                      username: user.userName,
                                    );
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "${result['msg']}. Mật khẩu mới: ${result['newPassword']}",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text("❌ $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
