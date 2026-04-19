import 'package:flutter/material.dart';

class InkWellCustom extends StatelessWidget {
  final String? title;
  final String? iconPath;
  final Color color;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final double fontSize;
  final double? iconSize;

  const InkWellCustom({
    super.key,
    this.title,
    this.iconPath,
    required this.color,
    required this.onTap,
    this.width,
    this.height,
    this.fontSize = 25,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(40),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconPath != null)
              iconSize != null
                  ? Image.asset(iconPath!, width: iconSize, height: iconSize)
                  : Image.asset(iconPath!),
            if (iconPath != null && title != null) SizedBox(width: 8),
            if (title != null)
              Text(
                title!,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FloatingButtonCustom extends StatelessWidget {
  final VoidCallback onPressed;
  final ImageProvider avatar;
  final double size;
  final Color backgroundColor;

  const FloatingButtonCustom({
    super.key,
    required this.onPressed,
    required this.avatar,
    this.size = 40.0,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        elevation: 4,
        shape: CircleBorder(),
        child: CircleAvatar(backgroundImage: avatar, radius: size / 2 - 4),
      ),
    );
  }
}
