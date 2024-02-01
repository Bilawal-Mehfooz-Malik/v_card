import 'package:flutter/material.dart';

class BottomSheetButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const BottomSheetButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context);
    final lightMode = style.brightness == Brightness.light;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: lightMode
                    ? Colors.grey.shade300
                    : const Color.fromARGB(255, 53, 53, 53),
              ),
            ),
            child: Icon(
              icon,
              size: 30,
              color: lightMode
                  ? style.colorScheme.error
                  : style.colorScheme.primaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style:
                TextStyle(color: lightMode ? Colors.black45 : Colors.white70),
          ),
        ],
      ),
    );
  }
}
