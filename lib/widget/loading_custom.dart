import 'package:flutter/material.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(250),
        child: Image.asset(
          'Img/download-unscreen.gif',
          width: 250,
          height: 250,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

void showLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const CustomLoading(),
  );
  Future.delayed(const Duration(seconds: 2), () {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  });
}

void hideLoading(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}
