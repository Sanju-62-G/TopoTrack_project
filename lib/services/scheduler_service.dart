import 'supabase_client.dart';
import '../algorithms/topological_sort.dart';

class SchedulerService {
  // Schedule generate করো
  static Future<List<Map<String, dynamic>>> generateSchedule() async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    // User এর mode আর priority ratio fetch করো
    final userData = await SupabaseClientService.from('users')
        .select('selected_goal, cgpa_priority_ratio')
        .eq('id', userId)
        .maybeSingle();

    if (userData == null) return [];

    final String mode = userData['selected_goal'] ?? 'Improve my CGPA';
    final double ratio = (userData['cgpa_priority_ratio'] ?? 0.5).toDouble();

    // সব incomplete topics fetch করো
    final topics = await SupabaseClientService.from('topics')
        .select('''
          *,
          topic_prerequisites!topic_id(prerequisite_id),
          courses(credit_hours, name, course_code)
        ''')
        .eq('user_id', userId)
        .eq('is_completed', false);

    if (topics.isEmpty) return [];

    // Topological sort করো
    final sorted = TopologicalSort.sort(
      List<Map<String, dynamic>>.from(topics),
    );

    // Mode অনুযায়ী weight calculate করো
    final weighted = sorted.map((topic) {
      double creditHours =
          (topic['courses']?['credit_hours'] ?? 3.0).toDouble();

      double weight = TopologicalSort.getWeight(
        {...topic, 'credit_hours': creditHours},
        mode,
        ratio,
      );

      return {...topic, 'weight': weight};
    }).toList();

    // Weight অনুযায়ী sort করো
    weighted.sort((a, b) =>
        (b['weight'] as double).compareTo(a['weight'] as double));

    return weighted;
  }

  // Daily schedule বানাও
  static List<Map<String, dynamic>> buildDailySchedule(
    List<Map<String, dynamic>> weightedTopics,
    double dailyHours,
  ) {
    List<Map<String, dynamic>> schedule = [];
    double remainingHours = dailyHours;
    double currentHour = 9.0; // 9:00 AM থেকে শুরু

    for (var topic in weightedTopics) {
      if (remainingHours <= 0) break;

      double topicHours =
          (topic['estimated_hours'] as num?)?.toDouble() ?? 1.0;

      // Topic এর জন্য available time
      double allocatedHours =
          topicHours > remainingHours ? remainingHours : topicHours;

      // Start time format করো
      int startHour = currentHour.floor();
      int startMinute = ((currentHour - startHour) * 60).round();
      
      String period = startHour >= 12 ? 'PM' : 'AM';
      int displayHour = startHour > 12 ? startHour - 12 : (startHour == 0 ? 12 : startHour);
      
      String startTime =
          '${displayHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')} $period';

      schedule.add({
        'id': topic['id'],
        'topic': topic,
        'allocated_hours': allocatedHours,
        'start_time': startTime,
        'course_name': topic['courses']?['name'] ?? 'General',
        'course_code': topic['courses']?['course_code'] ?? '',
        'priority': getPriorityLabel(topic['weight'] as double),
        'is_completed': topic['is_completed'] ?? false,
        'topics': topic, // For compatibility with UI expecting task['topics']
      });

      remainingHours -= allocatedHours;
      currentHour += allocatedHours + 0.25; // 15 min break
    }

    return schedule;
  }

  // Generate daily tasks for UI
  static Future<List<Map<String, dynamic>>> generateDailyTasks() async {
    final weighted = await generateSchedule();
    // Default daily study limit 4 hours
    return buildDailySchedule(weighted, 4.0);
  }

  // Complete task wrapper
  static Future<void> completeTask(String taskId) async {
    await SupabaseClientService.from('topics')
        .update({'is_completed': true})
        .eq('id', taskId);
  }

  // Priority label
  static String getPriorityLabel(double weight) {
    if (weight >= 15) return 'High';
    if (weight >= 8) return 'Medium';
    return 'Low';
  }
}
