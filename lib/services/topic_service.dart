import 'supabase_client.dart';

class TopicService {
  // Topic add করো
  static Future<void> addTopic({
    required String courseId,
    required String name,
    required String difficulty,
    required double estimatedHours,
    bool isCareerRelevant = false,
    List<String> prerequisites = const [],
  }) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    // Topic insert করো
    final topic = await SupabaseClientService.from('topics').insert({
      'course_id': courseId,
      'user_id': userId,
      'name': name,
      'difficulty': difficulty,
      'estimated_hours': estimatedHours,
      'is_career_relevant': isCareerRelevant,
      'is_completed': false,
    }).select().single();

    // Prerequisites insert করো
    if (prerequisites.isNotEmpty) {
      final prereqData = prerequisites.map((prereqId) => {
        'topic_id': topic['id'],
        'prerequisite_id': prereqId,
      }).toList();

      await SupabaseClientService.from('topic_prerequisites')
          .insert(prereqData);
    }
  }

  // Course এর সব topics fetch করো
  static Future<List<Map<String, dynamic>>> getTopics(
    String courseId,
  ) async {
    final topics = await SupabaseClientService.from('topics')
        .select('''
          *,
          topic_prerequisites(
            prerequisite_id
          )
        ''')
        .eq('course_id', courseId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(topics);
  }

  // Topic complete mark করো
  static Future<void> markCompleted(
    String topicId,
    bool isCompleted,
  ) async {
    await SupabaseClientService.from('topics')
        .update({'is_completed': isCompleted})
        .eq('id', topicId);
  }

  // Topic delete করো
  static Future<void> deleteTopic(String topicId) async {
    await SupabaseClientService.from('topics')
        .delete()
        .eq('id', topicId);
  }

  // Topic update করো
  static Future<void> updateTopic({
    required String topicId,
    required String name,
    required String difficulty,
    required double estimatedHours,
    bool isCareerRelevant = false,
  }) async {
    await SupabaseClientService.from('topics').update({
      'name': name,
      'difficulty': difficulty,
      'estimated_hours': estimatedHours,
      'is_career_relevant': isCareerRelevant,
    }).eq('id', topicId);
  }
}
