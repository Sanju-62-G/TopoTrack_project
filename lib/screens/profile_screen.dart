import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';
import '../Goal_Engine/goal_setup.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    final String selectedGoal = GoalSetupScreen.selectedGoal;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32.h),
              _buildHeader(context),
              SizedBox(height: 32.h),
              _buildProgressOverview(),
              SizedBox(height: 24.h),
              _buildGoalSection(selectedGoal),
              SizedBox(height: 24.h),
              Text(
                'Settings',
                style: GoogleFonts.interTight(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4F200D),
                ),
              ),
              SizedBox(height: 16.h),
              _buildSettingsOption(
                Icons.person_outline_rounded, 
                'Personal Information',
                onTap: () => Navigator.pushNamed(context, '/personal_info'),
              ),
              _buildSettingsOption(
                Icons.track_changes_rounded, 
                'Goal & Mood Setting',
                onTap: () => Navigator.pushNamed(context, '/goal_mood'),
              ),
              _buildSettingsOption(
                Icons.security_rounded, 
                'Security & Privacy',
                onTap: () => Navigator.pushNamed(context, '/security_privacy'),
              ),
              SizedBox(height: 32.h),
              CustomButton(
                content: 'Logout',
                width: double.infinity,
                variant: 'destructive',
                onPressed: () async {
                  await AuthService.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                },
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final String fullName = user?.userMetadata?['full_name'] ?? 'User';
    final String email = user?.email ?? 'No email';

    return Row(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFF9A00), width: 2),
            image: const DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/300'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 20.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fullName,
              style: GoogleFonts.interTight(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4F200D),
              ),
            ),
            Text(
              email,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF4F200D).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/personal_info'),
          icon: Icon(Icons.edit_note_rounded, color: const Color(0xFFFF9A00), size: 28.sp),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressOverview() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9846E5), Color(0xFFEAB712)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9846E5).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem('12', 'Courses'),
              _statItem('45', 'Topics Done'),
              _statItem('124h', 'Learning'),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16.w),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Level 8: Academic Master',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '2,450 XP',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.interTight(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSection(String goal) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: const Color(0xFFFFD93D).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9A00).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.flag_rounded, color: const Color(0xFFFF9A00), size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Active Goal',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  goal,
                  style: GoogleFonts.interTight(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4F200D),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 24.sp),
        ],
      ),
    );
  }

  Widget _buildSettingsOption(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.w),
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
            Icon(icon, color: const Color(0xFF4F200D).withValues(alpha: 0.7), size: 22.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4F200D),
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 14.sp),
          ],
        ),
      ),
    );
  }
}
