import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../api/service_controller.dart';
import '../../api/servicedetails_controller.dart';
import '../../api/account_controller.dart';

import '../../entities/service.dart';
import '../../entities/service_details.dart';

import '../../widget/chart_custom.dart';
import '../../widget/loading_custom.dart';

class StatisticScreen extends StatefulWidget {
  final int userID;

  const StatisticScreen({super.key, required this.userID});

  @override
  State<StatisticScreen> createState() => _FormStatistic();
}

Map<String, double> calculateFee(List<ServiceDetail> details) {
  double computerFee = 0;
  double serviceFee = 0;
  double depositFee = 0; // thêm tiền nạp

  for (var d in details) {
    if (d.serviceType == 1) {
      computerFee += d.totalReceived;
    } else if (d.serviceType == 0) {
      serviceFee += d.totalReceived;
    } else if (d.serviceType == 2) {
      depositFee += d.totalReceived;
    }
  }

  return {
    "computerFee": computerFee,
    "serviceFee": serviceFee,
    "depositFee": depositFee,
    "total": computerFee + serviceFee + depositFee,
  };
}

Map<int, String> staffNames = {};

enum StatisticMode { day, week, month }

class _FormStatistic extends State<StatisticScreen> {
  DateTime? selectedDate;
  StatisticMode selectedMode = StatisticMode.day;
  bool isLoading = false;
  bool showDetail = false;
  List<Service> services = [];
  Map<int, Map<String, double>> serviceFees = {};
  Map<int, List<int>> serviceComputers = {};
  DateTime? selectedMonth;

  @override
  void initState() {
    super.initState();
    loadService();
    selectedDate = DateTime.now();
  }

  // hàm lấy số tuần trong năm
  int weekOfYear(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final days = date.difference(firstDay).inDays;
    return (days / 7).floor() + 1;
  }

  Future<void> loadService() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final data = await ServiceAPI.fetchService();
      services = data;
      final futures = data.map((s) async {
        final details = await ServiceDetailsAPI.fetchService(s.serviceID);
        serviceFees[s.serviceID] = calculateFee(details);

        serviceComputers[s.serviceID] = details
            .map((d) => d.computerID ?? 0)
            .toSet()
            .toList();

        if (s.staffID != null && !staffNames.containsKey(s.staffID)) {
          final staff = await AccountAPI.loadAccountById(s.staffID!);
          if (staff != null) {
            staffNames[s.staffID!] = staff.displayOrUserName;
          }
        }
      });

      await Future.wait(futures);

