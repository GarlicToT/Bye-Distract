import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'study_room_detail.dart'; // 添加此行
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class StudyRoomPage extends StatelessWidget {
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
                      onPressed: () {}, // 预留
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
                      onPressed: () {}, // 预留
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
  required VoidCallback onPressed, // 新增点击回调参数
}) 
  {
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
          child: Center( // 新增外层 Center 保证整体居中
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
              children: [
                Icon(icon, color: Colors.white, size: 32),
                SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center, // 文本内容居中
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
                          onTap: () async {
                            // 校验输入
                            if (nameController.text.trim().isEmpty || descController.text.trim().isEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Hint'),
                                  content: Text('Please fill in the room name and description.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text('Yes'),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            // 获取user_id
                            final prefs = await SharedPreferences.getInstance();
                            final userId = prefs.getInt('user_id');
                            if (userId == null) {
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('错误'),
                                  content: Text('未获取到用户ID，请重新登录'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text('确定'),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            // 发送POST请求
                            Navigator.of(context).pop(); // 先关闭创建弹窗
                            final url = Uri.parse(ApiConfig.createStudyRoomUrl);
                            final body = {
                              'user_id': userId,
                              'room_name': nameController.text.trim(),
                              'room_description': descController.text.trim(),
                            };
                            try {
                              final response = await http.post(
                                url,
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode(body),
                              );
                              if (response.statusCode == 200 || response.statusCode == 201) {
                                final data = jsonDecode(response.body);
                                // 保存返回信息
                                await prefs.setInt('creator_id', data['creator_id']);
                                await prefs.setString('room_name', data['room_name']);
                                await prefs.setString('room_description', data['room_description']);
                                await prefs.setInt('room_id', data['room_id']);
                                // 弹出成功提示框
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => _buildSuccessDialog(context),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('创建失败'),
                                    content: Text('服务器返回错误: ${response.body}'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text('确定'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } catch (e) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('网络错误'),
                                  content: Text('无法连接服务器: $e'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text('确定'),
                                    ),
                                  ],
                                ),
                              );
                            }
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

  Widget _buildSuccessDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 32),
            Icon(Icons.celebration, size: 72, color: Colors.black),
            SizedBox(height: 16),
            Text('Room created\nsuccessfully!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudyRoomDetailPage()),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  border: Border(top: BorderSide(color: Colors.grey.shade300, width: 2)),
                ),
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Enter the room.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}