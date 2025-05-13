class Task {
  final String title;
  final String mode;
  final int? countdownTime;
  bool isRunning;  //这是为了倒计时功能，cursor改的

  Task({
    required this.title,
    required this.mode,
    this.countdownTime,
    this.isRunning = false,  //这是为了倒计时功能，cursor改的
  });
}