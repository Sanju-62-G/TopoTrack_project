import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';

class AcademicRoadmap extends StatelessWidget {
  const AcademicRoadmap({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTrajectoryCard(context),
        SizedBox(height: 24.h),
        Text(
          'Semester Progression',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F200D),
          ),
        ),
        SizedBox(height: 16.h),
        _buildSemesterItem('Semester 1', 'Completed', 1.0, '3.50 GPA', 'CSE101, MAT101, ENG101'),
        _buildSemesterItem('Semester 2', 'Completed', 1.0, '3.65 GPA', 'CSE201, MAT201, PHY101'),
        _buildSemesterItem('Semester 3', 'In Progress', 0.6, 'Target: 3.80', 'CSE301, CSE305, MAT301'),
        _buildSemesterItem('Semester 4', 'Locked', 0, 'Pending', 'CSE401, CSE402, HUM101'),
        _buildSemesterItem('Semester 5', 'Locked', 0, 'Pending', 'Capstone Phase 1, Elective I'),
      ],
    );
  }

  Widget _buildTrajectoryCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: const Color(0xFFFFD93D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up_rounded, color: Color(0xFFEA580C), size: 32),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              "At this pace, you'll reach 3.85 by Semester 6",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9A3412),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterItem(String title, String status, double progress, String detail, String courses) {
    Color statusColor = status == 'Completed' 
        ? const Color(0xFF22C55E) 
        : (status == 'In Progress' ? const Color(0xFFFF9A00) : const Color(0xFF94A3B8));

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: const Color(0xFFFFD93D).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4F200D),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Courses: $courses',
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.w),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation(statusColor),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                detail,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
