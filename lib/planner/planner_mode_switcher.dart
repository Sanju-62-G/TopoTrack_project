import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Goal_Engine/goal_setup.dart';

class PlannerModeSwitcher extends StatelessWidget {
  final String activeMode;
  final Function(String) onModeChanged;

  const PlannerModeSwitcher({
    super.key,
    required this.activeMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final String globalGoal = GoalSetupScreen.selectedGoal;
    
    // Define available tabs based on the global goal
    List<Widget> tabs = [];
    
    if (globalGoal == 'Both — CGPA + Career') {
      tabs.add(_buildModeTab('CGPA', 'Improve my CGPA'));
      tabs.add(_buildModeTab('Career', 'Build my career path'));
    } else {
      // For single goal modes, we don't need a switcher as there's only one option
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xFFFFD93D)),
      ),
      child: Row(
        children: tabs,
      ),
    );
  }

  Widget _buildModeTab(String label, String goalValue) {
    bool isActive = activeMode == goalValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(goalValue),
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
