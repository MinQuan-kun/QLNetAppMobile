import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../entities/menu.dart';

import '../../api/menu_controller.dart';
import '../../api/import_controller.dart';

import '../General/login_screen.dart';

import '../../widget/button_custom.dart';

class MenuDetailsScreen extends StatefulWidget {
  final int foodID;

  const MenuDetailsScreen({super.key, required this.foodID});

  @override
  State<StatefulWidget> createState() => _FormMenuDetails();
}

class _FormMenuDetails extends State<MenuDetailsScreen> {
  late int foodId;
  bool isLoading = true;
  Menu? menu;
  File? foodImage;
  final picker = ImagePicker();
  bool isUpdated = false;

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  late TextEditingController categoryController;
  late TextEditingController noteController;

  void onUpdate() {
    setState(() {
      isUpdated = true;
    });
  }

  @override
  void initState() {
    super.initState();
    foodId = widget.foodID;
    nameController = TextEditingController();
    priceController = TextEditingController();
    quantityController = TextEditingController();
    categoryController = TextEditingController();
    noteController = TextEditingController();
    loadFood();
  }

  Future<void> loadFood() async {
    try {
      final data = await MenuAPI.fetchFoodById(foodId);
      if (data != null) {
        setState(() {
          menu = data;
          nameController.text = menu?.foodName ?? "";
          priceController.text = menu?.foodPrice.toString() ?? "";
          quantityController.text = menu?.quantity.toString() ?? "";
          categoryController.text = menu?.categoryID?.toString() ?? "";
          noteController.text = menu?.notes ?? "";
        });
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi tải món: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<bool> updateFood() async {
    try {
      final image = foodImage != null
          ? await MultipartFile.fromFile(
              foodImage!.path,
              filename: foodImage!.path.split('/').last,
            )
          : null;

      return await MenuAPI.updateFood(
        foodId: foodId,
        foodName: nameController.text.trim(),
        foodPrice: int.tryParse(priceController.text.trim()) ?? 0,
        quantity: int.tryParse(quantityController.text.trim()) ?? 0,
        categoryId: int.tryParse(categoryController.text.trim()),
        notes: noteController.text.trim(),
        foodImage: image,
      );
    } catch (e) {
      debugPrint("❌ Lỗi khi cập nhật món: $e");
      return false;
    }
  }

  Future<void> pickFoodImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        foodImage = File(picked.path);
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    categoryController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context, isUpdated),
        ),
        centerTitle: true,
        title: Text(
          'Chi tiết món ăn',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: pickFoodImage,
                            child: SizedBox(
                              height: 200,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  foodImage != null
                                      ? Image.file(
                                          foodImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : (menu != null && menu!.foodImage != null
                                            ? Image.memory(
                                                menu!.foodImage!,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                color: Colors.grey[300],
                                                child: Center(
                                                  child: Text(
                                                    "Bấm để chọn ảnh",
                                                  ),
                                                ),
                                              )),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 15),

                          // Các field nhập
                          buildTextField(
                            label: "Tên món",
                            controller: nameController,
                            enabled: true,
                          ),
                          buildTextField(
                            label: "Giá",
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            enabled: true,
                          ),
                          buildTextField(
                            label: "Số lượng",
                            controller: quantityController,
                            enabled: false,
                          ),
                          buildTextField(
                            label: "Category ID",
                            controller: categoryController,
                            keyboardType: TextInputType.number,
                            enabled: true,
                          ),
                          buildTextField(
                            label: "Ghi chú",
                            controller: noteController,
                            maxLines: 3,
                            maxLength: 200,
                            enabled: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWellCustom(
                          title: "Chỉnh sửa",
                            width: 150,
                            height: 60,
                            fontSize: 14,
                            color: Colors.blue, onTap: ()async{
                          final success = await updateFood();

                          if (!context.mounted) return;
                          onUpdate();
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("✅ Cập nhật món ăn thành công"),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "❌ Lưu thất bại, vui lòng thử lại",
                                ),
                              ),
                            );
                          }
                        }),
                        SizedBox(width: 20),
                        InkWellCustom(
                          title: "Nhập hàng",
                          width: 150,
                          height: 60,
                          fontSize: 14,
                          color: Colors.orange,
                          onTap: () async {

                            final result = await showDialog<int>(
                              context: context,
                              builder: (BuildContext context) {
                                final quantityController = TextEditingController();

                                return AlertDialog(
                                  title: Text("Nhập số lượng"),
                                  content: TextField(
                                    controller: quantityController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: "Số lượng",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Hủy"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        final value = int.tryParse(quantityController.text.trim());
                                        if (value != null && value > 0) {
                                          Navigator.pop(context, value);
                                        }
                                      },
                                      child: Text("Xác nhận"),
                                    ),
                                  ],
                                );
                              },
                            );

                            // Nếu có số lượng hợp lệ
                            if (result != null) {
                              try {
                                final msg = await ImportAPI.importMenu(
                                  staffid: currentAccount?.idUser ?? 0,
                                  foodid: foodId,
                                  quantum: result,
                                );

                                if (!context.mounted) return;
                                onUpdate();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("✅ $msg")),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("❌ Lỗi: $e")),
                                );
                              }
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    required bool enabled,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType: keyboardType,
            enabled: enabled,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
