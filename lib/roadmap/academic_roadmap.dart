import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../services/course_service.dart';
import '../services/gpa_service.dart';

class AcademicRoadmap extends StatefulWidget {
  const AcademicRoadmap({super.key});

  @override
  State<AcademicRoadmap> createState() => _AcademicRoadmapState();
}

class _AcademicRoadmapState extends State<AcademicRoadmap> {
  Map<String, List<Map<String, dynamic>>> _coursesBySemester = {};
  double _currentCgpa = 0.0;
  double _targetCgpa = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final courses = await CourseService.getCourses();
      final cgpaData = await GpaService.getCgpaData();
      
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var course in courses) {
        final sem = course['semester'] ?? 'Semester 1';
        if (!grouped.containsKey(sem)) grouped[sem] = [];
        grouped[sem]!.add(course);
      }

      setState(() {
        _coursesBySemester = grouped;
        if (cgpaData != null) {
          _currentCgpa = (cgpaData['current_cgpa'] ?? 0.0).toDouble();
          _targetCgpa = (cgpaData['target_cgpa'] ?? 0.0).toDouble();
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading academic roadmap: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF9A00)));
    }

    final semesters = _coursesBySemester.keys.toList();
    semesters.sort(); // Sort Semester 1, 2, 3...

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTrajectoryCard(),
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
        if (semesters.isEmpty)
          _buildEmptyState()
        else
          ...semesters.map((sem) {
            final courses = _coursesBySemester[sem]!;
            final courseNames = courses.map((c) => c['course_code']).join(', ');
            return _buildSemesterItem(
              sem, 
              'Active Plan', 
              1.0, 
              '${courses.length} Courses', 
              courseNames
            );
          }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(Icons.history_edu_rounded, size: 48.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text('No courses added to your planner yet.', style: GoogleFonts.inter(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrajectoryCard() {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Goal Projection",
                  style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF9A3412)),
                ),
                Text(
                  "Current: $_currentCgpa → Target: $_targetCgpa",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9A3412),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterItem(String title, String status, double progress, String detail, String courses) {
    Color statusColor = const Color(0xFFFF9A00);

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
            'Codes: $courses',
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
