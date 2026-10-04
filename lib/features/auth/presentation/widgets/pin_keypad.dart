import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PinKeypad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;

  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  static const double _keySize = 78; // tasarımdaki 74-86px dokunma hedefi

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    row
                        .map(
                          (d) => _KeyButton(label: d, onTap: () => onDigit(d)),
                        )
                        .toList(),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: _keySize, height: _keySize),
              _KeyButton(label: '0', onTap: () => onDigit('0')),
              _KeyButton(icon: Icons.backspace_outlined, onTap: onBackspace),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _KeyButton({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: PinKeypad._keySize,
        height: PinKeypad._keySize,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
        ),
        child:
            icon != null
                ? Icon(icon, size: 28, color: AppColors.text)
                : Text(
                  label!,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
      ),
    );
  }
}
