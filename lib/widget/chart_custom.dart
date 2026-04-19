import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

/// -------- Donut Chart (ngày / tháng) --------
class CustomDonutChart extends StatelessWidget {
  final Map<String, double> data;
  final Map<String, Color> colors;
  final DateTime selectedDate;

  const CustomDonutChart({
    super.key,
    required this.data,
    required this.colors,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.decimalPattern('vi_VN');
    final total = data.values.fold(0.0, (sum, val) => sum + val);

    final chartData = data.entries
        .where((e) => e.value > 0)
        .map((e) => ChartData(e.key, e.value, colors[e.key] ?? Colors.grey))
        .toList();

    final formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);

    return SfCircularChart(
      title: ChartTitle(
        text: 'Biểu đồ doanh thu ngày $formattedDate',
        alignment: ChartAlignment.center,
        textStyle:  TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.greenAccent,
        ),
      ),
      legend:  Legend(isVisible: false),
      series: <CircularSeries>[
        DoughnutSeries<ChartData, String>(
          dataSource: chartData.isNotEmpty
              ? chartData
              : [ChartData("Không có dữ liệu", 1, Colors.grey.shade300)],
          xValueMapper: (ChartData data, _) => data.label,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelMapper: (ChartData data, _) => chartData.isNotEmpty
              ? "${data.label}\n${currencyFormatter.format(data.value)} VNĐ"
              : "",
          dataLabelSettings:  DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            connectorLineSettings: ConnectorLineSettings(
              type: ConnectorType.curve,
              length: '15%',
            ),
          ),
          radius: '75%',
          innerRadius: '75%',
        )
      ],
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
          widget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Text(
                "Tổng",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                "${currencyFormatter.format(total)} VNĐ",
                style:  TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChartData {
  final String label;
  final double value;
  final Color color;
  ChartData(this.label, this.value, this.color);
}

/// -------- Column Chart (tuần) --------
class CustomWeekChart extends StatelessWidget {
  final DateTime selectedDate;
  final List<WeekChartData> data;

  const CustomWeekChart({
    super.key,
    required this.selectedDate,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final weekNumber = _weekOfYear(selectedDate);

    return SfCartesianChart(
      title: ChartTitle(
        text: "Biểu đồ doanh thu tuần $weekNumber / ${selectedDate.year}",
        alignment: ChartAlignment.center,
        textStyle:  TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
      legend:  Legend(isVisible: true, position: LegendPosition.bottom),
      primaryXAxis: CategoryAxis(title: AxisTitle(text: "Thứ")),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: "Doanh thu (VNĐ)"),
        numberFormat: NumberFormat.decimalPattern('vi_VN'),
      ),
      series: <CartesianSeries<WeekChartData, String>>[
        ColumnSeries<WeekChartData, String>(
          name: "Dịch vụ",
          dataSource: data,
          xValueMapper: (WeekChartData d, _) => d.day,
          yValueMapper: (WeekChartData d, _) => d.service,
          dataLabelSettings:  DataLabelSettings(isVisible: true),
          color: Colors.orangeAccent,
        ),
        ColumnSeries<WeekChartData, String>(
          name: "Máy tính",
          dataSource: data,
          xValueMapper: (WeekChartData d, _) => d.day,
          yValueMapper: (WeekChartData d, _) => d.computer,
          dataLabelSettings:  DataLabelSettings(isVisible: true),
          color: Colors.blueAccent,
        ),
        ColumnSeries<WeekChartData, String>(
          name: "Nạp tiền",
          dataSource: data,
          xValueMapper: (WeekChartData d, _) => d.day,
          yValueMapper: (WeekChartData d, _) => d.deposit,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          color: Colors.greenAccent,
        ),
      ],
    );
  }

  int _weekOfYear(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final days = date.difference(firstDay).inDays;
    return (days / 7).floor() + 1;
  }
}

class WeekChartData {
  final String day;
  final double service;
  final double computer;
  final double deposit;

  WeekChartData(this.day, this.service, this.computer, this.deposit);
}
