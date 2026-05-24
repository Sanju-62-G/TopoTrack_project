import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Goal_Engine/goal_setup.dart';
import 'academic_roadmap.dart';
import 'career_roadmap.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  late String _activeMode;
  late String _globalGoal;

  @override
  void initState() {
    super.initState();
    _globalGoal = GoalSetupScreen.selectedGoal;
    _activeMode = _globalGoal;
    
    // Default sub-mode for "Both"
    if (_globalGoal == 'Both — CGPA + Career') {
      _activeMode = 'Improve my CGPA';
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModeSwitcher(),
                  SizedBox(height: 24.h),
                  if (_activeMode == 'Improve my CGPA') const AcademicRoadmap(),
                  if (_activeMode == 'Build my career path') const CareerRoadmap(),
                ],
              ),
            ),
          ),
        ],
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
            'Future Roadmap',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4F200D),
            ),
          ),
          IconButton(
            icon: Icon(Icons.share_rounded, color: const Color(0xFF491706), size: 24.sp),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitcher() {
    if (_globalGoal != 'Both — CGPA + Career') return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xFFFFD93D)),
      ),
      child: Row(
        children: [
          _buildModeTab('Academic', 'Improve my CGPA'),
          _buildModeTab('Career', 'Build my career path'),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, String goalValue) {
    bool isActive = _activeMode == goalValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeMode = goalValue),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFF9A00) : Colors.transparent,
            borderRadius: BorderRadius.circular(8.w),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF4F200D) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
