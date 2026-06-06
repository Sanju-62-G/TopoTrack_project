import 'package:flutter/material.dart';
import '../services/supabase_client.dart';
import '../services/deadline_service.dart';
import '../services/scheduler_service.dart';
import '../planner/planner_screen.dart';
import '../graph/visual_paths_screen.dart';
import '../simulator_parts/simulator_router.dart';
import '../roadmap/career_roadmap.dart';
import 'add_deadline_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  Map<String, dynamic> _userData = {};
  List<Map<String, dynamic>> _deadlines = [];
  List<Map<String, dynamic>> _todayTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return;

    try {
      // User data fetch
      final userData = await SupabaseClientService.from('users')
          .select()
          .eq('id', userId)
          .single();

      // Upcoming deadlines fetch
      final deadlines = await DeadlineService.getDeadlines();

      // Today's tasks fetch
      final tasks = await SchedulerService.generateDailyTasks();

      if (!mounted) return;
      setState(() {
        _userData = userData;
        _deadlines = deadlines;
        _todayTasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F1E9),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF5A623)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                _buildGreeting(),
                const SizedBox(height: 20),
        
                // CGPA card
                _buildCgpaCard(),
                const SizedBox(height: 16),
        
                // Learning Tools grid
                _buildLearningTools(),
                const SizedBox(height: 16),
        
                // Today's tasks
                _buildTodayTasks(),
                const SizedBox(height: 16),
        
                // Upcoming deadlines
                _buildUpcomingDeadlines(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    String name = _userData['full_name'] ?? 'Student';
    String firstName = name.split(' ')[0];
    int hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              firstName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F200D),
              ),
            ),
          ],
        ),
        CircleAvatar(
          backgroundColor: const Color(0xFFF5A623),
          child: Text(
            firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCgpaCard() {
    double currentCgpa =
        (_userData['current_cgpa'] as num?)?.toDouble() ?? 0.0;
    double targetCgpa =
        (_userData['target_cgpa'] as num?)?.toDouble() ?? 4.0;
    double progress = targetCgpa > 0 ? currentCgpa / targetCgpa : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5A623),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current CGPA',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          Text(
            currentCgpa.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation(
                Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Target: ${targetCgpa.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Learning Tools',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F200D),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildToolCard(
              'Planner',
              'Manage Courses',
              Icons.book_outlined,
              const Color(0xFF7F77DD),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PlannerScreen(),
                ),
              ),
            ),
            _buildToolCard(
              'DAG Graph',
              'Visual Paths',
              Icons.account_tree_outlined,
              const Color(0xFF1D9E75),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VisualPathsScreen(),
                ),
              ),
            ),
            _buildToolCard(
              'Simulator',
              'Predict GPA',
              Icons.calculate_outlined,
              const Color(0xFFF5A623),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SimulatorRouter(),
                ),
              ),
            ),
            _buildToolCard(
              'Roadmap',
              'Future Skills',
              Icons.map_outlined,
              const Color(0xFFD85A30),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CareerRoadmap(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF4F200D),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTasks() {
    if (_todayTasks.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Tasks",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F200D),
          ),
        ),
        const SizedBox(height: 12),
        ..._todayTasks.take(3).map((task) {
          String topicName =
              task['topics']?['name'] ?? 'Task';
          bool isCompleted = task['is_completed'] ?? false;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await SchedulerService.completeTask(
                      task['id'].toString(),
                    );
                    _loadDashboard();
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? const Color(0xFF1D9E75)
                          : Colors.transparent,
                      border: Border.all(
                        color: isCompleted
                            ? const Color(0xFF1D9E75)
                            : Colors.grey.shade400,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    topicName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isCompleted
                          ? Colors.grey
                          : const Color(0xFF4F200D),
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUpcomingDeadlines() {
    if (_deadlines.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Deadlines',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F200D),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddDeadlineScreen(),
                  ),
                );
                _loadDashboard();
              },
              child: const Text(
                '+ Add',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFF5A623),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._deadlines.take(3).map((deadline) {
          String title = deadline['title'] ?? '';
          String courseCode =
              deadline['course_code'] ?? '';
          DateTime deadlineAt = DateTime.parse(
            deadline['deadline_at'],
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5A623),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF4F200D),
                        ),
                      ),
                      Text(
                        '$courseCode · '
                        '${deadlineAt.day}/${deadlineAt.month} '
                        '${deadlineAt.hour}:${deadlineAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
