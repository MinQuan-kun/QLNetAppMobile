import 'package:flutter/material.dart';

import '../../Funtions/menu_funtions.dart';

import '../../entities/category.dart';
import '../../entities/menu.dart';

import '../../api/category_controller.dart';
import '../../api/menu_controller.dart';

import '../../widget/loading_custom.dart';

class MenuScreen extends StatefulWidget {
  final int? userID;
  final String? guestName;

  const MenuScreen({super.key, this.userID, this.guestName});

  @override
  State<StatefulWidget> createState() => _FormMenu();
}

class _FormMenu extends State<MenuScreen> {
  List<Menu> menu = [];
  List<Category> categories = [];
  bool isLoading = false;
  String? selectedCategory;
  String? selectedPrice;
  String? selectCategorName;
  int idCategory = 0;

  final priceRanges = <String>['Tất cả', 'Dưới 20k', '20k - 50k', 'Trên 50k'];

  @override
  void initState() {
    super.initState();
    loadMenu();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final data = await CategoryAPI.fetchCategory();
      setState(() {
        categories = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách thể loại: $e')),
      );
    }
  }

  Future<void> loadMenu() async {
    setState(() => isLoading = true);
    try {
      final data = await MenuAPI.fetchMenu();
      setState(() {
        menu = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách món: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<Menu> get filteredMenu {
    return menu.where((food) {
      // Lọc theo category name
      if (selectCategorName != null && selectCategorName != '0') {
        if (food.categoryID != int.tryParse(selectCategorName!)) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(

        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh tìm kiếm
              Container(
                width: double.infinity,
                height: 45,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.search),
                        onPressed: () {
                          // Xử lý tìm kiếm
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),

              // Bộ lọc + Nút tạo tài khoản
              Row(
                children: [
                  // Lọc theo thể loại
                  SizedBox(
                    width: 140,
                    child: DropdownButtonFormField<String>(
                      value: selectCategorName,
                      decoration: InputDecoration(
                        labelText: 'Thể loại',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Tất cả'),
                        ),
                        ...categories.map(
                          (cat) => DropdownMenuItem<String>(
                            value: cat.categoryID.toString(),
                            child: Text(cat.categoryName),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectCategorName = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 20,),
                  InkWell(
                    onTap: () {
                      // Xử lý tạo món
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Thêm món",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              // Danh sách món

              Expanded(
                child: isLoading
                    ? const Center(child: CustomLoading())
                    : filteredMenu.isEmpty
                    ? const Center(child: Text("Không có món nào!"))
                    : FoodByCategoryList(
                  menus: filteredMenu,
                  onMenuUpdated: () async {
                    await loadMenu(); // reload menu khi cập nhật
                  },
                ),
              )


            ],
          ),
        ),
      ),
    );
  }
}
