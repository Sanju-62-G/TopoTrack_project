import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';
import '../models/goal_setup_data.dart';
import 'academic_setup.dart';
import 'career_goal_picker.dart';

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  // Add this static variable to store the choice globally for the session
  static String selectedGoal = 'Improve my CGPA';

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  int _selectedCardIndex = -1;

  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'Improve my CGPA',
      'description': 'Get credit-weighted study plans to hit your target GPA',
      'icon': Icons.emoji_events_outlined,
    },
    {
      'title': 'Build my career path',
      'description': 'Focus on skills needed for your dream tech role',
      'icon': Icons.add_road_outlined,
    },
    {
      'title': 'Both — CGPA + Career',
      'description': 'Balance academic performance with career readiness',
      'icon': Icons.bolt_outlined,
    },
  ];

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
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  ...List.generate(_goals.length, (index) => _buildGoalCard(index)),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 32.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9A00),
              borderRadius: BorderRadius.circular(20.w),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x33000000),
                  blurRadius: 5.w,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.track_changes, color: Colors.white, size: 24.sp),
                SizedBox(width: 8.w),
                Icon(Icons.star, color: Colors.white, size: 18.sp),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "What's your main goal?",
            textAlign: TextAlign.center,
            style: GoogleFonts.interTight(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4F200D),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "We'll personalize your experience based on your answer",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF4F200D),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(int index) {
    bool isSelected = _selectedCardIndex == index;
    final goal = _goals[index];

    return GestureDetector(
      onTap: () => setState(() => _selectedCardIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F1E9),
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9A00) : const Color(0xFFFFD93D),
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 5.w,
              color: isSelected 
                ? const Color(0xFFFF9A00).withAlpha(51)
                : const Color(0x33000000),
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9A00).withAlpha(25),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Icon(
                goal['icon'],
                color: const Color(0xFFFF9A00),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4F200D),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    goal['description'],
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: const Color(0xFF4F200D).withAlpha(180),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF9A00) : const Color(0xFFFFD93D),
                  width: 2.w,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9.w,
                        height: 9.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFF9A00),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    final String? semester = ModalRoute.of(context)?.settings.arguments as String?;
    
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E9),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            content: 'Continue',
            width: double.infinity,
            onPressed: _selectedCardIndex != -1
                ? () {
                    final selectedGoalText = _goals[_selectedCardIndex]['title'];
                    
                    // Initialize data object
                    final goalData = GoalSetupData(
                      selectedGoal: selectedGoalText,
                      semester: semester,
                    );

                    // Update global static for backward compatibility if needed
                    GoalSetupScreen.selectedGoal = selectedGoalText;

                    if (!context.mounted) return;

                    if (_selectedCardIndex == 0) {
                      // Improve my CGPA -> Academic Setup
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AcademicSetupScreen(goalData: goalData),
                        ),
                      );
                    } else {
                      // Career or Both -> Career Picker
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CareerGoalPickerScreen(goalData: goalData),
                        ),
                      );
                    }
                  }
                : null,
            size: 'medium',
          ),
          SizedBox(height: 16.h),
          Text(
            "You can change this anytime in Settings",
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: const Color(0xFF4F200D).withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }
}
