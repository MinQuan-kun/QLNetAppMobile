import 'package:flutter/material.dart';

import '../screen/General/home_screen.dart';
import '../screen/General/computer_screen.dart';
import '../screen/General/account_screen.dart';
import '../screen/General/login_screen.dart';
import '../screen/General/guest_screen.dart';
import '../screen/Admin/manage_screen.dart';

BottomNavigationBar buildBottomNavigationBar(
  BuildContext context,
  int currentIndex, {
  VoidCallback? onRefresh,
}) {
  bool check = false;
  if (currentAccount?.idUser != 0) check = true;

  List<BottomNavigationBarItem> navItems = [
    BottomNavigationBarItem(
      icon: Image.asset("Img/Home Page.png", width: 30, height: 30),
      label: "Trang chủ",
    ),
    BottomNavigationBarItem(
      icon: Image.asset("Img/computer2.png", width: 30, height: 30),
      label: "Bảng máy",
    ),
    BottomNavigationBarItem(
      icon: Image.asset("Img/Hatsune Miku.png", width: 30, height: 30),
      label: "Cá nhân",
    ),
  ];

  if (currentAccount?.userRole != "User") {
    navItems.insert(
      2,
      BottomNavigationBarItem(
        icon: Image.asset("Img/Access.png", width: 30, height: 30),
        label: "Quản lý",
      ),
    );
  }

  if (currentIndex >= navItems.length) {
    currentIndex = navItems.length - 1;
  }

  return BottomNavigationBar(
    currentIndex: currentIndex,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.green,
    ),
    unselectedLabelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    items: navItems,
    onTap: (index) {
      if (index == currentIndex) {
        if (index == 1) {
          onRefresh?.call();
        }
        return;
      }

      Widget nextPage;
      if (index == 0) {
        nextPage = HomeScreen(userID: currentAccount?.idUser ?? 0);
      } else if (index == 1) {
        nextPage = ComputerScreen(
          userId: currentAccount?.idUser,
          guestName: guestname,
          isUser: check,
        );
      } else if (index == 2 && currentAccount?.userRole != "User") {
        nextPage = ManageScreen(userId: currentAccount?.idUser ?? 0);
      } else {
        nextPage = AccountScreen(userID: currentAccount?.idUser ?? 0);
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    },
  );
}
