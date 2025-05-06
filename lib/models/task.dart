class Task {
  final String title;
  final String mode;
  final int? countdownTime;

  Task({
    required this.title,
    required this.mode,
    this.countdownTime,
  });
}