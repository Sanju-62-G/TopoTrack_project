import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';
import '../services/course_service.dart';
import '../services/goal_service.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _creditsController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  String _selectedSemester = 'Semester 1';

  final List<String> _semesters = [
    'Semester 1', 'Semester 2', 'Semester 3', 'Semester 4',
    'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserSemester();
  }

  Future<void> _loadUserSemester() async {
    try {
      final goal = await GoalService.getUserGoal();
      if (goal != null && goal['semester'] != null) {
        if (_semesters.contains(goal['semester'])) {
          setState(() {
            _selectedSemester = goal['semester'];
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user semester: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              label: 'Course Name',
              hint: 'e.g. Data Structures',
              controller: _nameController,
            ),
            SizedBox(height: 24.h),
            _buildInputField(
              label: 'Course Code',
              hint: 'e.g. CSE201',
              controller: _codeController,
            ),
            SizedBox(height: 24.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'Credits',
                    hint: 'e.g. 3.0',
                    controller: _creditsController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildSemesterPicker(),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _buildInputField(
              label: 'Teacher (Optional)',
              hint: 'e.g. Dr. John Doe',
              controller: _teacherController,
            ),
            SizedBox(height: 40.h),
            CustomButton(
              content: 'Add Course',
              width: double.infinity,
              onPressed: _handleAddCourse,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: const Color(0xFF4F200D), size: 24.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Add New Course',
        style: GoogleFonts.interTight(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4F200D),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4F200D),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF4F200D)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w),
              borderSide: const BorderSide(color: Color(0xFFFFD93D)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w),
              borderSide: const BorderSide(color: Color(0xFFFFD93D)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w),
              borderSide: const BorderSide(color: Color(0xFFFF9A00)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Semester',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4F200D),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.w),
            border: Border.all(color: const Color(0xFFFFD93D)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSemester,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: const Color(0xFF4F200D), size: 24.sp),
              style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF4F200D)),
              items: _semesters.map((s) => DropdownMenuItem(
                value: s, 
                child: Text(s, style: GoogleFonts.inter(fontSize: 14.sp))
              )).toList(),
              onChanged: (val) => setState(() => _selectedSemester = val!),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAddCourse() async {
    if (_nameController.text.isEmpty || _codeController.text.isEmpty || _creditsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      final double? credits = double.tryParse(_creditsController.text);
      if (credits == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credits value')),
        );
        return;
      }

      await CourseService.addCourse(
        name: _nameController.text.trim(),
        courseCode: _codeController.text.trim(),
        creditHours: credits,
        semester: _selectedSemester,
        teacherName: _teacherController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
