class ApiConfig {
  // static const String baseUrl = 'http://10.252.88.78:8001';
  // static const String baseUrl = 'http://10.253.52.107:8001';
  static const String baseUrl = 'http://10.252.88.70:8001';

  
  // 用户相关
  static String get loginUrl => '$baseUrl/users/login';
  static String get registerUrl => '$baseUrl/users/register';
  
  // 任务相关
  static String get addTaskUrl => '$baseUrl/tasks/add';
  static String get fetchTasksUrl => '$baseUrl/tasks';
  static String get deleteTaskUrl => '$baseUrl/tasks/del';
  static String get finishTaskUrl => '$baseUrl/tasks/finish';
  static String get modifyTaskUrl => '$baseUrl/tasks/modify';
  
  //数据相关
  static String get getStatisticsUrl => '$baseUrl/stas';

  // 学习室相关
  static String get createStudyRoomUrl => '$baseUrl/study_room/add';
  static String get leaveStudyRoomUrl => '$baseUrl/study_room/leave';
} 