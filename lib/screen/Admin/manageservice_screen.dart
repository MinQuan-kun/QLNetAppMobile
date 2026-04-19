import 'package:flutter/material.dart';
import '../../widget/appbar_custom.dart';
import 'menu_screen.dart';

class ManageServiceScreen extends StatefulWidget {
  final int userID;
  const ManageServiceScreen({super.key, required this.userID});

  @override
  State<StatefulWidget> createState() => _FormManageService();
}

class _FormManageService extends State<ManageServiceScreen> {
  final _manageServiceKey = GlobalKey<FormState>();
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(
        selectedIndex: selectedTab,
        onTabSelected: (i) => setState(() => selectedTab = i),
        tabs: const [
          TabItem(label: "Máy tính", icon: Icons.computer),
          TabItem(label: "Menu", icon: Icons.fastfood),
        ],
        backgroundColor: Colors.orangeAccent,
        selectedColor: Colors.white,
        unselectedColor: Colors.white70,
        leadingIcon: Icons.arrow_back_ios,
        onLeadingPressed: () {
            Navigator.pop(context);
        },
      ),

      body: Column(
        key: _manageServiceKey,
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                switch (selectedTab) {
                  case 0:
                    return Center(
                      child: Text("đang được cập nhật...",
                          style: TextStyle(fontSize: 18)),
                    );
                  case 1:
                    return MenuScreen();
                  default:
                    return SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
