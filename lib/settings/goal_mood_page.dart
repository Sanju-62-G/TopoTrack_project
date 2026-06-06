import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';
import '../services/goal_service.dart';
import '../Goal_Engine/goal_setup.dart';

class GoalMoodPage extends StatefulWidget {
  const GoalMoodPage({super.key});

  @override
  State<GoalMoodPage> createState() => _GoalMoodPageState();
}

class _GoalMoodPageState extends State<GoalMoodPage> {
  String _selectedGoal = GoalSetupScreen.selectedGoal;
  String? _careerGoal;
  double _targetCgpa = 3.5;
  double _priorityRatio = 0.5;
  String _moodIntensity = 'Balanced';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    try {
      final goalData = await GoalService.getUserGoal();
      if (goalData != null) {
        setState(() {
          _selectedGoal = goalData['selected_goal'] ?? GoalSetupScreen.selectedGoal;
          _careerGoal = goalData['career_goal'];
          _targetCgpa = (goalData['target_cgpa'] as num?)?.toDouble() ?? 3.5;
          _priorityRatio = (goalData['cgpa_priority_ratio'] as num?)?.toDouble() ?? 0.5;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading goal: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _applyPreferences() async {
    setState(() => _isLoading = true);
    try {
      await GoalService.updateGoal(
        selectedGoal: _selectedGoal,
        careerGoal: _careerGoal,
        targetCgpa: _targetCgpa,
        cgpaPriorityRatio: _priorityRatio,
      );
      
      GoalSetupScreen.selectedGoal = _selectedGoal;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences applied!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      appBar: _buildAppBar(context),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF9A00)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Active Tracking Goal'),
                  SizedBox(height: 16.h),
                  _buildGoalOption('Improve my CGPA', Icons.school_rounded),
                  _buildGoalOption('Build my career path', Icons.work_rounded),
                  _buildGoalOption('Both — CGPA + Career', Icons.auto_awesome_rounded),
                  if (_selectedGoal != 'Build my career path') ...[
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Target CGPA'),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _targetCgpa,
                            min: 2.0,
                            max: 4.0,
                            divisions: 20,
                            label: _targetCgpa.toStringAsFixed(2),
                            activeColor: const Color(0xFFFF9A00),
                            onChanged: (val) => setState(() => _targetCgpa = val),
                          ),
                        ),
                        Text(
                          _targetCgpa.toStringAsFixed(2),
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                  if (_selectedGoal == 'Both — CGPA + Career') ...[
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Priority Focus'),
                    SizedBox(height: 8.h),
                    Text(
                      'Balance between CGPA and Career preparation',
                      style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Career', style: GoogleFonts.inter(fontSize: 12.sp)),
                        Expanded(
                          child: Slider(
                            value: _priorityRatio,
                            onChanged: (val) => setState(() => _priorityRatio = val),
                            activeColor: const Color(0xFF9846E5),
                          ),
                        ),
                        Text('CGPA', style: GoogleFonts.inter(fontSize: 12.sp)),
                      ],
                    ),
                  ],
                  SizedBox(height: 32.h),
                  _buildSectionTitle('Mood-Based Guidance'),
                  SizedBox(height: 12.h),
                  Text(
                    'How should the AI adjust your schedule when you are feeling low?',
                    style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 20.h),
                  _buildMoodSelector(),
                  SizedBox(height: 40.h),
                  CustomButton(
                    content: 'Apply Preferences',
                    width: double.infinity,
                    onPressed: _applyPreferences,
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
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFF4F200D), size: 20.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Goal & Mood Setting',
        style: GoogleFonts.interTight(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4F200D),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.interTight(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF4F200D).withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildGoalOption(String goal, IconData icon) {
    bool isSelected = _selectedGoal == goal;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goal),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF9A00).withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9A00) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFFF9A00) : Colors.grey, size: 22.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                goal,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4F200D),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: const Color(0xFFFF9A00), size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    final List<String> modes = ['Gentle', 'Balanced', 'Strict'];
    return Row(
      children: modes.map((mode) {
        bool isSelected = _moodIntensity == mode;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _moodIntensity = mode),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4F200D) : Colors.white,
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
              ),
              child: Text(
                mode,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
