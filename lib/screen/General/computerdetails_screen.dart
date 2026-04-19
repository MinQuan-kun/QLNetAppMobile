import 'package:flutter/material.dart';
import 'dart:async';
import "package:intl/intl.dart";
import 'package:collection/collection.dart';

import '../../entities/computer.dart';
import '../../entities/menu.dart';
import '../../entities/user_account.dart';

import '../../api/computer_controller.dart';
import '../../api/service_controller.dart';
import '../../api/account_controller.dart';
import '../../api/menu_controller.dart';

import '../../widget/button_custom.dart';

import 'pay_screen.dart';

class DetailsComputerScreen extends StatefulWidget {
  final String computerName;
  final String computerStatus;
  final int idComputer;
  final int idUser;
  final String name;
  final String phone;
  final bool isUser;
  final bool canStart;

  final List<Order> orders;
  final List<Bill> bills;
  final int totalService;
  final int totalComplete;

  const DetailsComputerScreen({
    super.key,
    required this.computerName,
    required this.idComputer,
    required this.idUser,
    required this.name,
    required this.phone,
    required this.isUser,
    required this.computerStatus,
    required this.canStart,
    this.orders = const [],
    this.bills = const [],
    this.totalService = 0,
    this.totalComplete = 0,
  });

  @override
  State<DetailsComputerScreen> createState() => _DetailsComputerScreenState();
}

enum PaymentMethod { now, later }

class Order {
  final Map<Menu, int> items;
  final int total;
  final PaymentMethod method;

  Order({required this.items, required this.total, required this.method});
}

class Bill {
  final List<Order> orders;
  final int total;
  final DateTime createdAt;

  Bill({required this.orders, required this.total, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();
}

class _DetailsComputerScreenState extends State<DetailsComputerScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _moneyController = TextEditingController();
  late Future<List<Menu>> _menuFuture;
  Accounts? account;
  Accounts? user;
  bool open = true;
  bool close = false;
  bool isUpdated = false;
  late TabController _tabController;

  int _selectedCustomerType = 0;
  int _selectedPlayType = 0;
  final _moneyusingController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _computerdetailskey = GlobalKey<FormState>();
  late bool _canStart = false;
  bool _deposit = false;

  bool start = false;
  bool pause = false;

  /// Tổng tiền máy
  late double _totalComputerMoney = 0;

  int first = 0;
  Computer? currentcomputer;
  Timer? _timer;
  Timer? _timeUserTimer;

  int _secondsPlayed = 0;
  final double _moneyPerSecond = 20000 / 3600;
  bool guest = true;
  bool haspay = false;

  /// Giỏ hàng (Menu: số lượng)
  final Map<Menu, int> _order = {};
  late List<Order> _orders;
  late List<Bill> _bills;
  late int _totalService;
  late int _totalCompleteService;

  void _payOrders() {
    if (_orders.isEmpty) return;
    final total = _orders.fold<int>(0, (sum, o) => sum + o.total);

    setState(() {
      _bills.add(Bill(orders: List.from(_orders), total: total));
      _orders.clear();
      _totalService = 0;
      _totalCompleteService = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Thanh toán thành công, tạo bill mới")),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAccount();
    _totalComputerMoney = 0;
    _totalCompleteService = 0;
    _orders = List.from(widget.orders);
    _bills = List.from(widget.bills);
    _totalService = widget.totalService;
    _totalCompleteService = widget.totalComplete;
    _nameController.addListener(() {
      setState(() {});
    });
    _phoneController.addListener(() {
      setState(() {});
    });
    _moneyusingController.addListener(() {
      setState(() {});
    });
    _canStart = widget.canStart;
    _fetchComputer(widget.idComputer);
    _menuFuture = MenuAPI.fetchMenu();
    _tabController = TabController(length: 3, vsync: this);
  }

  void onUpdate() {
    setState(() {
      isUpdated = true;
    });
  }

  void _startTimerForUser(int userId) {
    _timeUserTimer?.cancel();
    _timeUserTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      try {
        await AccountAPI.decreaseTimeUser(userId, minutes: 1);
        final updatedUser = await AccountAPI.loadAccountById(userId);
        setState(() {
          user = updatedUser;
        });

        if (user!.timeUsing <= 0) {
          timer.cancel();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Hết thời gian sử dụng")),
          );
          // TODO: gọi API đóng máy, kết thúc session
        }
      } catch (e) {
        timer.cancel();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi khi trừ thời gian: $e")));
      }
    });
  }

