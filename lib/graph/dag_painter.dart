import 'package:flutter/material.dart';
import 'graph_models.dart';
import '../utils/responsive.dart';

class DagPainter extends CustomPainter {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final String mode;

  DagPainter({required this.nodes, required this.edges, required this.mode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD3C5B5) // Tan/Brown color for curves
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var edge in edges) {
      GraphNode? fromNode;
      GraphNode? toNode;

      try {
        fromNode = nodes.firstWhere((n) => n.id == edge.from);
        toNode = nodes.firstWhere((n) => n.id == edge.to);
      } catch (e) {
        continue;
      }

      final nodeWidth = 160.w;
      // Cards are roughly 110-120h based on content
      final nodeHeight = 115.h; 

      final start = Offset(
        fromNode.position.dx.w + nodeWidth / 2,
        fromNode.position.dy.h + nodeHeight - 15.h,
      );
      final end = Offset(
        toNode.position.dx.w + nodeWidth / 2,
        toNode.position.dy.h + 10.h,
      );

      final path = Path();
      path.moveTo(start.dx, start.dy);
      
      final midY = start.dy + (end.dy - start.dy) / 2;
      
      // Control points to create the curved "tree" look
      path.cubicTo(
        start.dx, midY,
        end.dx, midY,
        end.dx, end.dy,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
