import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';
import '../services/gpa_service.dart';

class GpaSimulatorScreen extends StatefulWidget {
  const GpaSimulatorScreen({super.key});

  static String routeName = 'GPASimulator';
  static String routePath = '/gPASimulator';

  @override
  State<GpaSimulatorScreen> createState() => _GpaSimulatorScreenState();
}

class _GpaSimulatorScreenState extends State<GpaSimulatorScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<Map<String, dynamic>> _courses = [];
  Map<String, double> _targetGrades = {};
  double _currentCgpa = 0.0;
  double _targetCgpa = 0.0;
  double _simulatedCgpa = 0.0;
  int _completedCredits = 50; // Default fallback
  bool _isLoading = true;

  final List<String> _gradeOptions = [
    'A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'D', 'F'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final cgpaData = await GpaService.getCgpaData();
      final courses = await GpaService.getCurrentCourses();

      Map<String, double> grades = {};
      for (var course in courses) {
        grades[course['id'].toString()] = 4.0; // Default to A
      }

      setState(() {
        if (cgpaData != null) {
          _currentCgpa = (cgpaData['current_cgpa'] ?? 0.0).toDouble();
          _targetCgpa = (cgpaData['target_cgpa'] ?? 0.0).toDouble();
        }
        _courses = courses;
        _targetGrades = grades;
        _isLoading = false;
      });

      _simulate();
    } catch (e) {
      debugPrint('Error loading simulator data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _simulate() {
    final simulated = GpaService.simulateGpa(
      courses: _courses,
      targetGrades: _targetGrades,
      currentCgpa: _currentCgpa,
      completedCredits: _completedCredits,
    );

    setState(() => _simulatedCgpa = simulated);
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F1E9),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF9A00))),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF6F1E9),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    _buildCgpaStats(),
                    SizedBox(height: 24.h),
                    _buildCourseSection(),
                    SizedBox(height: 32.h),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E9),
        border: Border(bottom: BorderSide(color: Color(0xFFFF9A00), width: 1)),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 48.h, 16.w, 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: const Color(0xFF4F200D), size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'GPA Simulator',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4F200D),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: const Color(0xFF491706), size: 24.sp),
            onPressed: _loadData,
          ),
        ],
      ),
    );
  }

  Widget _buildCgpaStats() {
    double diff = _simulatedCgpa - _currentCgpa;
    bool isPositive = diff >= 0;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.w),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Current', _currentCgpa.toStringAsFixed(2), Colors.grey),
              _buildStatItem(
                'Simulated', 
                _simulatedCgpa.toStringAsFixed(2), 
                isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444)
              ),
              _buildStatItem('Target', _targetCgpa.toStringAsFixed(2), const Color(0xFFFF9A00)),
            ],
          ),
          if (_courses.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Text(
              _simulatedCgpa >= _targetCgpa 
                ? 'On track to hit your goal! Keep up these grades.' 
                : 'You need higher grades to reach your target of ${_targetCgpa.toStringAsFixed(2)}.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.sp, 
                color: const Color(0xFF4F200D).withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Semester Courses',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F200D),
          ),
        ),
        SizedBox(height: 16.h),
        if (_courses.isEmpty)
          _buildEmptyCourses()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _courses.length,
            itemBuilder: (context, index) => _buildCourseRow(_courses[index]),
          ),
      ],
    );
  }

  Widget _buildEmptyCourses() {
    return Container(
      padding: EdgeInsets.all(24.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: const Color(0xFFFFD93D).withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 40.sp, color: Colors.grey),
          SizedBox(height: 12.h),
          Text(
            'No courses found for this semester',
            style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),
          ),
          SizedBox(height: 8.h),
          CustomButton(
            content: 'Add Courses in Planner',
            variant: 'ghost',
            size: 'small',
            onPressed: () => Navigator.pushNamed(context, '/planner'),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseRow(Map<String, dynamic> course) {
    final String courseId = course['id'].toString();
    final double currentGrade = _targetGrades[courseId] ?? 4.0;

    String currentLetter = _gradeOptions.firstWhere(
      (g) => GpaService.gradeToPoint(g) == currentGrade,
      orElse: () => 'A',
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: const Color(0xFFFFD93D).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['name'] ?? 'Untitled',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: const Color(0xFF4F200D),
                  ),
                ),
                Text(
                  '${course['course_code']} • ${course['credit_hours']} Credits',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6EE),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentLetter,
                icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18.sp, color: const Color(0xFFFF9A00)),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF9A00),
                ),
                items: _gradeOptions.map((grade) {
                  return DropdownMenuItem(value: grade, child: Text(grade));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _targetGrades[courseId] = GpaService.gradeToPoint(value);
                    });
                    _simulate();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        CustomButton(
          content: 'Save Simulation Results',
          width: double.infinity,
          onPressed: _simulatedCgpa > 0 ? () async {
            try {
              await GpaService.updateCurrentCgpa(_simulatedCgpa);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Current CGPA updated successfully!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating CGPA: $e')),
              );
            }
          } : null,
        ),
        SizedBox(height: 16.h),
        Text(
          'Saving will update your baseline CGPA in your profile.',
          style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey),
        ),
      ],
    );
  }
}
