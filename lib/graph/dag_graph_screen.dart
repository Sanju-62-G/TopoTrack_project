import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/topic_service.dart';
import '../algorithms/topological_sort.dart';
import '../utils/responsive.dart';

class DAGGraphScreen extends StatefulWidget {
  final String courseId;
  final String courseName;
  
  const DAGGraphScreen({
    super.key, 
    required this.courseId,
    required this.courseName,
  });

  @override
  State<DAGGraphScreen> createState() => _DAGGraphScreenState();
}

class _DAGGraphScreenState extends State<DAGGraphScreen> {
  List<Map<String, dynamic>> _topics = [];
  final Graph _graph = Graph()..isTree = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDAG();
  }

  Future<void> _loadDAG() async {
    try {
      final topics = await TopicService.getTopics(widget.courseId);
      final sorted = TopologicalSort.sort(topics);

      // Clear existing graph
      _graph.nodes.clear();

      // Graph nodes বানাও
      Map<String, Node> nodeMap = {};
      for (var topic in sorted) {
        final nodeId = topic['id'].toString();
        nodeMap[nodeId] = Node.Id(nodeId);
      }

      // Graph edges বানাও
      for (var topic in sorted) {
        final topicId = topic['id'].toString();
        List prereqs = topic['topic_prerequisites'] ?? [];
        for (var prereq in prereqs) {
          String prereqId = prereq['prerequisite_id'].toString();
          if (nodeMap.containsKey(prereqId)) {
            _graph.addEdge(
              nodeMap[prereqId]!,
              nodeMap[topicId]!,
            );
          }
        }
      }

      setState(() {
        _topics = sorted;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading DAG: $e');
      setState(() => _isLoading = false);
    }
  }

  Color _getNodeColor(Map<String, dynamic> topic) {
    if (topic['is_completed'] == true) {
      return const Color(0xFF22C55E); // green
    }

    List prereqs = topic['topic_prerequisites'] ?? [];
    if (prereqs.isEmpty) return const Color(0xFFFF9A00); // orange (unlocked)

    bool isUnlocked = prereqs.every((p) {
      final prereqId = p['prerequisite_id'].toString();
      return _topics.any((t) =>
        t['id'].toString() == prereqId &&
        t['is_completed'] == true
      );
    });

    if (isUnlocked) return const Color(0xFFFF9A00); // orange
    return const Color(0xFF94A3B8); // locked (grey)
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F1E9),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF9A00))),
      );
    }

    final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration()
      ..siblingSeparation = 50
      ..levelSeparation = 80
      ..subtreeSeparation = 50
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.courseName,
              style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              'Topic Dependencies',
              style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF4F200D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _topics.isEmpty 
        ? _buildEmptyState()
        : InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.5,
            maxScale: 2.0,
            child: GraphView(
              graph: _graph,
              algorithm: BuchheimWalkerAlgorithm(
                builder,
                TreeEdgeRenderer(builder),
              ),
              builder: (Node node) {
                String topicId = node.key!.value as String;
                Map<String, dynamic> topic = _topics.firstWhere(
                  (t) => t['id'].toString() == topicId,
                );
                return _buildNode(topic);
              },
            ),
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree_outlined, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            'No topics added to this course',
            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          Text(
            'Add topics to see the dependency graph',
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(Map<String, dynamic> topic) {
    Color color = _getNodeColor(topic);
    bool isCompleted = topic['is_completed'] == true;

    return GestureDetector(
      onTap: () async {
        try {
          await TopicService.markCompleted(
            topic['id'].toString(),
            !isCompleted,
          );
          _loadDAG();
        } catch (e) {
          debugPrint('Error updating topic: $e');
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCompleted)
                  Icon(Icons.check_circle, color: color, size: 14.sp)
                else if (color == const Color(0xFF94A3B8))
                  Icon(Icons.lock, color: color, size: 14.sp),
                if (isCompleted || color == const Color(0xFF94A3B8))
                  SizedBox(width: 6.w),
                Text(
                  topic['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4F200D),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              '${topic['difficulty']} • ${topic['estimated_hours']}h',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
