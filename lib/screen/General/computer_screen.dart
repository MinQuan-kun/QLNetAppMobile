import 'package:flutter/material.dart';

import '../../Funtions/computer_funtions.dart';

import 'login_screen.dart';

import '../../api/computer_controller.dart';

import '../../entities/computer.dart';

import '../../widget/button_custom.dart';
import '../../widget/loading_custom.dart';
import '../../widget/bottomnavigator_custom.dart';

class ComputerScreen extends StatefulWidget {
  final int? userId;
  final String? guestName;
  final bool isUser;

  const ComputerScreen({
    super.key,
    this.userId,
    this.guestName,
    required this.isUser,
  });

  @override
  State<StatefulWidget> createState() => _FormComputer();
}

class _FormComputer extends State<ComputerScreen> {
  List<Computer> computers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadComputers();
  }

  Future<void> loadComputers() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await ComputerAPI.fetchComputers();
      if (!mounted) return;
      setState(() {
        computers = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách máy: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const spacing = 16.0;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bảng máy",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

        automaticallyImplyLeading: false,
        actions: [
          if (!widget.isUser)
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: InkWellCustom(
                color: Colors.red,
                title: "Thoát",
                fontSize: 12,
                width: 80,
                onTap: () {
                  logined = false;
                  user = false;
                  currentGuestName = null;
                  isGuestLogin = false;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            ),
          if (currentAccount?.userRole != "User" && widget.userId != 0)
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Material(
                    color: Colors.transparent,
                    shape: CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      customBorder: CircleBorder(),
                      onTap: () async {
                        await ComputerAPI.openAllComputers();
                        await loadComputers();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Mở máy thành công')),
                        );
                      },
                      child: Ink.image(
                        image: AssetImage("Img/On.png"),
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Material(
                    color: Colors.transparent,
                    shape: CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      customBorder: CircleBorder(),
                      onTap: () async {
                        final freshComputers = await ComputerAPI.fetchComputers();

                        final hasUser = freshComputers.any((c) => c.idUser != 0);
                        if (hasUser) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Không thể đóng, vẫn còn máy đang có user sử dụng!')),
                          );
                          return;
                        }

                        await ComputerAPI.closeAllComputers();
                        await loadComputers();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đóng máy thành công')),
                        );
                      },

                      child: Ink.image(
                        image: AssetImage("Img/Off.png"),
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadComputers,
        child: Padding(
          padding: EdgeInsets.all(spacing),
          child: isLoading
              ? CustomLoading()
              : computers.isEmpty
              ? Center(child: Text("Không có máy nào!"))
              : GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: 1,
                  children: computers
                      .map(
                        (c) => buildComputerItem(
                          context,
                          c,
                          widget.guestName,
                          widget.userId,
                          computers,
                          loadComputers,
                        ),
                      )
                      .toList(),
                ),
        ),
      ),

      bottomNavigationBar: (widget.isUser == true)
          ? buildBottomNavigationBar(context, 1, onRefresh: loadComputers)
          : null,
    );
  }
}
