import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';

class DeadlineItem extends StatelessWidget {
  final Color? accentColor;
  final String? title;
  final String? course;
  final String? time;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const DeadlineItem({
    super.key,
    this.accentColor,
    this.title,
    this.course,
    this.time,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1E9),
        boxShadow: [
          BoxShadow(
            blurRadius: 5.w,
            color: const Color(0x33000000),
            offset: Offset(0, 2.h),
          )
        ],
        borderRadius: BorderRadius.circular(12.w),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: const Color(0xFFFFD93D),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 4.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: accentColor ?? const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(9999),
                shape: BoxShape.rectangle,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? 'Algorithm Analysis Quiz',
                    maxLines: 1,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4F200D),
                      letterSpacing: 0.0,
                      height: 1.5,
                      fontSize: 14.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${course ?? 'Course'} · ${time ?? 'Time'}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF64748B),
                      fontSize: 11.sp,
                      letterSpacing: 0.0,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: const Color(0xFF94A3B8), size: 20.sp),
              padding: EdgeInsets.zero,
              color: const Color(0xFFF6F1E9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
              onSelected: (value) {
                if (value == 'edit' && onEdit != null) {
                  onEdit!();
                } else if (value == 'delete' && onDelete != null) {
                  onDelete!();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18.sp, color: const Color(0xFF4F200D)),
                      SizedBox(width: 8.w),
                      Text('Edit', style: GoogleFonts.inter(fontSize: 13.sp)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 18.sp, color: Colors.red),
                      SizedBox(width: 8.w),
                      Text('Delete', style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
