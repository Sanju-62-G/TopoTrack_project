import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.content = 'Continue',
    this.onPressed,
    this.loading = false,
    this.size = 'medium',
    this.variant = 'primary',
    this.icon,
    this.iconEnd,
    this.iconPresent = false,
    this.iconEndPresent = false,
    this.width,
  });

  final String content;
  final VoidCallback? onPressed;
  final bool loading;
  final String size; // 'small', 'medium', 'large'
  final String variant;
  final Widget? icon;
  final Widget? iconEnd;
  final bool iconPresent;
  final bool iconEndPresent;
  final double? width;

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);

    double fontSize;
    double horizontalPadding;
    double verticalPadding;
    double borderRadius = 16.0.w;

    switch (size) {
      case 'small':
        fontSize = 14.0.sp;
        horizontalPadding = 16.0.w;
        verticalPadding = 8.0.h;
        break;
      case 'large':
        fontSize = 18.0.sp;
        horizontalPadding = 32.0.w;
        verticalPadding = 16.0.h;
        break;
      default: // medium
        fontSize = 16.0.sp;
        horizontalPadding = 24.0.w;
        verticalPadding = 12.0.h;
    }

    Color backgroundColor;
    Color textColor;
    Border? border;

    switch (variant) {
      case 'secondary':
        backgroundColor = const Color(0xFFE2E8F0);
        textColor = const Color(0xFF1E293B);
        break;
      case 'outline':
        backgroundColor = Colors.transparent;
        textColor = const Color(0xFF4F46E5);
        border = Border.all(color: const Color(0xFF4F46E5), width: 1.5);
        break;
      case 'ghost':
        backgroundColor = Colors.transparent;
        textColor = const Color(0xFFFF9A00);
        break;
      case 'destructive':
        backgroundColor = const Color(0xFFEF4444);
        textColor = Colors.white;
        break;
      default: // primary
        backgroundColor = const Color(0xFFFF9A00);
        textColor = const Color(0xFF4F200D);
    }

    return SizedBox(
      width: width,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: border,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: loading ? 0.0 : 1.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (iconPresent && icon != null) ...[
                        icon!,
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        content,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      if (iconEndPresent && iconEnd != null) ...[
                        SizedBox(width: 8.w),
                        iconEnd!,
                      ],
                    ],
                  ),
                ),
                if (loading)
                  SizedBox(
                    width: fontSize * 1.5,
                    height: fontSize * 1.5,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
