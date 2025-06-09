class ApiConfig {
  // static const String baseUrl = 'http://10.252.88.78:8001';
  // static const String baseUrl = 'http://10.253.52.107:8001';
  // static const String baseUrl = 'http://cm-aq01.cdn.chunithm.cn:20100';
  // static const String baseUrl = 'http://10.252.88.252:8001';
  static const String baseUrl = 'http://47.115.40.224:8001';
  // http://hwc.cdn.chunithm.cn:20071
  
  // User-related
  static String get loginUrl => '$baseUrl/users/login';
  static String get registerUrl => '$baseUrl/users/register';
  static String get uploadAvatarUrl => '$baseUrl/photos/upload';
  static String get getAvatarUrl => '$baseUrl/photos';
  // Task-related
  static String get addTaskUrl => '$baseUrl/tasks/add';
  static String get fetchTasksUrl => '$baseUrl/tasks';
  static String get deleteTaskUrl => '$baseUrl/tasks/del';
  static String get finishTaskUrl => '$baseUrl/tasks/finish';
  static String get modifyTaskUrl => '$baseUrl/tasks/modify';
  static String checkEmotionUrl(int userId) => '$baseUrl/tasks/emotion/$userId';
  
  // Data-related
  static String get getStatisticsUrl => '$baseUrl/stats';

  // Video-related
  static String get uploadVideoUrl => '$baseUrl/videos/upload/reference';
  static String get uploadansVideoUrl => '$baseUrl/videos/upload/ans';

  // Study room-related
  static String get createStudyRoomUrl => '$baseUrl/study_room/add';
  static String get leaveStudyRoomUrl => '$baseUrl/study_room/leave';
  static String get joinStudyRoomUrl => '$baseUrl/study_room/join';
  static String leaderboardStudyRoomUrl(int roomId, int userId) => '$baseUrl/study_room/$roomId/$userId/leaderboard';
} 