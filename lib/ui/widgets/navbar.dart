import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/config/theme.dart';
import 'package:flutter/material.dart';

class BottomDockNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomDockNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          height: 60,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.school_rounded,
                label: 'My Learning',
                isActive: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? primaryColor : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 2),
          AppText.interMini(
            label,
            color: color,
            weight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}
