import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = 'Search here...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade500),
          const SizedBox(width: 12),

          
          Expanded(
            child: Center(
              child: TextField(
                controller: controller,
                textAlignVertical: TextAlignVertical.center,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  isDense: true,
                  suffixIcon: controller.text.isEmpty
                      ? null
                      : GestureDetector(
                          onTap: () {
                            controller.clear();
                            if (onChanged != null) onChanged!('');
                          },
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.grey.shade500,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
