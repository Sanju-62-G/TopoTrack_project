import 'supabase_client.dart';

class DeadlineService {
  // Deadline save করো
  static Future<void> addDeadline({
    required String title,
    required String courseCode,
    String? topic,
    required DateTime deadlineAt,
  }) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return;

    await SupabaseClientService.from('deadlines').insert({
      'user_id': userId,
      'title': title,
      'course_code': courseCode,
      'topic': topic,
      'deadline_at': deadlineAt.toIso8601String(),
    });
  }

  // Upcoming deadlines fetch করো
  static Future<List<Map<String, dynamic>>> getDeadlines() async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return [];

    await SupabaseClientService.client.rpc('delete_expired_deadlines');

    final data = await SupabaseClientService.from('deadlines')
        .select()
        .eq('user_id', userId)
        .gte('deadline_at', DateTime.now().toIso8601String())
        .order('deadline_at', ascending: true);

    return List<Map<String, dynamic>>.from(data);
  }

  // Deadline remove করো
  static Future<void> deleteDeadline(int id) async {
    await SupabaseClientService.from('deadlines').delete().eq('id', id);
  }

  // Deadline update করো
  static Future<void> updateDeadline({
    required int id,
    required String title,
    required String courseCode,
    String? topic,
    required DateTime deadlineAt,
  }) async {
    await SupabaseClientService.from('deadlines').update({
      'title': title,
      'course_code': courseCode,
      'topic': topic,
      'deadline_at': deadlineAt.toIso8601String(),
    }).eq('id', id);
  }

  // Notification schedule
  static void scheduleReminders(Map<String, dynamic> deadline) {
    final now = DateTime.now();
    final deadlineTime = DateTime.parse(deadline['deadline_at']);

    final threeDaysBefore = deadlineTime.subtract(const Duration(days: 3));
    if (threeDaysBefore.isAfter(now)) {
      // Schedule: "3 days left for ${deadline['title']}"
    }

    final oneDayBefore = deadlineTime.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(now)) {
      // Schedule: "Tomorrow is deadline for ${deadline['title']}"
    }

    final twoHoursBefore = deadlineTime.subtract(const Duration(hours: 2));
    if (twoHoursBefore.isAfter(now)) {
      // Schedule: "Only 2 hours left for ${deadline['title']}!"
    }
  }
}
