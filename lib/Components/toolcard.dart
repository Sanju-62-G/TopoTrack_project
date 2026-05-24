import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';

class ToolCard extends StatelessWidget {
  final Color? bgTint;
  final Widget? icon;
  final String? title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final VoidCallback? onTap;
  final bool isSelected;

  final double? width;
  final double? height;

  const ToolCard({
    super.key,
    this.bgTint,
    this.icon,
    this.title,
    this.subtitle,
    this.subtitleWidget,
    this.onTap,
    this.isSelected = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width ?? 165.w,
        constraints: BoxConstraints(
          minHeight: height ?? 150.h,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F1E9),
          boxShadow: [
            BoxShadow(
              blurRadius: 5.w,
              color: isSelected ? const Color(0xFFFF9A00).withAlpha(51) : const Color(0x33000000),
              offset: Offset(0, 2.h),
            )
          ],
          borderRadius: BorderRadius.circular(20.w),
          shape: BoxShape.rectangle,
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9A00) : const Color(0xFFFFD93D),
            width: isSelected ? 2.w : 1.w,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: bgTint ?? const Color(0xFFFFE789),
                  borderRadius: BorderRadius.circular(12.w),
                  shape: BoxShape.rectangle,
                ),
                alignment: const AlignmentDirectional(0, 0),
                child: icon,
              ),
              SizedBox(height: 8.h),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? 'Planner',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4F200D),
                      fontSize: 14.sp,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  subtitleWidget ?? Text(
                    subtitle ?? 'Manage Courses',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF4F200D),
                      fontSize: 11.sp,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
