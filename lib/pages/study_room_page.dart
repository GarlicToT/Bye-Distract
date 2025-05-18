import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'study_room_detail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'todo_list_page.dart';
import 'statistics_page.dart';
import 'profile_page.dart';
import '../main.dart';

class StudyRoomPage extends GeneratorPage {
  @override
  _StudyRoomPageState createState() => _StudyRoomPageState();
}

class _StudyRoomPageState extends GeneratorPageState {
  int _selectedIndex = 2; // 保持和GeneratorPage一致，2为Study Room

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Study Room', style: _appBarTitleStyle),
        backgroundColor: Color(0xFFAED3EA),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<int?>(
        future: _getStudyRoomId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            final hasStudyRoom = snapshot.hasData && snapshot.data != null;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasStudyRoom) ...[
                    _buildCircularButton(
                      icon: Icons.visibility,
                      label: 'View My Room',
                      color: Color(0xFFFFD6D6),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StudyRoomDetailPage()),
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    _buildCircularButton(
                      icon: Icons.exit_to_app,
                      label: 'Leave My Room',
                      color: Color(0xFFAED3EA),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _buildLeaveRoomDialog(context),
                        );
                      },
                    ),
                  ] else ...[
                    _buildCircularButton(
                      icon: Icons.add,
                      label: 'Create Room',
                      color: Color(0xFFFFD6D6),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _buildCreateRoomDialog(context),
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    _buildCircularButton(
                      icon: Icons.home,
                      label: 'Join Room',
                      color: Color(0xFFAED3EA),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _buildJoinRoomDialog(context),
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<int?> _getStudyRoomId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('study_room_id');
  }

  Widget _buildCircularButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  final TextStyle _appBarTitleStyle = TextStyle(
    color: Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  Widget _buildCreateRoomDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController descController = TextEditingController();
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFAED3EA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Create Study Room',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room Name', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Please enter...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text('Room Description', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: descController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Please enter...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text('cancel', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (nameController.text.isEmpty || descController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please fill in all fields')),
                              );
                              return;
                            }
                            // 获取当前登录用户的user_id
                            SharedPreferences.getInstance().then((prefs) {
                              int? userId = prefs.getInt('user_id');
                              if (userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('User ID not found')),
                                );
                                return;
                              }
                              // 发送POST请求
                              http.post(
                                Uri.parse(ApiConfig.createStudyRoomUrl), // 使用 ApiConfig 的配置 // 替换为实际的后端URL
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'user_id': userId,
                                  'room_name': nameController.text,
                                  'room_description': descController.text,
                                }),
                              ).then((response) {
                                if (response.statusCode == 200) {
                                  final responseData = jsonDecode(response.body);
                                  // 保存返回数据
                                  prefs.setInt('creator_id', responseData['creator_id']);
                                  prefs.setString('room_name', responseData['room_name']);
                                  prefs.setString('room_description', responseData['room_description']);
                                  prefs.setInt('room_id', responseData['room_id']);
                                  // 更新study_room_id
                                  prefs.setInt('study_room_id', responseData['room_id']);
                                  // 关闭创建房间对话框
                                  Navigator.of(context).pop();
                                  // 弹出成功提示框
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Success'),
                                      content: Text('Room created successfully!'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => StudyRoomDetailPage()),
                                            );
                                          },
                                          child: Text('Enter the room'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to create room')),
                                  );
                                }
                              }).catchError((error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $error')),
                                );
                              });
                            });
                          },
                          child: Text('Create', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinRoomDialog(BuildContext context) {
    TextEditingController codeController = TextEditingController();
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Join Room', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter Room Code',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            SizedBox(height: 32),
            GestureDetector(
              onTap: () async {
                if (codeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('please enter room code')),
                  );
                  return;
                }
                // 获取user_id
                final prefs = await SharedPreferences.getInstance();
                int? userId = prefs.getInt('user_id');
                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User not logged in')),
                  );
                  return;
                }
                // 发送POST请求
                final response = await http.post(
                  Uri.parse('${ApiConfig.baseUrl}/study_room/join'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'user_id': userId,
                    'room_id': int.tryParse(codeController.text),
                  }),
                );
                if (response.statusCode == 200) {
                  try {
                    final data = jsonDecode(response.body);
                    if (data['room_id'] != null) {
                      await prefs.setInt('study_room_id', data['room_id']);
                      await prefs.setString('room_name', data['room_name']);
                      await prefs.setString('room_description', data['room_description']);
                      Navigator.of(context).pop(); // 关闭Dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StudyRoomDetailPage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('please enter correct room code')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('please enter correct room code')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('please enter correct room code')),
                  );
                }
              },
              child: Text('Join', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveRoomDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to leave this study room?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    int? userId = prefs.getInt('user_id');
                    int? roomId = prefs.getInt('study_room_id');
                    if (userId == null || roomId == null) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User or room info not found')),
                      );
                      return;
                    }
                    final response = await http.post(
                      Uri.parse(ApiConfig.leaveStudyRoomUrl),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'user_id': userId,
                        'room_id': roomId,
                      }),
                    );
                    if (response.statusCode == 200) {
                      await prefs.remove('study_room_id');
                      await prefs.remove('room_name');
                      await prefs.remove('room_description');
                      Navigator.of(context).pop();
                      setState(() {}); // 刷新页面
                    } else {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to leave room')),
                      );
                    }
                  },
                  child: Text('Yes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}