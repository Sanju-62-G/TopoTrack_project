class GoalSetupData {
  String? selectedGoal;      // 'Improve my CGPA' / 'Build my career path' / 'Both — CGPA + Career'
  String? careerGoal;        // 'Flutter Developer' etc.
  double? currentCgpa;
  double? targetCgpa;
  double? cgpaPriorityRatio;
  String? semester;

  GoalSetupData({
    this.selectedGoal,
    this.careerGoal,
    this.currentCgpa,
    this.targetCgpa,
    this.cgpaPriorityRatio,
    this.semester,
  });
}
