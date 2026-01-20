import 'package:flutter/material.dart';
import 'package:cotiza_ya/core/constants/text_styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  
  const SectionTitle({
    super.key,
    required this.title,
    this.trailing,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.h3,
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
