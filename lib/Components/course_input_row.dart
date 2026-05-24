import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';

class CourseInputRow extends StatelessWidget {
  final String name;
  final String code;
  final String credits;
  final double grade;

  const CourseInputRow({
    super.key,
    required this.name,
    required this.code,
    required this.credits,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xFFFFD93D)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4F200D),
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  '$code • $credits Credits',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
