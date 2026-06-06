import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../services/course_service.dart';
import 'dag_graph_screen.dart';

class VisualPathsScreen extends StatefulWidget {
  const VisualPathsScreen({super.key});

  @override
  State<VisualPathsScreen> createState() => _VisualPathsScreenState();
}

class _VisualPathsScreenState extends State<VisualPathsScreen> {
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await CourseService.getCourses();
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading courses for DAG: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      appBar: AppBar(
        title: Text(
          'Learning Paths',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF4F200D)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF4F200D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF9A00)))
        : _courses.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(24.w),
              itemCount: _courses.length,
              itemBuilder: (context, index) => _buildCourseCard(_courses[index]),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_rounded, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            'No courses found',
            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add courses in the Planner to see their graphs',
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DAGGraphScreen(
              courseId: course['id'].toString(),
              courseName: course['name'],
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(color: const Color(0xFFFFD93D).withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9A00).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_tree_rounded, color: const Color(0xFFFF9A00), size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['name'],
                    style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF4F200D)),
                  ),
                  Text(
                    course['course_code'],
                    style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 16.sp),
          ],
        ),
      ),
    );
  }
}