      if (mounted) setState(() {});
      // hideLoading(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể tải danh sách: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredServices = selectedDate == null
        ? services
        : services.where((s) {
            final createdAt = s.billCreatedAt;
            switch (selectedMode) {
              case StatisticMode.day:
                return createdAt.year == selectedDate!.year &&
                    createdAt.month == selectedDate!.month &&
                    createdAt.day == selectedDate!.day;
              case StatisticMode.week:
                return createdAt.year == selectedDate!.year &&
                    weekOfYear(createdAt) == weekOfYear(selectedDate!);
              case StatisticMode.month:
                return createdAt.year == selectedDate!.year &&
                    createdAt.month == selectedDate!.month;
            }
          }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.greenAccent),
            SizedBox(width: 8),
            Text(
              "Thống kê doanh thu",
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
      ),
      body: isLoading
          ? CustomLoading()
          : Column(
              children: [
                // chọn ngày
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _selectDate,
                        icon: Icon(Icons.calendar_today),
                        label: Text("Chọn ngày"),
                      ),
                      SizedBox(width: 10),
                      DropdownButton<StatisticMode>(
                        value: selectedMode,
                        items: [
                          DropdownMenuItem(
                            value: StatisticMode.day,
                            child: Text("Theo ngày"),
                          ),
                          DropdownMenuItem(
                            value: StatisticMode.week,
                            child: Text("Theo tuần"),
                          ),
                          DropdownMenuItem(
                            value: StatisticMode.month,
                            child: Text("Theo tháng"),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedMode = value);
                          }
                        },
                      ),
                      SizedBox(width: 10),
                      Text(
                        selectedDate != null
                            ? (selectedMode == StatisticMode.day
                                  ? DateFormat(
                                      "dd/MM/yyyy",
                                    ).format(selectedDate!)
                                  : selectedMode == StatisticMode.week
                                  ? "Tuần ${weekOfYear(selectedDate!)} / ${selectedDate!.year}"
                                  : DateFormat("MM/yyyy").format(selectedDate!))
                            : "Chưa chọn",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // biểu đồ + tổng tiền
                if (selectedDate != null)
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Builder(
                          builder: (_) {
                            if (selectedMode == StatisticMode.week) {
                              // Chuẩn bị dữ liệu cho tuần
                              final daysOfWeek = [
                                "T2",
                                "T3",
                                "T4",
                                "T5",
                                "T6",
                                "T7",
                                "CN",
                              ];
                              final List<WeekChartData> weeklyData = [];

                              for (int i = 1; i <= 7; i++) {
                                final dateOfWeek = selectedDate!.subtract(
                                  Duration(days: selectedDate!.weekday - i),
                                );
                                double serviceFee = 0;
                                double computerFee = 0;
                                double depositFee = 0; // thêm

                                for (var s in filteredServices) {
                                  if (s.billCreatedAt.year == dateOfWeek.year &&
                                      s.billCreatedAt.month ==
                                          dateOfWeek.month &&
                                      s.billCreatedAt.day == dateOfWeek.day) {
                                    final fees =
                                        serviceFees[s.serviceID] ??
                                        {
                                          "computerFee": 0,
                                          "serviceFee": 0,
                                          "depositFee": 0,
                                        };
                                    serviceFee += fees["serviceFee"] ?? 0;
                                    computerFee += fees["computerFee"] ?? 0;
                                    depositFee += fees["depositFee"] ?? 0;
                                  }
                                }

                                weeklyData.add(
                                  WeekChartData(
                                    daysOfWeek[i - 1],
                                    serviceFee,
                                    computerFee,
                                    depositFee, // thêm
                                  ),
                                );
                              }

                              return CustomWeekChart(
                                selectedDate: selectedDate!,
                                data: weeklyData,
                              );
                            } else {
                              double computerFee = 0;
                              double serviceFee = 0;
                              double depositFee = 0; // thêm
                              for (var s in filteredServices) {
                                final fees =
                                    serviceFees[s.serviceID] ??
                                    {
                                      "computerFee": 0,
                                      "serviceFee": 0,
                                      "depositFee": 0,
                                    };
                                computerFee += fees["computerFee"] ?? 0;
                                serviceFee += fees["serviceFee"] ?? 0;
                                depositFee += fees["depositFee"] ?? 0; // thêm
                              }

                              final dataMap = {
                                "Tiền máy": computerFee,
                                "Dịch vụ": serviceFee,
                                "Tiền nạp": depositFee, // thêm cột nạp
                              };

                              final colorMap = {
                                "Tiền máy": Colors.blueAccent,
                                "Dịch vụ": Colors.orangeAccent,
                                "Tiền nạp": Colors.greenAccent,
                              };

                              return CustomDonutChart(
                                data: dataMap,
                                colors: colorMap,
                                selectedDate: selectedDate!,
                              );
                            }
                          },
                        ),

                        SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  showDetail = !showDetail;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  showDetail ? "Ẩn chi tiết" : "Xem chi tiết",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                if (showDetail)
                  if (showDetail)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical, // cho phép cuộn dọc
                        child: SingleChildScrollView(
                          scrollDirection:
                              Axis.horizontal, // cho phép cuộn ngang
                          child: DataTable(
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                            ),
                            headingRowColor: WidgetStateProperty.all(
                              Colors.blueAccent.shade100,
                            ),
                            columns: const [
                              DataColumn(label: Text("STT")),
                              DataColumn(label: Text("Username")),
                              DataColumn(label: Text("ID máy")),
                              DataColumn(label: Text("Thời điểm")),
                              DataColumn(label: Text("Phí dịch vụ")),
                              DataColumn(label: Text("Tiền nạp")),
                              DataColumn(label: Text("Phí thời gian")),
                              DataColumn(label: Text("Tổng tiền")),
                              DataColumn(label: Text("Nhân viên")),
                            ],
                            rows: filteredServices.asMap().entries.map((entry) {
                              final index = entry.key + 1;
                              final service = entry.value;

                              final createdAt = service.billCreatedAt;
                              final fees =
                                  serviceFees[service.serviceID] ??
                                  {
                                    "computerFee": 0,
                                    "serviceFee": 0,
                                    "total": 0,
                                  };
                              final computers =
                                  serviceComputers[service.serviceID] ?? [];
                              final computerIDs = computers.isEmpty
                                  ? "-"
                                  : computers
                                        .map((c) => c.toString())
                                        .join(", ");

                              return DataRow(
                                cells: [
                                  DataCell(Text(index.toString())),
                                  DataCell(
                                    Text(service.guestName ?? "Unknown"),
                                  ),
                                  DataCell(Text(computerIDs)),
                                  DataCell(
                                    Text(
                                      DateFormat(
                                        "dd/MM/yyyy HH:mm",
                                      ).format(createdAt),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      "${(fees["serviceFee"] ?? 0).toStringAsFixed(0)} đ",
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      "${(fees["depositFee"] ?? 0).toStringAsFixed(0)} đ",
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      "${fees["computerFee"]!.toStringAsFixed(0)} đ",
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      "${fees["total"]!.toStringAsFixed(0)} đ",
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      staffNames[service.staffID] ??
                                          service.staffID.toString(),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
    );
  }
}
