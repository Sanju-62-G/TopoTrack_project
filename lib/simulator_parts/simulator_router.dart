import 'package:flutter/material.dart';
import '../Goal_Engine/goal_setup.dart';
import 'gpa_simulator_screen.dart';
import 'career_simulator_screen.dart';

class SimulatorRouter extends StatelessWidget {
  const SimulatorRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final String? args = ModalRoute.of(context)?.settings.arguments as String?;
    final String selection = args ?? GoalSetupScreen.selectedGoal;

    // Using contains to be safe from hidden character differences like dashes
    if (selection.contains('career path')) {
      // If purely career, show career simulator (currently static)
      return const CareerSimulatorScreen();
    } else {
      // For both "Improve my CGPA" and "Both — CGPA + Career", show the functional GPA simulator
      return const GpaSimulatorScreen();
    }
  }
}
