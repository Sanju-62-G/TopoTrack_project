import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import 'graph_models.dart';
import 'dag_painter.dart';

class VisualPathsScreen extends StatefulWidget {
  const VisualPathsScreen({super.key});

  @override
  State<VisualPathsScreen> createState() => _VisualPathsScreenState();
}

class _VisualPathsScreenState extends State<VisualPathsScreen> {
  // Use fixed logical pixels for the canvas to ensure stability
  static const double canvasWidth = 500.0;
  static const double canvasHeight = 900.0;
  
  late TransformationController _transformationController;
  bool _isInitialized = false;

  final List<GraphNode> _nodes = [
    GraphNode(
      id: '1',
      label: 'Arrays & Strings',
      type: NodeType.academic,
      difficulty: Difficulty.easy,
      status: NodeStatus.done,
      duration: '4 hrs',
      position: const Offset(170, 40),
    ),
    GraphNode(
      id: '2',
      label: 'Linked Lists',
      type: NodeType.academic,
      difficulty: Difficulty.medium,
      status: NodeStatus.done,
      duration: '6 hrs',
      position: const Offset(40, 220),
    ),
    GraphNode(
      id: '3',
      label: 'Stacks & Queues',
      type: NodeType.academic,
      difficulty: Difficulty.easy,
      status: NodeStatus.done,
      duration: '3 hrs',
      position: const Offset(300, 220),
    ),
    GraphNode(
      id: '4',
      label: 'Binary Trees',
      type: NodeType.academic,
      difficulty: Difficulty.hard,
      status: NodeStatus.next,
      duration: '10 hrs',
      position: const Offset(170, 420),
    ),
    GraphNode(
      id: '5',
      label: 'Heaps',
      type: NodeType.academic,
      difficulty: Difficulty.medium,
      status: NodeStatus.locked,
      duration: '5 hrs',
      position: const Offset(40, 620),
    ),
    GraphNode(
      id: '6',
      label: 'Graphs',
      type: NodeType.academic,
      difficulty: Difficulty.hard,
      status: NodeStatus.locked,
      duration: '12 hrs',
      position: const Offset(300, 620),
    ),
  ];

  final List<GraphEdge> _edges = [
    GraphEdge(from: '1', to: '2', color: Colors.transparent),
    GraphEdge(from: '1', to: '3', color: Colors.transparent),
    GraphEdge(from: '2', to: '4', color: Colors.transparent),
    GraphEdge(from: '3', to: '4', color: Colors.transparent),
    GraphEdge(from: '4', to: '5', color: Colors.transparent),
    GraphEdge(from: '4', to: '6', color: Colors.transparent),
  ];

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _centerGraph(Size screenSize) {
    if (_isInitialized) return;
    
    // Scale the canvas width according to our responsive utility
    final double scaledCanvasWidth = canvasWidth.w;
    final double initialX = (screenSize.width - scaledCanvasWidth) / 2;
    
    _transformationController.value = Matrix4.translationValues(initialX, 20.0, 0.0);
    
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    final Size screenSize = MediaQuery.of(context).size;
    
    // Ensure the graph is centered once
    _centerGraph(screenSize);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsBanner(),
            Expanded(
              child: InteractiveViewer(
                constrained: false,
                // Large boundary margin to prevent snapping back
                boundaryMargin: const EdgeInsets.all(double.infinity),
                minScale: 0.1,
                maxScale: 2.5,
                transformationController: _transformationController,
                child: Container(
                  width: canvasWidth.w,
                  height: canvasHeight.h,
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(canvasWidth.w, canvasHeight.h),
                        painter: DagPainter(
                          nodes: _nodes,
                          edges: _edges,
                          mode: 'CGPA',
                        ),
                      ),
                      ..._nodes.map((node) => _buildModernNode(node)),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomActionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: const Color(0xFF4F200D), size: 22.sp),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              fixedSize: Size(40.w, 40.w),
            ),
          ),
          Column(
            children: [
              Text(
                'Data Structures',
                style: GoogleFonts.interTight(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4F200D),
                ),
              ),
              Text(
                'Learning Path (DAG)',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4F200D).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: const Color(0xFF4F200D), size: 22.sp),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              fixedSize: Size(40.w, 40.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(18.w),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(Icons.task_alt_rounded, '4/12', 'Done', Colors.white),
          _divider(color: Colors.white.withValues(alpha: 0.3)),
          _statItem(Icons.trending_up_rounded, '65%', 'Progress', Colors.white),
          _divider(color: Colors.white.withValues(alpha: 0.3)),
          _statItem(Icons.schedule_rounded, '24h', 'Time', Colors.white),
        ],
      ),
    );
  }

  Widget _divider({Color color = const Color(0xFFE2E8F0)}) => 
      Container(height: 24.h, width: 1, color: color);

  Widget _statItem(IconData icon, String val, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18.sp),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(val, style: GoogleFonts.interTight(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: GoogleFonts.inter(fontSize: 9.sp, color: Colors.white.withValues(alpha: 0.8))),
          ],
        ),
      ],
    );
  }

  Widget _buildModernNode(GraphNode node) {
    String statusText = '';
    
    switch (node.status) {
      case NodeStatus.done:
        statusText = 'Done';
        break;
      case NodeStatus.next:
        statusText = 'Next';
        break;
      case NodeStatus.locked:
        statusText = 'Locked';
        break;
    }

    return Positioned(
      left: node.position.dx.w,
      top: node.position.dy.h,
      child: GestureDetector(
        onTap: () {
          // Add your tap logic here if needed
          debugPrint('Tapped node: ${node.label}');
        },
        child: Container(
          width: 160.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.w),
            border: Border.all(
              color: node.status == NodeStatus.next ? const Color(0xFFFFD93D) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F200D).withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF6EE),
                        borderRadius: BorderRadius.circular(10.w),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 9.sp, 
                          fontWeight: FontWeight.bold, 
                          color: const Color(0xFFFF9A00)
                        ),
                      ),
                    ),
                    _difficultyDot(node.difficulty!),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  node.label,
                  style: GoogleFonts.interTight(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4F200D),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14.sp, color: const Color(0xFF4F200D).withValues(alpha: 0.4)),
                        SizedBox(width: 4.w),
                        Text(
                          node.duration,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp, 
                            color: const Color(0xFF4F200D).withValues(alpha: 0.4), 
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                    if (node.status == NodeStatus.done)
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF9A00),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, size: 12.sp, color: Colors.white),
                      )
                    else if (node.status == NodeStatus.next)
                       Icon(Icons.arrow_circle_right_rounded, size: 20.sp, color: const Color(0xFF4F46E5))
                    else
                      Icon(Icons.lock_rounded, size: 18.sp, color: const Color(0xFF94A3B8)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _difficultyDot(Difficulty diff) {
    Color color;
    switch (diff) {
      case Difficulty.easy: color = const Color(0xFF22C55E); break;
      case Difficulty.medium: color = const Color(0xFFFFD93D); break;
      case Difficulty.hard: color = const Color(0xFFEF4444); break;
    }
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildBottomActionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EADF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.w)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD93D),
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Up Next',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4F200D).withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Binary Trees',
                    style: GoogleFonts.interTight(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4F200D),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9A00),
                  foregroundColor: const Color(0xFF4F200D),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start Learning',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
