import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:dio/dio.dart';

import 'computerdetails_screen.dart';
import '../../api/service_controller.dart';
import '../../api/computer_controller.dart';

class PayScreen extends StatefulWidget {
  final int userId;
  final int staffId;
  final String userphone;
  final bool isUser;
  final int computerid;
  final double computerFee; // tiền máy
  final int serviceFee; // tiền dịch vụ
  final int totalComplete; // tiền đã thanh toán
  final List<Order> orders; // danh sách order chưa thanh toán

  const PayScreen({
    super.key,
    required this.userId,
    required this.staffId,
    required this.userphone,
    required this.isUser,
    required this.computerFee,
    required this.serviceFee,
    required this.orders,
    required this.computerid,
    required this.totalComplete,
  });

  @override
  State<StatefulWidget> createState() => _FormPay();
}

double roundToThousands(double amount, {bool minOneThousand = false}) {
  if (minOneThousand && amount < 1000) return 1000;
  return (amount / 1000).round() * 1000;
}

class _FormPay extends State<PayScreen> {
  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,###');

    final computerFeeRounded = roundToThousands(
      widget.computerFee,
      minOneThousand: true,
    );
    final serviceFeeRounded = roundToThousands(widget.serviceFee.toDouble());
    final totalAmount = computerFeeRounded + serviceFeeRounded;
    final totalCompleteMoney = widget.totalComplete;
    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết thanh toán"),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // --- Thông tin tiền máy + dịch vụ ---
          Card(
            margin: EdgeInsets.all(12),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "💻 Tiền máy:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${currency.format(computerFeeRounded)} VNĐ",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "🍜 Tiền dịch vụ:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${currency.format(serviceFeeRounded)} VNĐ",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "🍜 Tiền dịch vụ đã thanh toán:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${currency.format(totalCompleteMoney)} VNĐ",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- Danh sách order ---
          Expanded(
            child: widget.orders.isEmpty
                ? Center(child: Text("Không có đơn hàng nào"))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: widget.orders.length,
                    itemBuilder: (context, index) {
                      final order = widget.orders[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "🕒 ${order.method == PaymentMethod.later ? "Thanh toán sau" : "Thanh toán ngay"}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 8),
                              ...order.items.entries.map(
                                (e) => Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${e.key.foodName} x${e.value}"),
                                      Text(
                                        "${currency.format(e.key.foodPrice.toInt() * e.value)} VNĐ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Tổng: ${currency.format(order.total)} VNĐ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // --- Tổng cộng + Nút thanh toán ---
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "💰 Tổng cộng:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${currency.format(totalAmount)} VNĐ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      // 1. Gọi API stopService
                      await ServiceAPI.stopService(
                        computerId: widget.computerid,
                      );
                      // 2. Gọi API đóng máy
                      await ComputerAPI.closeComputer(widget.computerid);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Thanh toán thành công ✅"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context, true);
                      }
                    } on DioException catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Thanh toán thất bại: ${e.response?.data}",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(Icons.payment),
                  label: Text(
                    "Thanh toán ngay",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
