import 'package:flutter/material.dart';

class AppbarCustom extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final List<TabItem> tabs;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final double fontSize;
  final bool showBackButton;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;

  const AppbarCustom({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.tabs,
    this.backgroundColor = Colors.blue,
    this.selectedColor = Colors.white,
    this.unselectedColor = Colors.white70,
    this.fontSize = 16,
    this.showBackButton = false,
    this.leadingIcon,
    this.onLeadingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40, bottom: 8, left: 8, right: 8),
      color: backgroundColor,
      child: Row(
        children: [
          // Ưu tiên leading button
          if (leadingIcon != null)
            IconButton(
              icon: Icon(leadingIcon, color: Colors.white),
              onPressed: onLeadingPressed,
            )
          else if (showBackButton) // fallback là nút back
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(tabs.length, (index) {
                final isSelected = index == selectedIndex;
                final tab = tabs[index];
                return GestureDetector(
                  onTap: () => onTabSelected(index),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              tab.icon,
                              color: isSelected
                                  ? selectedColor
                                  : unselectedColor,
                              size: fontSize,
                            ),
                            SizedBox(width: 6),
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? selectedColor
                                    : unselectedColor,
                              ),
                            ),
                          ],
                        ),
                        if (isSelected)
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            height: 3,
                            width: 24,
                            decoration: BoxDecoration(
                              color: selectedColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 30);
}

class TabItem {
  final String label;
  final IconData icon;

  const TabItem({required this.label, required this.icon});
}
