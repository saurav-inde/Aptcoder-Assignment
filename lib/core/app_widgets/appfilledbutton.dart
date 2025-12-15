import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/config/theme.dart';
import 'package:flutter/material.dart';

class AppFilledButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onTap;

  const AppFilledButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12), 
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 8),
            AppText.interLarge(
              label,
              color: Colors.white,
              weight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}