  @override
  void dispose() {
    _moneyController.dispose();
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAccount() async {
    final acc = await AccountAPI.loadAccountById(widget.idUser);
    setState(() {
      account = acc;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final int totalAmount =
        _totalService + (int.tryParse(_moneyController.text) ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết máy tính"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.computer), text: "Máy tính"),
            Tab(icon: Icon(Icons.restaurant), text: "Menu"),
            Tab(icon: Icon(Icons.fastfood), text: "Chi tiết hóa đơn"),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, {
              "idComputer": widget.idComputer,
              "status": currentcomputer?.computerStatus ?? false,
              "idUser": user?.idUser,
              "customerType": _selectedCustomerType,
              "phone": _phoneController.text.isNotEmpty
                  ? _phoneController.text
                  : "",
              "name": _nameController.text.isNotEmpty
                  ? _nameController.text
                  : "Khách",
              "secondsPlayed": _secondsPlayed,
              "order": _order,
              "canStart": _canStart,
              "orders": _orders,
              "bills": _bills,
              "totalService": _totalService,
              "totalComplete": _totalCompleteService,
            });
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        key: _computerdetailskey,
        children: [
          _buildComputerTab(totalAmount),
          _buildServiceTab(),
          _buildCartTab(),
        ],
      ),
    );
  }

  Future<void> _fetchComputer(int id) async {
    final comp = await ComputerAPI.loadComputerById(id);
    if (comp != null) {
      setState(() {
        currentcomputer = comp;
        if (comp.useStartTime != null) {
          start = true;
          final duration = DateTime.now().difference(comp.useStartTime!);
          _secondsPlayed = duration.inSeconds;
          _startTimer(); // tiếp tục đếm
        }
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsPlayed += 1;
        _totalComputerMoney = (_secondsPlayed * _moneyPerSecond);
        _moneyController.text = _totalComputerMoney.round().toString();
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _timeUserTimer?.cancel();
    _timeUserTimer = null;
  }

  void _addToCart(Menu item) {
    setState(() {
      _order.update(item, (v) => v + 1, ifAbsent: () => 1);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("🛒 Đã thêm ${item.foodName}")));
  }

  // void _removeFromCart(Menu item) {
  //   if (!_order.containsKey(item)) return;
  //   setState(() {
  //     final newQty = _order[item]! - 1;
  //     if (newQty <= 0) {
  //       _order.remove(item);
  //     } else {
  //       _order[item] = newQty;
  //     }
  //   });
  // }

  /// Xác nhận đặt món
  void _confirmOrder(PaymentMethod method) async {
    if (_order.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Xác nhận gọi món"),
        content: Text("Bạn có chắc chắn muốn gọi món không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("✅ Có"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("❌ Hủy"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      for (var entry in _order.entries) {
        final item = entry.key;
        final qty = entry.value;

        await ServiceAPI.startService(
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : "",
          userId: user?.idUser,
          staffId: widget.idUser,
          guestName:
              user?.userDisplayName ??
              (_nameController.text.isEmpty ? "Khách" : _nameController.text),
          computerId: widget.idComputer,
          foodId: item.foodID,
          price: item.foodPrice,
          quantity: qty,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gọi món thành công ")));

      setState(() {
        final total = _order.entries.fold<int>(
          0,
          (sum, e) => sum + e.key.foodPrice.toInt() * e.value,
        );

        if (method == PaymentMethod.now) {
          final newOrder = Order(
            items: Map.from(_order),
            total: total,
            method: method,
          );
          _bills.add(Bill(orders: [newOrder], total: total));
          _totalCompleteService += total;
        } else {
          _totalService += total;
          _orders.add(
            Order(items: Map.from(_order), total: total, method: method),
          );
        }
        _order.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Không thể gọi món: $e")));
    }
  }

  Widget _buildComputerTab(int totalAmount) {
    final comp = currentcomputer;
    if (comp == null) {
      return Center(child: CircularProgressIndicator());
    }

    final Color iconColor = comp.computerStatus ? Colors.green : Colors.grey;
    final String status = comp.computerStatus ? "Online" : "Offline";

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Icon(Icons.computer, size: 80, color: iconColor),
        SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.computerName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text("Trạng thái: $status", textAlign: TextAlign.center),
            Text("ID User: ${comp.idUser}"),
            if (comp.useStartTime != null) ...[
              Text(
                "Tổng tiền máy: ${NumberFormat('#,###').format(_totalComputerMoney)} VNĐ",
              ),
              Text(
                "Tổng tiền dịch vụ: ${NumberFormat('#,###').format(_totalService)} VNĐ",
              ),
              Text(
                "Tổng tiền đã thanh toán: ${NumberFormat('#,###').format(_totalCompleteService)} VNĐ",
              ),
              Text(
                "Tổng tiền chưa thanh toán: ${NumberFormat('#,###').format(totalAmount)} VNĐ",
              ),
              Text(
                "Thời gian chơi: ${(_secondsPlayed ~/ 3600).toString().padLeft(2, '0')}:"
                "${((_secondsPlayed % 3600) ~/ 60).toString().padLeft(2, '0')}:"
                "${(_secondsPlayed % 60).toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
            // --- NÚT MỞ MÁY
            if (!comp.computerStatus && account?.userRole != "User") ...[
              SizedBox(height: 14),
              InkWellCustom(
                iconPath: "Img/On.png",
                color: Colors.lightGreenAccent,
                width: 80,
                height: 80,
                onTap: () async {
                  try {
                    await ComputerAPI.openComputer(widget.idComputer);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Máy ${widget.idComputer} đã mở thành công ",
                        ),
                      ),
                    );
                    onUpdate();
                    setState(() {
                      comp.computerStatus = true;
                    });
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Không thể mở máy: $e")),
                    );
                  }
                  setState(() {
                    open = false;
                    close = true;
                  });
                },
              ),
            ],

            // --- NÚT ĐÓNG MÁY
            if (comp.computerStatus && !start) ...[
              SizedBox(height: 14),
              InkWellCustom(
                iconPath: "Img/Off.png",
                color: Colors.red,
                width: 80,
                height: 80,
                onTap: () async {
                  try {
                    await ComputerAPI.closeComputer(comp.idComputer);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Máy đã đóng và tính tiền thành công "),
                      ),
                    );

                    setState(() {
                      comp.computerStatus = false;
                      start = false;
                      _secondsPlayed = 0;
                      _moneyController.text = "";
                    });
                    _stopTimer();
                  } catch (e) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Không thể đóng máy hoặc tính tiền: $e"),
                      ),
                    );
                  }
                },
              ),
            ],
            if (comp.computerStatus && !start) ...[
              SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text("Khách vãng lai"),
                        selected: _selectedCustomerType == 0,
                        onSelected: (_) {
                          setState(() {
                            guest = true;
                            _selectedCustomerType = 0;
                            user = null;
                          });
                        },
                      ),
                      SizedBox(width: 10),
                      ChoiceChip(
                        label: Text("Khách có tài khoản"),
                        selected: _selectedCustomerType == 1,
                        onSelected: (_) {
                          setState(() {
                            guest = false;
                            _selectedCustomerType = 1;
                            _canStart = false;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_selectedCustomerType == 0) ...[
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: Text("Trả sau"),
                          selected: _selectedPlayType == 0,
                          onSelected: (_) {
                            setState(() {
                              _canStart = false;
                              _selectedPlayType = 0;
                              user = null;
                            });
                          },
                        ),
                        SizedBox(width: 10),
                        ChoiceChip(
                          label: Text("Trả trước"),
                          selected: _selectedPlayType == 1,
                          onSelected: (_) {
                            setState(() {
                              _selectedPlayType = 1;
                              _canStart = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              if (guest) ...[
                SizedBox(height: 14),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Tên khách",
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: _nameController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _nameController.clear();
                            },
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.text,
                ),
              ],

              SizedBox(height: 14),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Số điện thoại",
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.search, color: Colors.blue),
                        tooltip: "Tìm tài khoản",
                        onPressed: () async {
                          setState(() {
                            user = null;
                            _canStart = false;
                            _deposit = false;
                          });
                          final phone = _phoneController.text.trim();

                          if (phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Vui lòng nhập số điện thoại"),
                              ),
                            );
                            return;
                          }
                          final phoneRegex = RegExp(r'^(0[0-9]{9})$');
                          if (!phoneRegex.hasMatch(phone)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Số điện thoại không hợp lệ"),
                              ),
                            );
                            return;
                          }
                          if (_selectedCustomerType == 1) {
                            try {
                              user = await AccountAPI.loadAccountByPhone(
                                _phoneController.text,
                              );
                              if (!mounted) return;
                              setState(() {
                                _deposit = true;
                              });
                              if (user?.timeUsing != 0) {
                                setState(() {
                                  _canStart = true;
                                });
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Đã tìm thấy tài khoản"),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Không tìm thấy tài khoản"),
                                ),
                              );
                            }
                          } else {
                            try {
                              user = await AccountAPI.loadAccountByPhone(
                                _phoneController.text,
                              );
                              if (!mounted) return;
                              setState(() {
                                _canStart = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Số điện thoại đã tồn tại"),
                                ),
                              );
                            } catch (e) {
                              setState(() {
                                _canStart = true;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Số điện thoại này chưa tồn tại",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      if (_phoneController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _phoneController.clear();
                          },
                        ),
                    ],
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),

              // if(_selectedPlayType == 1 || _deposit)...[
              //   SizedBox(height: 12,),
              //   TextField(
              //     controller: _moneyusingController,
              //     decoration: InputDecoration(
              //       labelText: "Số tiền",
              //       fillColor: Colors.grey.shade100,
              //       contentPadding: EdgeInsets.symmetric(
              //         horizontal: 16,
              //         vertical: 14,
              //       ),
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //       suffixIcon: Row(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           if (_moneyusingController.text.isNotEmpty)
              //             IconButton(
              //               icon: Icon(Icons.clear),
              //               onPressed: () {
              //                 _moneyusingController.clear();
              //               },
              //             ),
              //         ],
              //       ),
              //     ),
              //     keyboardType: TextInputType.number,
              //   ),
              // ],
              if (user != null) ...[
                SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tài khoản: ${user?.userName}"),
                        user?.userDisplayName != null
                            ? Text("Tên hiển thị: ${user!.userDisplayName}")
                            : SizedBox.shrink(),
                        Text("Điểm: ${user?.userPoint}"),
                        Text("Số dư: ${user?.userBalance} VNĐ"),
                        Text(
                          "Thời gian sử dụng còn lại: ${user?.timeUsing} phút",
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (_deposit && user != null) ...[
                SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final TextEditingController moneyController =
                        TextEditingController();

                    final result = await showDialog<int>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Nạp tiền cho tài khoản"),
                          content: TextField(
                            controller: moneyController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: "Nhập số tiền cần nạp",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(null),
                              child: Text("Hủy"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final inputText = moneyController.text.trim();
                                final amountDouble = double.tryParse(inputText);

                                if (amountDouble == null || amountDouble <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Vui lòng nhập số tiền hợp lệ"),
                                    ),
                                  );
                                } else {
                                  // Chuyển double sang int trước khi pop
                                  final amountInt = amountDouble.round();
                                  Navigator.of(context).pop(amountInt);
                                }
                              },
                              child: Text("Xác nhận"),
                            ),
                          ],
                        );
                      },
                    );

                    if (result != null) {
                      final message = await ServiceAPI.rechargeUser(
                        userId: user?.idUser ?? 0,
                        amount: result,
                        staffId: widget.idUser,
                      );

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));

                      final updatedUser = await AccountAPI.loadAccountById(
                        user?.idUser ?? 0,
                      );
                      setState(() {
                        user = updatedUser;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Nạp tiền",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_selectedCustomerType == 1 && user != null) ...[
                    if (_canStart) ...[
                      SizedBox(height: 12),
                      InkWellCustom(
                        title: "Bắt đầu chơi",
                        iconPath: "Img/Game Controller.png",
                        width: 170,
                        height: 60,
                        iconSize: 20,
                        fontSize: 14,
                        color: Colors.deepPurpleAccent,
                        onTap: () async {
                          try {
                            // 1. Kiểm tra xem user đã login vào máy nào chưa
                            final allComputers =
                                await ComputerAPI.fetchComputers();
                            final existing = allComputers.firstWhereOrNull(
                              (c) =>
                                  c.idUser == widget.idUser &&
                                  c.computerStatus == true,
                            );
                            if (!mounted) return;
                            if (existing != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "❌ Người dùng này đang sử dụng máy ${existing.computerName}!",
                                  ),
                                ),
                              );
                              return;
                            }

                            // 2. Gọi API mở máy
                            await ComputerAPI.usingComputer(
                              comp.idComputer,
                              user?.idUser,
                              _phoneController.text,
                              _nameController.text.isEmpty
                                  ? "Khách"
                                  : _nameController.text,
                            );

                            // 3. Nếu là user có tài khoản (_selectcustomer == 1) → chơi bằng thời gian
                            if (_selectedCustomerType == 1 && user != null) {
                              // Gọi API tạo service (giá = 0, vì trừ vào timeUsing)
                              await ServiceAPI.startService(
                                phone: _phoneController.text,
                                userId: user?.idUser,
                                staffId: widget.idUser,
                                guestName:
                                    user?.userDisplayName ??
                                    user?.userName ??
                                    "Khách",
                                computerId: comp.idComputer,
                                price: 0,
                                // miễn phí vì đã trừ vào thời gian
                                quantity: 1,
                              );

                              // Bắt đầu đếm giờ & trừ thời gian mỗi phút
                              _startTimerForUser(user!.idUser);
                            } else {
                              int pricePerMinute = (20000 / 60).round();
                              await ServiceAPI.startService(
                                phone: _phoneController.text.isNotEmpty
                                    ? _phoneController.text
                                    : "",
                                userId: user?.idUser,
                                staffId: widget.idUser,
                                guestName: user?.idUser != null
                                    ? (user?.userDisplayName != null &&
                                              user!.userDisplayName!.isNotEmpty
                                          ? user?.userDisplayName
                                          : (user?.userName != null &&
                                                    user!.userName.isNotEmpty
                                                ? user?.userName
                                                : "Khách"))
                                    : (_nameController.text.isNotEmpty
                                          ? _nameController.text
                                          : "Khách"),
                                computerId: comp.idComputer,
                                price: pricePerMinute.toInt(),
                                quantity: 1,
                              );
                              // Bắt đầu đếm giờ
                              _startTimer();
                            }

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Bắt đầu sử dụng thành công ✅"),
                              ),
                            );

                            setState(() {
                              _fetchComputer(comp.idComputer);
                              start = true;
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Không thể bắt đầu: $e")),
                            );
                          }
                        },
                      ),
                    ],
                    SizedBox(width: 12),
                    InkWellCustom(
                      title: "Nạp giờ chơi",
                      iconPath: "Img/Time to Pay.png",
                      width: 170,
                      height: 60,
                      iconSize: 20,
                      fontSize: 14,
                      color: Colors.orangeAccent,
                      onTap: () async {
                        final TextEditingController moneyController =
                            TextEditingController();

                        final result = await showDialog<int>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Nạp giờ chơi"),
                              content: TextField(
                                controller: moneyController,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Nhập số tiền muốn nạp",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(null),
                                  child: Text("Hủy"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final money = int.tryParse(
                                      moneyController.text.trim(),
                                    );
                                    if (money == null || money <= 0) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Vui lòng nhập số tiền hợp lệ",
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.of(context).pop(money);
                                    }
                                  },
                                  child: Text("Xác nhận"),
                                ),
                              ],
                            );
                          },
                        );

                        if (result != null) {
                          final message = await AccountAPI.deposittimeusing(
                            userid: user?.idUser ?? 0,
                            money: result,
                          );
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
                        final updatedUser = await AccountAPI.loadAccountById(
                          user?.idUser ?? 0,
                        );
                        setState(() {
                          user = updatedUser;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ],
            if (_totalComputerMoney != 0) ...[
              SizedBox(height: 20),
              InkWellCustom(
                color: Colors.green,
                title: "Thanh toán",
                iconPath: "Img/Cash.png",
                width: 200,
                height: 65,
                iconSize: 25,
                fontSize: 16,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PayScreen(
                        userId: comp.idUser ?? 0,
                        staffId: widget.idComputer,
                        userphone: widget.phone,
                        isUser: widget.isUser,
                        computerFee: _totalComputerMoney,
                        serviceFee: _totalService,
                        orders: _orders,
                        computerid: comp.idComputer,
                        totalComplete: _totalCompleteService,
                      ),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      _stopTimer();
                      start = false;
                      pause = false;
                      haspay = false;
                      _secondsPlayed = 0;
                      _totalComputerMoney = 0;
                      _totalService = 0;
                      _totalCompleteService = 0;
                      currentcomputer?.computerStatus = false;
                      _moneyController.clear();
                      _order.clear();
                      _orders.clear();
                      _bills.clear();
                      _fetchComputer(comp.idComputer);
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCartTab() {
    if (_bills.isEmpty && _orders.isEmpty && _order.isEmpty) {
      return Center(child: Text("Hóa đơn trống"));
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // --- Bills đã thanh toán ---
        if (_bills.isNotEmpty) ...[
          Text(
            "📑 Các bill đã thanh toán",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ..._bills.map(
            (bill) => Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bill ngày ${DateFormat('dd/MM/yyyy HH:mm').format(bill.createdAt)}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    ...bill.orders.expand(
                      (o) => o.items.entries.map((e) {
                        final item = e.key;
                        final qty = e.value;
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: item.foodImage != null
                                    ? Image.memory(
                                        item.foodImage!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.fastfood,
                                        color: Colors.grey[700],
                                      ),
                              ),
                              SizedBox(width: 12),
                              Expanded(child: Text("${item.foodName} x$qty")),
                              Text(
                                "${NumberFormat('#,###').format(item.foodPrice.toInt() * qty)} VNĐ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    Divider(),
                    Text(
                      "Tổng: ${NumberFormat('#,###').format(bill.total)} VNĐ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
        ],

        // --- Orders chưa thanh toán ---
        if (_orders.isNotEmpty) ...[
          Text(
            "🕒 Order chưa thanh toán",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ..._orders.map(
            (order) => Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),
                    ...order.items.entries.map((e) {
                      final item = e.key;
                      final qty = e.value;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: item.foodImage != null
                                  ? Image.memory(
                                      item.foodImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.fastfood,
                                      color: Colors.grey[700],
                                    ),
                            ),
                            SizedBox(width: 12),
                            Expanded(child: Text("${item.foodName} x$qty")),
                            Text(
                              "${NumberFormat('#,###').format(item.foodPrice.toInt() * qty)} VNĐ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }),
                    Divider(),
                    Text(
                      "Tổng: ${NumberFormat('#,###').format(order.total)} VNĐ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _payOrders,
            child: Text("💰 Thanh toán tất cả order"),
          ),
          SizedBox(height: 16),
        ],

        // --- Đơn hiện tại (_order) ---
        if (_order.isNotEmpty) ...[
          Text(
            "🛒 Đơn hiện tại",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ..._order.entries.map((entry) {
            final item = entry.key;
            final qty = entry.value;
            return Card(
              child: ListTile(
                leading: item.foodImage != null
                    ? Image.memory(
                        item.foodImage!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.fastfood),
                title: Text(item.foodName),
                subtitle: Text(
                  "${NumberFormat('#,###').format(item.foodPrice.toInt())} VNĐ x $qty = "
                  "${NumberFormat('#,###').format(item.foodPrice.toInt() * qty)} VNĐ",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          if (qty > 1) {
                            _order[item] = qty - 1;
                          } else {
                            _order.remove(item);
                          }
                        });
                      },
                    ),
                    Text(
                      "$qty",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          _order[item] = qty + 1;
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  if (!start) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Không thể thanh toán!Vui lòng sử dụng máy"),
                      ),
                    );
                    return;
                  }

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Xác nhận gọi món"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _confirmOrder(PaymentMethod.now);
                          },
                          child: Text("💳 Thanh toán ngay"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _confirmOrder(PaymentMethod.later);
                          },
                          child: Text("🕒 Thanh toán sau"),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightGreen),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Thanh toán",
                    style: TextStyle(
                      color: Colors.lightGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildServiceTab() {
    return FutureBuilder<List<Menu>>(
      future: _menuFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Lỗi tải menu: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Không có món nào"));
        }

        final menus = snapshot.data!;

        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: menus.length,
          itemBuilder: (context, index) {
            final item = menus[index];
            return Card(
              elevation: 4,
              color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: item.foodImage != null
                        ? Image.memory(item.foodImage!, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.fastfood, size: 40),
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.foodName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${NumberFormat('#,###').format(item.foodPrice.toInt())} VNĐ",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => _addToCart(item),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Thêm",
                                  style: TextStyle(
                                    color: Colors.white,
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
                ],
              ),
            );
          },
        );
      },
    );
  }
}
