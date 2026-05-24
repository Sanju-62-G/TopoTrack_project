class TopologicalSort {
  static List<Map<String, dynamic>> sort(
    List<Map<String, dynamic>> topics,
  ) {
    // Step 1: inDegree map বানাও
    Map<String, int> inDegree = {};
    Map<String, List<String>> graph = {};

    for (var topic in topics) {
      String id = topic['id'].toString();
      inDegree[id] = 0;
      graph[id] = [];
    }

    // Step 2: edges set করো prerequisites থেকে
    for (var topic in topics) {
      String id = topic['id'].toString();
      List prereqs = topic['topic_prerequisites'] ?? [];

      for (var prereq in prereqs) {
        String prereqId = prereq['prerequisite_id'].toString();
        if (graph.containsKey(prereqId)) {
          graph[prereqId]!.add(id);
          inDegree[id] = (inDegree[id] ?? 0) + 1;
        }
      }
    }

    // Step 3: inDegree = 0 দিয়ে queue শুরু করো
    List<String> queue = [];
    for (var topic in topics) {
      String id = topic['id'].toString();
      if ((inDegree[id] ?? 0) == 0) {
        queue.add(id);
      }
    }

    // Step 4: Topological order বানাও
    List<Map<String, dynamic>> sorted = [];
    Set<String> processed = {};

    while (queue.isNotEmpty) {
      String currentId = queue.removeAt(0);
      if (processed.contains(currentId)) continue;
      
      final current = topics.firstWhere(
        (t) => t['id'].toString() == currentId,
      );
      sorted.add(current);
      processed.add(currentId);

      if (graph.containsKey(currentId)) {
        for (var neighborId in graph[currentId]!) {
          inDegree[neighborId] = (inDegree[neighborId] ?? 1) - 1;
          if (inDegree[neighborId] == 0) {
            queue.add(neighborId);
          }
        }
      }
    }

    // Add any remaining nodes that might be in cycles or disconnected
    for (var topic in topics) {
      if (!processed.contains(topic['id'].toString())) {
        sorted.add(topic);
      }
    }

    return sorted;
  }

  // Mode অনুযায়ী weight calculate করো
  static double getWeight(
    Map<String, dynamic> topic,
    String mode,
    double cgpaPriorityRatio,
  ) {
    double creditHours = (topic['credit_hours'] ?? 3.0).toDouble();
    bool isCareerRelevant = topic['is_career_relevant'] ?? false;

    switch (mode) {
      case 'Improve my CGPA':
        return creditHours * 10;

      case 'Build my career path':
        return isCareerRelevant ? 20.0 : 5.0;

      case 'Both — CGPA + Career':
        double cgpaScore = creditHours * cgpaPriorityRatio * 5;
        double careerScore = (isCareerRelevant ? 10.0 : 2.0) * (1 - cgpaPriorityRatio);
        return cgpaScore + careerScore;

      default:
        return creditHours * 10;
    }
  }
}
