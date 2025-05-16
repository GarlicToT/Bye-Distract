import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'study_room_detail_page.dart'; // For navigation
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
// import 'create_study_room.dart'; // create_study_room will be handled by parent

class StudyRoomPage extends StatefulWidget {
  final VoidCallback onCreateRoom;
  // Add a new callback for viewing an existing room, to be handled by GeneratorPage
  final Function(String roomId, String roomName, String roomDescription) onViewExistingRoom;

  const StudyRoomPage({
    Key? key,
    required this.onCreateRoom,
    required this.onViewExistingRoom,
  }) : super(key: key);

  @override
  State<StudyRoomPage> createState() => _StudyRoomPageState();
}

class _StudyRoomPageState extends State<StudyRoomPage> {
  bool _isLoading = true;
  bool _hasExistingRoom = false;
  String? _existingRoomId;
  String? _existingRoomName;
  String? _existingRoomDescription;

  @override
  void initState() {
    super.initState();
    _checkUserStudyRoom();
  }

  Future<void> _checkUserStudyRoom() async {
    setState(() { _isLoading = true; });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      
      if (userId == null) {
        setState(() { 
          _isLoading = false;
          _hasExistingRoom = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/study_room/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['room_id'] != null) {
          setState(() {
            _hasExistingRoom = true;
            _existingRoomId = data['room_id'].toString();
            _existingRoomName = data['room_name'];
            _existingRoomDescription = data['room_description'];
          });
        } else {
          setState(() { _hasExistingRoom = false; });
        }
      } else {
        setState(() { _hasExistingRoom = false; });
      }
    } catch (e) {
      setState(() { _hasExistingRoom = false; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _leaveRoom() async {
    if (_existingRoomId == null) return;

    setState(() { _isLoading = true; });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      
      final response = await http.post(
        Uri.parse(ApiConfig.leaveStudyRoomUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'room_id': int.parse(_existingRoomId!),
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _hasExistingRoom = false;
          _existingRoomId = null;
          _existingRoomName = null;
          _existingRoomDescription = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully left the study room')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to leave the room: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonSize = screenSize.width * 0.3; // 按钮大小为屏幕宽度的30%
    final spacing = screenSize.height * 0.05; // 间距为屏幕高度的5%

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Study Room', style: _appBarTitleStyle),
        backgroundColor: Color(0xFFAED3EA),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.05,
                      vertical: screenSize.height * 0.05,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_hasExistingRoom) ...[
                          GestureDetector(
                            onTap: () {
                              if (_existingRoomId != null && _existingRoomName != null && _existingRoomDescription != null) {
                                widget.onViewExistingRoom(_existingRoomId!, _existingRoomName!, _existingRoomDescription!);
                              }
                            },
                            child: _buildCircularButton(
                              icon: Icons.visibility,
                              label: 'View My Room',
                              color: Color(0xFFFFD6D6),
                              size: buttonSize,
                            ),
                          ),
                          SizedBox(height: spacing),
                          GestureDetector(
                            onTap: () {
                              _leaveRoom();
                            },
                            child: _buildCircularButton(
                              icon: Icons.exit_to_app,
                              label: 'Leave My Room',
                              color: Colors.red[300]!,
                              size: buttonSize,
                            ),
                          ),
                        ] else ...[
                          GestureDetector(
                            onTap: () {
                              widget.onCreateRoom();
                            },
                            child: _buildCircularButton(
                              icon: Icons.add,
                              label: 'Create Room',
                              color: Color(0xFFFFD6D6),
                              size: buttonSize,
                            ),
                          ),
                          SizedBox(height: spacing),
                          GestureDetector(
                            onTap: () {
                              // TODO: 实现加入房间的功能
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Join Room feature coming soon!')),
                              );
                            },
                            child: _buildCircularButton(
                              icon: Icons.home,
                              label: 'Join Room',
                              color: Color(0xFFAED3EA),
                              size: buttonSize,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required String label,
    required Color color,
    required double size,
  }) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: size * 0.3, // 图标大小为按钮大小的30%
              ),
              SizedBox(height: size * 0.05), // 间距为按钮大小的5%
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.15, // 字体大小为按钮大小的15%
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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