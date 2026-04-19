import 'package:flutter/material.dart';
import '../api/service_controller.dart';
void showDepositDialog(
  BuildContext context, {
  required String userName,
  required int userID,
  required int staffid,
  required Function(int) onConfirm,
}) {
  final TextEditingController amountController = TextEditingController();

  void setAmount(int value) {
    amountController.text = value.toString();
  }

  // Cache navigator & messenger trước khi await
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  showDialog(
    context: context,
    builder: (dialogContext) {
      // dialogContext chỉ dùng để build UI, không dùng cho async
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Nạp tiền cho $userName",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Số tiền",
                suffixText: "VNĐ",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var amount in [50000, 100000, 200000, 500000])
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => setAmount(amount),
                    child: Text("${(amount / 1000).toStringAsFixed(0)}K"),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => navigator.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (amountController.text.isEmpty) return;

              final amount = int.tryParse(amountController.text) ?? 0;

              if (amount <= 0) {
                messenger.showSnackBar(
                  SnackBar(content: Text("Số tiền không hợp lệ")),
                );
                return;
              }
              try {
                await ServiceAPI.rechargeUser(
                  userId: userID,
                  amount: amount,
                  staffId: staffid,
                );

                onConfirm(amount);
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text("💰 Nạp $amount VNĐ thành công!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text("❌ Lỗi nạp tiền: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text("Xác nhận"),
          ),
        ],
      );
    },
  );
}
