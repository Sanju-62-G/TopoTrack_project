import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Goal_Engine/goal_setup.dart';
import '../services/scheduler_service.dart';
import '../services/topic_service.dart';
import '../utils/side_panel.dart';
import 'add_task_screen.dart';

class SchedulerScreen extends StatefulWidget {
  const SchedulerScreen({super.key});

  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  int _selectedDateIndex = 0;
  late String _optimizationMode;
  List<Map<String, dynamic>> _schedule = [];
  bool _isLoading = true;
  double _dailyHours = 4.0;

  late final List<Map<String, String>> _dates = _buildWeekDates();

  List<Map<String, String>> _buildWeekDates() {
    final now = DateTime.now();
    // এই সপ্তাহের Monday খোঁজো
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return {
        'day': dayNames[i],
        'date': day.day.toString(),
      };
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDateIndex = DateTime.now().weekday - 1; // 0=Mon, 6=Sun
    _initializeDefaultMode();
    _loadSchedule();
  }

  void _initializeDefaultMode() {
    String globalGoal = GoalSetupScreen.selectedGoal;
    if (globalGoal == 'Both — CGPA + Career') {
      _optimizationMode = 'Balanced';
    } else if (globalGoal == 'Improve my CGPA') {
      _optimizationMode = 'CGPA Focus';
    } else if (globalGoal == 'Build my career path') {
      _optimizationMode = 'Career Focus';
    } else {
      _optimizationMode = 'Balanced';
    }
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    try {
      final weighted = await SchedulerService.generateSchedule();
      final schedule = SchedulerService.buildDailySchedule(
        weighted,
        _dailyHours,
      );

      setState(() {
        _schedule = schedule;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading schedule: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showHoursDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF6F1E9),
        title: Text(
          'Daily Study Hours',
          style: GoogleFonts.interTight(fontWeight: FontWeight.bold),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_dailyHours.toStringAsFixed(1)} hours',
                  style: GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF9A00),
                  ),
                ),
                Slider(
                  value: _dailyHours,
                  min: 1,
                  max: 10,
                  divisions: 18,
                  activeColor: const Color(0xFFFF9A00),
                  onChanged: (value) {
                    setDialogState(() => _dailyHours = value);
                    setState(() => _dailyHours = value);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadSchedule();
            },
            child: Text(
              'Apply',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF4F200D)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    
    final String globalGoal = GoalSetupScreen.selectedGoal;
    List<String> availableModes = [];
    
    if (globalGoal == 'Both — CGPA + Career') {
      availableModes = ['Balanced'];
    } else if (globalGoal == 'Improve my CGPA') {
      availableModes = ['CGPA Focus'];
    } else if (globalGoal == 'Build my career path') {
      availableModes = ['Career Focus'];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF9A00)))
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalendarStrip(),
                        SizedBox(height: 24.h),
                        _buildAIInsightCard(),
                        SizedBox(height: 24.h),
                        if (availableModes.isNotEmpty) ...[
                          _buildOptimizationSelector(availableModes),
                          SizedBox(height: 24.h),
                        ],
                        _buildTaskListHeader(),
                        SizedBox(height: 16.h),
                        _buildScheduledTasks(),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_task',
            onPressed: () => showSidePanel(
              context: context,
              screen: const AddTaskScreen(),
            ),
            backgroundColor: const Color(0xFFFF9A00),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          SizedBox(height: 12.h),
          FloatingActionButton(
            heroTag: 'set_hours',
            onPressed: _showHoursDialog,
            backgroundColor: const Color(0xFF4F200D),
            child: const Icon(Icons.timer_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledTasks() {
    if (_schedule.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 48.sp, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                'No pending tasks for today!',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _schedule.map((item) {
        final topic = item['topic'];
        final priority = item['priority'];
        Color priorityColor = priority == 'High'
            ? const Color(0xFFD85A30)
            : priority == 'Medium'
                ? const Color(0xFFBA7517)
                : const Color(0xFF64748B);

        return GestureDetector(
          onTap: () async {
            try {
              await TopicService.markCompleted(
                topic['id'].toString(),
                !(topic['is_completed'] ?? false),
              );
              _loadSchedule();
            } catch (e) {
              debugPrint('Error marking topic as completed: $e');
            }
          },
          child: _buildTaskItem(
            title: topic['name'],
            course: item['course_code'] ?? 'General',
            duration: '${item['allocated_hours'].toStringAsFixed(1)}h',
            priority: '$priority Priority',
            color: priorityColor,
            startTime: item['start_time'],
            isDone: topic['is_completed'] ?? false,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Schedule',
                style: GoogleFonts.interTight(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4F200D),
                ),
              ),
              Text(
                'Personalized Study Plan',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: const Color(0xFF4F200D).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.auto_awesome_rounded, color: const Color(0xFFFF9A00), size: 24.sp),
            onPressed: () => _loadSchedule(),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return SizedBox(
      height: 80.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          bool isSelected = _selectedDateIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDateIndex = index),
            child: Container(
              width: 50.w,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4F200D) : Colors.white,
                borderRadius: BorderRadius.circular(16.w),
                border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dates[index]['day']!,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: isSelected ? Colors.white.withValues(alpha: 0.7) : Colors.grey,
                    ),
                  ),
                  Text(
                    _dates[index]['date']!,
                    style: GoogleFonts.interTight(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF4F200D),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAIInsightCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: Colors.white, size: 28.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Optimization',
                  style: GoogleFonts.interTight(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Schedule optimized based on your dependencies, credit hours, and goal priority.',
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

  Widget _buildOptimizationSelector(List<String> modes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheduler Mode',
          style: GoogleFonts.interTight(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F200D),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: modes.map((mode) {
            bool isSelected = _optimizationMode == mode;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _optimizationMode = mode),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFF9A00) : Colors.white,
                    borderRadius: BorderRadius.circular(100.w),
                    border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    mode,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF4F200D) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTaskListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tasks for Today',
          style: GoogleFonts.interTight(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F200D),
          ),
        ),
        Text(
          '${_schedule.length} Topics Planned',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: const Color(0xFFFF9A00),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem({
    required String title,
    required String course,
    required String duration,
    required String priority,
    required Color color,
    required String startTime,
    required bool isDone,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
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
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.w),
            ),
            child: Center(
              child: Text(
                startTime.split(' ')[0],
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      course,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      priority,
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  title,
                  style: GoogleFonts.interTight(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4F200D),
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text(
                      '$duration (Starts at $startTime)',
                      style: GoogleFonts.inter(fontSize: 10.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
