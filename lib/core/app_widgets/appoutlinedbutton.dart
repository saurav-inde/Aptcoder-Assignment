import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/config/theme.dart';
import 'package:flutter/material.dart';

class AppOutlinedButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onTap;

  const AppOutlinedButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12), 
          border: Border.all(
            color: primaryColor,
            width: 1.5, 
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(data: const IconThemeData(size: 20), child: icon),
            const SizedBox(width: 8),
            AppText.interLarge(
              label,
              color: primaryColor,
              weight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}
