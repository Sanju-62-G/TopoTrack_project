import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class AppLogo extends StatelessWidget {
  final double? iconSize;
  final double? fontSize;
  final bool showText;

  const AppLogo({
    super.key,
    this.iconSize,
    this.fontSize,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize responsive utils if not already
    Responsive().init(context);

    final double effectiveIconSize = iconSize ?? 30.sp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: effectiveIconSize * 1.6,
          height: effectiveIconSize * 1.6,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9A00),
            borderRadius: BorderRadius.circular(effectiveIconSize * 0.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.hub_rounded,
            color: const Color(0xFFFFF8E8),
            size: effectiveIconSize,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
