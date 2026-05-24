import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return Padding(
      padding: EdgeInsets.all(32.0.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 100.sp,
            color: const Color(0xFFFF9A00),
          ),
          SizedBox(height: 48.h),
          Text(
            'Smart Study Planning',
            style: GoogleFonts.poppins(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF491706),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Organize your semesters, courses, and study goals with an automated intelligent framework.',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: const Color(0xFF491706),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
