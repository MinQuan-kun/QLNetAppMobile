import 'package:flutter/material.dart';

class MyInventoryScreen extends StatefulWidget {
  @override
  State<MyInventoryScreen> createState() => _FormMyInventory();
}

class _FormMyInventory extends State<MyInventoryScreen> {
  String selectedCategory = "Tất cả";

  final List<String> categories = [
    "Phiếu giảm giá",
    "Vật phẩm",
    "Tất cả",
  ];

  // Hien thi so o vat pham
  final List<String> dummyItems = List.generate(50, (index) => "");

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,  // responsive
        height: MediaQuery.of(context).size.height * 0.8,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
        ),
        child: Row(
          children: [
            // Bên trái: các nút danh mục
            Container(
              width: 100,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: categories.map((cat) {
                  final bool isSelected = cat == selectedCategory;
                  return Padding(
                    padding:  EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedCategory = cat;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding:  EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Text("Đang Update !!!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.red

                ),),
              ),
            )

            // Bên phải: danh sách vật phẩm dạng ô vuông
            // Expanded(
            //   child: Padding(
            //     padding: const EdgeInsets.all(14),
            //     child: GridView.builder(
            //       itemCount: dummyItems.length,
            //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //         crossAxisCount: 4,
            //         mainAxisSpacing: 8,
            //         crossAxisSpacing: 5,
            //         childAspectRatio: 1,
            //       ),
            //       itemBuilder: (context, index) {
            //         return Container(
            //           decoration: BoxDecoration(
            //             color: Colors.grey.shade200,
            //             borderRadius: BorderRadius.circular(8),
            //             border: Border.all(color: Colors.grey.shade400),
            //           ),
            //         );
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
