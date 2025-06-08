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
    final userId = prefs.getInt('user_id');
    final studyRoomId = prefs.getInt('study_room_id');

    print('Debug - userId: $userId');
    print('Debug - studyRoomId: $studyRoomId');

    if (userId == null || studyRoomId == null) {
      print('User ID or Study Room ID not found');
      return;
    }

    setState(() {
      roomId = studyRoomId.toString();
      currentUserId = userId;
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

      print('Fetching leaderboard data...');
      final response = await http.get(
        Uri.parse(ApiConfig.leaderboardStudyRoomUrl(studyRoomId, userId)),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> leaderboardData = data['leaderboard'];
        print('Successfully fetched leaderboard data, number of users: ${leaderboardData.length}');
        
        // Get study room information from leaderboard data
        if (data['room_description'] != null) {
          setState(() {
            roomDescription = data['room_description'];
            roomName = data['room_name'] ?? '';
          });
        }
        
        // Get all user IDs
        final userIds = leaderboardData.map((user) => user['user_id'].toString()).join(',');
        print('Preparing to fetch user avatars, user ID list: $userIds');

        // Batch fetch avatars
        try {
          final avatarResponse = await http.post(
            Uri.parse('${ApiConfig.getAvatarUrl}/?user_ids=$userIds'),
            headers: {
              'accept': 'application/json',
            },
          );
          print('Avatar request status code: ${avatarResponse.statusCode}');
          print('Avatar response data: ${avatarResponse.body}');
          
          if (avatarResponse.statusCode == 200) {
            final avatarData = jsonDecode(avatarResponse.body);
            if (avatarData['status'] == 'success') {
              setState(() {
                userAvatars = Map<String, String?>.from(avatarData['data']);
              });
              print('Successfully fetched user avatar data');
            }
          } else {
            print('Failed to fetch avatars: ${avatarResponse.statusCode}');
          }
        } catch (e) {
          print('Error fetching avatars: $e');
        }

        setState(() {
          leaderboard = leaderboardData;
          currentUser = data['current_user'];
          isLoading = false;
        });
        print('Leaderboard data update completed');
      } else {
        print('Failed to fetch leaderboard, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching leaderboard data: $e');
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
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Study Room', style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        )),
        backgroundColor: Color(0xFF98CCBB),
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.settings, color: Colors.white, size: 24),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/leaderboard.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
              child: isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF98CCBB).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(roomName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF329363))),
                                  SizedBox(width: 12),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF68A530).withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('${leaderboard.length} persons', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text('(Room Code: $roomId)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                              SizedBox(height: 4),
                              Text(roomDescription, style: TextStyle(fontSize: 14, color: Colors.white)),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF68A530).withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('${leaderboard.where((user) => user['duration'] > 0).length}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                        SizedBox(width: 4),
                                        Text('Focusing', style: TextStyle(fontSize: 14, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 24),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF68A530).withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('${currentUser?['rank'] ?? 0}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                        SizedBox(width: 4),
                                        Text('Your Rank', style: TextStyle(fontSize: 14, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16),
                              ...leaderboard.map((user) => _buildUserCard(user)).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
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
        color: Color(0xFF329363).withOpacity(0.7),
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
              Text('${user['rank']}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFF98CCBB).withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          avatarUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, size: 28, color: Colors.white);
                          },
                        ),
                      )
                    : Icon(Icons.person, size: 28, color: Colors.white),
              ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text('Focused Today: ${_formatDuration(user['duration'])} min', style: TextStyle(fontSize: 14, color: Colors.white)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFF80BC6B).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Focus\nStreak: 0 days',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFF98ccbb).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Total\nfocus: 0 days',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Column(
            children: [
              Text(_formatDuration(user['duration']), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('min', style: TextStyle(fontSize: 14, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
