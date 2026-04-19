import 'package:flutter/material.dart';

import '../screen/General/login_screen.dart';
import '../screen/General/computerdetails_screen.dart';

import '../entities/computer.dart';

Map<int, bool> serviceStatus = {};
Map<int, List<Order>> computerOrders = {};
Map<int, List<Bill>> computerBills = {};
Map<int, int> computerTotalService = {};
Map<int, int> totalCompleteService = {};

Widget buildComputerItem(
  BuildContext context,
  Computer computer,
  String? username,
  int? userID,
  List<Computer> computers,
  VoidCallback onRefresh,
) {
  final isAvailable = (computer.computerStatus == false);
  final bool checkUsing = (computer.idUser != 0);

  Color getComputerColor(bool isAvailable, bool checkUsing) {
    if (checkUsing) {
      return Colors.orange;
    } else if (isAvailable) {
      return Colors.black87;
    } else {
      return Colors.green;
    }
  }

  return GestureDetector(
    onTap: () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsComputerScreen(
            computerName: computer.computerName,
            idComputer: computer.idComputer,
            idUser: currentAccount?.idUser ?? 0,
            name: username ?? "Khách",
            phone: currentAccount?.userPhone ?? "",
            isUser: user,
            computerStatus: computer.computerStatus ? "Active" : "Inactive",
            canStart: serviceStatus[computer.idComputer] ?? false,

            orders: computerOrders[computer.idComputer] ?? [],
            bills: computerBills[computer.idComputer] ?? [],
            totalService: computerTotalService[computer.idComputer] ?? 0,
            totalComplete: totalCompleteService[computer.idComputer] ?? 0,
          ),
        ),
      );
      if (result != null && result is Map) {
        serviceStatus[computer.idComputer] = result["canStart"] ?? false;

        computerOrders[computer.idComputer] = result["orders"] ?? [];
        computerBills[computer.idComputer] = result["bills"] ?? [];
        computerTotalService[computer.idComputer] = result["totalService"] ?? 0;
        totalCompleteService[computer.idComputer] = result["totalComplete"] ?? 0;
      }

      onRefresh();
    },

    child: Container(
      decoration: BoxDecoration(
        color: getComputerColor(isAvailable, checkUsing),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.computer, size: 48, color: Colors.white),
          SizedBox(height: 8),
          Text(
            computer.computerName,
            style: TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            isAvailable
                ? computer.description
                : "Đang sử dụng\nID: ${computer.idUser}",
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
