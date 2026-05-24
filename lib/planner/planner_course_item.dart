import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';

class PlannerCourseItem extends StatelessWidget {
  final Map<String, dynamic> course;
  final String activeMode;
  final VoidCallback? onTap;

  const PlannerCourseItem({
    super.key,
    required this.course,
    required this.activeMode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double credits = (course['credit_hours'] ?? 0.0).toDouble();
    final String priority = _calculatePriority(credits);
    final Color priorityColor = _getPriorityColor(priority);
    final String studySuggestion = _getStudySuggestion(credits);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(color: const Color(0xFFFFD93D)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['name'] ?? 'Untitled Course',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4F200D),
                        ),
                      ),
                      Text(
                        course['course_code'] ?? 'No Code',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPriorityBadge(priority, priorityColor),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                if (activeMode == 'Improve my CGPA' || activeMode == 'Both — CGPA + Career')
                  _buildInfoBadge('$credits cr', const Color(0xFFF1F5F9), const Color(0xFF475569)),
                
                if (activeMode == 'Build my career path' || activeMode == 'Both — CGPA + Career')
                  (course['is_career_relevant'] == true)
                      ? _buildInfoBadge('Career Relevant', const Color(0xFFFFF7ED), const Color(0xFFEA580C))
                      : _buildInfoBadge('General', const Color(0xFFF1F5F9), const Color(0xFF94A3B8)),
                
                if (course['teacher_name'] != null && course['teacher_name'].toString().isNotEmpty)
                  _buildInfoBadge(course['teacher_name'], const Color(0xFFDCFCE7), const Color(0xFF166534)),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF64748B)),
                SizedBox(width: 4.w),
                Text(
                  'Suggestion: $studySuggestion',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String label, Color bg, Color text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  String _calculatePriority(double credits) {
    bool isCareerRelevant = course['is_career_relevant'] == true;
    
    if (activeMode == 'Improve my CGPA') {
      if (credits >= 3.0) return 'High';
      if (credits >= 2.0) return 'Medium';
      return 'Low';
    } else if (activeMode == 'Build my career path') {
      return isCareerRelevant ? 'High' : 'Medium';
    } else {
      // Both
      if (isCareerRelevant && credits >= 3.0) return 'Highest';
      if (isCareerRelevant || credits >= 3.0) return 'High';
      if (credits >= 2.0) return 'Medium';
      return 'Low';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Highest':
        return const Color(0xFFEF4444);
      case 'High':
        return const Color(0xFFF97316);
      case 'Medium':
        return const Color(0xFFEAB308);
      case 'Low':
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _getStudySuggestion(double credits) {
    if (credits >= 3.0) return 'Focus daily (2+ hrs)';
    if (credits >= 2.0) return 'Review 3x / week';
    return 'Weekend review sufficient';
  }
}
