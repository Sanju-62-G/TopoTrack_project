import 'package:flutter/material.dart';
import '../services/scheduler_service.dart';
import '../utils/side_panel.dart';
import 'add_task_screen.dart';

class SmartScheduler extends StatefulWidget {
  const SmartScheduler({super.key});

  @override
  State<SmartScheduler> createState() => _SmartSchedulerState();
}

class _SmartSchedulerState extends State<SmartScheduler> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final tasks = await SchedulerService.generateDailyTasks();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tasks: $e')),
      );
    }
  }

  Future<void> _completeTask(String taskId) async {
    await SchedulerService.completeTask(taskId);
    _loadTasks();
  }

  Future<void> _addManualTask() async {
    // Add Task screen open করো
    await showSidePanel(
      context: context,
      screen: const AddTaskScreen(),
    );
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      appBar: AppBar(
        title: const Text('Study Scheduler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _addManualTask,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskCard(_tasks[index]);
                  },
                ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    bool isCompleted = task['is_completed'] ?? false;
    String topicName =
        task['topics']?['name'] ?? 'Unknown Topic';
    String courseName =
        task['topics']?['courses']?['name'] ?? '';
    String priority = task['priority'] ?? 'Low';

    Color priorityColor = priority == 'High'
        ? const Color(0xFFD85A30)
        : priority == 'Medium'
            ? const Color(0xFFBA7517)
            : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF1D9E75)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          // Complete button
          GestureDetector(
            onTap: isCompleted
                ? null
                : () => _completeTask(task['id'].toString()),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? const Color(0xFF1D9E75)
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF1D9E75)
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topicName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isCompleted
                        ? Colors.grey
                        : const Color(0xFF4F200D),
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  courseName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Priority badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              priority,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: priorityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'All tasks done for today!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
