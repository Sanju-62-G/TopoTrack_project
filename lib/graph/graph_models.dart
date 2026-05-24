import 'package:flutter/material.dart';

enum NodeType { academic, career }

enum Difficulty { easy, medium, hard }

enum NodeStatus { done, next, locked }

class GraphNode {
  final String id;
  final String label;
  final NodeType type;
  final Difficulty? difficulty;
  final Offset position;
  final bool isHighValue;
  final NodeStatus status;
  final String duration;

  GraphNode({
    required this.id,
    required this.label,
    required this.type,
    required this.position,
    this.difficulty,
    this.isHighValue = false,
    this.status = NodeStatus.locked,
    this.duration = '0 hrs',
  });
}

class GraphEdge {
  final String from;
  final String to;
  final Color color;
  final bool isCareerPath;
  final bool isCgpPath;

  GraphEdge({
    required this.from,
    required this.to,
    required this.color,
    this.isCareerPath = false,
    this.isCgpPath = false,
  });
}
