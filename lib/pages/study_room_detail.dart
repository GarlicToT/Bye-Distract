import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'study_room_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class StudyRoomDetailPage extends StatefulWidget {
  @override
  _StudyRoomDetailPageState createState() => _StudyRoomDetailPageState();
}

class _StudyRoomDetailPageState extends State<StudyRoomDetailPage> {
  String roomName = '';
  String roomDescription = '';
  String roomId = '';
  List<dynamic> leaderboard = [];
  Map<String, dynamic>? currentUser;
  bool isLoading = true;
  int? currentUserId;
  Map<String, String?> userAvatars = {};

  @override
  void initState() {
    super.initState();
    _loadRoomInfo();
  }

  Future<void> _loadRoomInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      roomName = prefs.getString('room_name') ?? '';
      roomDescription = prefs.getString('room_description') ?? '';
      roomId = prefs.getInt('room_id')?.toString() ?? '';
      currentUserId = prefs.getInt('user_id');
    });
    await _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final studyRoomId = prefs.getInt('study_room_id');

      if (userId == null || studyRoomId == null) {
        print('User ID or Study Room ID not found');
        return;
      }

      print('开始获取排行榜数据...');
      final response = await http.get(
        Uri.parse(ApiConfig.leaderboardStudyRoomUrl(studyRoomId, userId)),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> leaderboardData = data['leaderboard'];
        print('成功获取排行榜数据，用户数量: ${leaderboardData.length}');
        
        // 获取所有用户的user_id
        final userIds = leaderboardData.map((user) => user['user_id'].toString()).join(',');
        print('准备获取用户头像，用户ID列表: $userIds');

        // 批量获取头像
        try {
          final avatarResponse = await http.post(
            Uri.parse('${ApiConfig.getAvatarUrl}/?user_ids=$userIds'),
            headers: {
              'accept': 'application/json',
            },
          );
          print('头像请求状态码: ${avatarResponse.statusCode}');
          print('头像响应数据: ${avatarResponse.body}');
          
          if (avatarResponse.statusCode == 200) {
            final avatarData = jsonDecode(avatarResponse.body);
            if (avatarData['status'] == 'success') {
              setState(() {
                userAvatars = Map<String, String?>.from(avatarData['data']);
              });
              print('成功获取用户头像数据');
            }
          } else {
            print('获取头像失败: ${avatarResponse.statusCode}');
          }
        } catch (e) {
          print('获取头像时出错: $e');
        }

        setState(() {
          leaderboard = leaderboardData;
          currentUser = data['current_user'];
          isLoading = false;
        });
        print('排行榜数据更新完成');
      } else {
        print('获取排行榜失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      print('获取排行榜数据时出错: $e');
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    return '$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudyRoomPage()),
            );
          },
        ),
        title: Text('Study Room', style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        )),
        backgroundColor: Color(0xFFAED3EA),
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.settings, color: Colors.black, size: 28),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(roomName, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            SizedBox(width: 12),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFE6A0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('${leaderboard.length} persons', style: TextStyle(color: Color(0xFFB88A00), fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text('(Room Code: $roomId)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        SizedBox(height: 4),
                        Text(roomDescription, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Text('${leaderboard.where((user) => user['duration'] > 0).length}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Text('Focusing', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                            SizedBox(width: 24),
                            Text('${currentUser?['rank'] ?? 0}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Text('Your Rank', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                          ],
                        ),
                        SizedBox(height: 16),
                        ...leaderboard.map((user) => _buildUserCard(user)).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final bool isCurrentUser = user['user_id'] == currentUserId;
    final String userId = user['user_id'].toString();
    final String? avatarUrl = userAvatars[userId];
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFE6E6),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text('${user['rank']}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          avatarUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, size: 32, color: Colors.grey[400]);
                          },
                        ),
                      )
                    : Icon(Icons.person, size: 32, color: Colors.grey[400]),
              ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Focused Today: ${_formatDuration(user['duration'])} min', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF8A8A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Focus Streak: 0 days', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFD6B4FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Total focus: 0 days', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Column(
            children: [
              Text(_formatDuration(user['duration']), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              Text('min', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            ],
          ),
        ],
      ),
    );
  }
}
