import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'study_room_detail.dart'; // 添加此行

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
                      onPressed: () {}, // 预留
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
}