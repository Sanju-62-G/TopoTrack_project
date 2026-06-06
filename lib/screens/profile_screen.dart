import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';
import '../Goal_Engine/goal_setup.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';
import '../services/topic_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  // Dynamic Stats
  int _coursesCount = 0;
  int _topicsDoneCount = 0;
  double _learningHours = 0;
  int _userLevel = 1;
  int _userXp = 0;
  String _levelName = 'Academic Novice';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final courses = await CourseService.getCourses();
      int completedTopics = 0;
      double totalHours = 0;

      for (var course in courses) {
        final topics = await TopicService.getTopics(course['id'].toString());
        for (var topic in topics) {
          if (topic['is_completed'] == true) {
            completedTopics++;
            totalHours += (topic['estimated_hours'] ?? 0.0).toDouble();
          }
        }
      }

      if (mounted) {
        setState(() {
          _coursesCount = courses.length;
          _topicsDoneCount = completedTopics;
          _learningHours = totalHours;
          
          // Calculate level and XP (same logic as dashboard for consistency)
          _userLevel = (completedTopics / 10).floor() + 1;
          _userXp = (completedTopics % 10) * 250 + (totalHours * 5).toInt();
          _levelName = _getLevelName(_userLevel);
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  String _getLevelName(int level) {
    if (level >= 10) return 'Academic Legend';
    if (level >= 8) return 'Academic Master';
    if (level >= 5) return 'Scholar';
    if (level >= 3) return 'Advanced Student';
    return 'Academic Novice';
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await AuthService.instance.getUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
        if (profile?['selected_goal'] != null) {
          GoalSetupScreen.selectedGoal = profile!['selected_goal'];
        }
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    final String selectedGoal = GoalSetupScreen.selectedGoal;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF9A00)))
          : RefreshIndicator(
              onRefresh: _loadProfile,
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
                      onTap: () async {
                        await Navigator.pushNamed(context, '/personal_info');
                        _loadProfile();
                      },
                    ),
                    _buildSettingsOption(
                      Icons.track_changes_rounded, 
                      'Goal & Mood Setting',
                      onTap: () async {
                        final result = await Navigator.pushNamed(context, '/goal_mood');
                        if (result == true) _loadProfile();
                      },
                    ),
                    _buildSettingsOption(
                      Icons.security_rounded, 
                      'Security & Privacy',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/security_privacy');
                        _loadProfile();
                      },
                    ),
                    _buildSettingsOption(
                      Icons.delete_forever_rounded, 
                      'Delete Account',
                      onTap: () async {
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Account'),
                            content: const Text('Are you sure you want to delete your account? This action is irreversible and all your data will be lost.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          setState(() => _isLoading = true);
                          try {
                            await AuthService.instance.deleteAccount();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                              setState(() => _isLoading = false);
                            }
                          }
                        }
                      },
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final String fullName = _userProfile?['full_name'] ?? 'User';
    final String email = _userProfile?['email'] ?? 'No email';

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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: GoogleFonts.interTight(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4F200D),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                email,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: const Color(0xFF4F200D).withValues(alpha: 0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () async {
            await Navigator.pushNamed(context, '/personal_info');
            _loadProfile();
          },
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
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 24.w, 24.w, 12.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF9846E5),
            Color(0xFFEAB712),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statItem(_coursesCount.toString(), 'Courses'),
                _statItem(_topicsDoneCount.toString(), 'Topics Done'),
                _statItem('${_learningHours.toInt()}h', 'Learning'),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Level $_userLevel: $_levelName',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_userXp.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} XP',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
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
