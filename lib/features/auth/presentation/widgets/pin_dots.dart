import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PinDots extends StatelessWidget {
  final int filled;
  final int length;
  final bool hasError;

  const PinDots({
    super.key,
    required this.filled,
    required this.length,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final isFilled = i < filled;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 9),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isFilled
                    ? (hasError ? AppColors.danger : AppColors.accent)
                    : Colors.transparent,
            border: Border.all(
              color:
                  hasError ? AppColors.danger : AppColors.text.withOpacity(0.3),
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}
