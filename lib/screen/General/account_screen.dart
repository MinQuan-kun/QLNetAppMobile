import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'login_screen.dart';
import 'updateprofile_screen.dart';

import '../../Funtions/account_funtions.dart';

import '../../entities/user_account.dart';

import '../../api/account_controller.dart';

import '../../widget/bottomnavigator_custom.dart';
import '../../widget/loading_custom.dart';

class AccountScreen extends StatefulWidget {
  final int userID;

  const AccountScreen({super.key, required this.userID});

  @override
  State<StatefulWidget> createState() => _FormAccount();
}

bool check = false;
final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');

int getActiveDays(DateTime? created, DateTime? lastLogin) {
  if (created == null || lastLogin == null) return 0;
  return lastLogin.difference(created).inDays;
}

String Rank(int point) {
  String rank = "Đồng";
  if (point < 100) return rank;
  if (point >= 100 && point < 500)
    rank = "Bạc";
  if(point >= 500 && point < 1000)
    rank = "Vàng";
  return rank;
}

class _FormAccount extends State<AccountScreen> {
  File? backgroundImage;
  File? avatarImage;
  final picker = ImagePicker();
  Accounts? account;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    account = await AccountAPI.loadAccountById(widget.userID);
    if (account != null) {
      setState(() {
        currentAccount = account;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: isLoading
            ? const Center(child: CustomLoading())
            : NestedScrollView(
          headerSliverBuilder: (context, _) => [
            buildSliverAppBar(
              context: context,
              backgroundImage: backgroundImage,
              avatarImage: avatarImage,
              onEditPressed: () async {
                if (logined) {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UpdateProfileScreen()),
                  );
                  if (updated == true) {
                    await _loadData();
                  }
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              },
              account: account,
              onAvatarTap: () {
                if (!isLoggedIn()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                }
              },
            ),
          ],
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      label: "Số ngày hoạt động",
                      value:
                      "${getActiveDays(currentAccount?.userCreateDate, currentAccount?.userLastLogin)} ngày",
                    ),
                    _StatItem(
                      label: "TG chơi còn lại",
                      value: "${currentAccount?.timeUsing ?? 0} min",
                    ),
                    _StatItem(
                      label: "Số tiền",
                      value: currencyFormatter.format(currentAccount?.userBalance ?? 0),
                    ),
                    _StatItem(
                      label: "Hạng mức",
                      value: Rank(currentAccount?.userPoint ?? 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: buildBottomNavigationBar(
          context,
          currentAccount?.userRole == "User" ? 2 : 3,
          onRefresh: _loadData,
        ),
      ),
    );
  }
}


class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}
