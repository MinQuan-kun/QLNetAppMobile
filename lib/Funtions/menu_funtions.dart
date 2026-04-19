import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../screen/Admin/menudetails_screen.dart';

import '../entities/menu.dart';

class FoodItem extends StatelessWidget {
  final Menu menu;
  final int? userId;
  final String? guestName;

  FoodItem({super.key, required this.menu, this.userId, this.guestName});

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.grey[300],
                image: menu.foodImage != null
                    ? DecorationImage(
                  image: MemoryImage(menu.foodImage!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
            ),
            Text(
              menu.foodName,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Số lượng: ${menu.quantity}',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
            Text(
              'Đơn giá: ${currencyFormatter.format(menu.foodPrice)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class FoodByCategoryList extends StatelessWidget {
  final List<Menu> menus;
  final Future<void> Function()? onMenuUpdated;

  const FoodByCategoryList({
    super.key,
    required this.menus,
    this.onMenuUpdated,
  });

  @override
  Widget build(BuildContext context) {
    // Nhóm món theo categoryID
    Map<int?, List<Menu>> groupedMenus = {};
    for (var menu in menus) {
      groupedMenus.putIfAbsent(menu.categoryID, () => []);
      groupedMenus[menu.categoryID]!.add(menu);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedMenus.entries.map((entry) {
          int? categoryId = entry.key;
          List<Menu> menuList = entry.value;
          String categoryName = getCategoryNameById(categoryId);

          const spacing = 12.0;
          int crossAxisCount = 2;
          double mainAxisSpacing = spacing;
          double crossAxisSpacing = spacing;
          double childAspectRatio = 0.65;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề Category
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                // Grid món ăn
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: menuList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: mainAxisSpacing,
                    crossAxisSpacing: crossAxisSpacing,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final food = menuList[index];
                    return GestureDetector(
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MenuDetailsScreen(foodID: food.foodID),
                          ),
                        );
                        if (updated == true && onMenuUpdated != null) {
                          await onMenuUpdated!();
                        }
                      },
                      child: FoodItem(menu: food),
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String getCategoryNameById(int? id) {
    if (id == null) return "Không xác định";
    if (id == 1) return "Cơm";
    if (id == 2) return "Nước";
    if (id == 3) return "Snack";
    if (id == 4) return "Mì";
    if (id == 5) return "Kem";
    return "Category $id";
  }
}
