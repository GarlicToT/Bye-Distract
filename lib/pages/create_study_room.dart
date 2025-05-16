import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'study_room_detail_page.dart';

class CreateStudyRoomPage extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(String roomId, String roomName, String roomDescription) onRoomCreatedAndNavToDetail;

  const CreateStudyRoomPage({
    Key? key,
    required this.onCancel,
    required this.onRoomCreatedAndNavToDetail,
  }) : super(key: key);

  @override
  State<CreateStudyRoomPage> createState() => _CreateStudyRoomPageState();
}

class _CreateStudyRoomPageState extends State<CreateStudyRoomPage> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _roomDescController = TextEditingController();
  bool _isLoading = false;
  String? _existingRoomId;
  String? _existingRoomName;
  String? _existingRoomDescription;

  @override
  void initState() {
    super.initState();
    _loadExistingRoom();
  }

  Future<void> _loadExistingRoom() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _existingRoomId = prefs.getString('created_room_id');
      _existingRoomName = prefs.getString('created_room_name');
      _existingRoomDescription = prefs.getString('created_room_description');
    });
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
        // 清除保存的房间信息
        await prefs.remove('created_room_id');
        await prefs.remove('created_room_name');
        await prefs.remove('created_room_description');
        
        setState(() {
          _existingRoomId = null;
          _existingRoomName = null;
          _existingRoomDescription = null;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully left the study room')),
        );
      } else {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to leave the room: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  Future<void> _createRoom() async {
    final roomName = _roomNameController.text.trim();
    final roomDesc = _roomDescController.text.trim();
    if (roomName.isEmpty || roomDesc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room name and Room description can not be empty.')),
      );
      return;
    }

    setState(() { _isLoading = true; });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      
      final response = await http.post(
        Uri.parse(ApiConfig.createStudyRoomUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'room_name': roomName,
          'room_description': roomDesc,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final roomId = responseData['room_id'].toString();
        final fetchedRoomName = responseData['room_name'] as String;
        final fetchedRoomDescription = responseData['room_description'] as String;

        if (!mounted) return;
        setState(() { _isLoading = false; });
        _showSuccessDialog(roomId, fetchedRoomName, fetchedRoomDescription);
      } else {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Creation failed: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  void _showSuccessDialog(String roomId, String roomName, String roomDescription) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.celebration, size: 80, color: Colors.black87),
                SizedBox(height: 16),
                Text(
                  'Room created\nsuccessfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onRoomCreatedAndNavToDetail(roomId, roomName, roomDescription);
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                      child: Text(
                        'Enter the room.',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.05; // 水平内边距为屏幕宽度的5%
    final verticalSpacing = screenSize.height * 0.02; // 垂直间距为屏幕高度的2%

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.03,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFAED3EA),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _existingRoomId != null ? 'My Study Room' : 'Create Study Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenSize.width * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (_existingRoomId != null) ...[
                  SizedBox(height: verticalSpacing * 2),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Room',
                          style: TextStyle(
                            fontSize: screenSize.width * 0.055,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        SizedBox(height: verticalSpacing),
                        Container(
                          padding: EdgeInsets.all(screenSize.width * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _existingRoomName ?? '',
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: verticalSpacing),
                              Text(
                                _existingRoomDescription ?? '',
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.04,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SizedBox(height: verticalSpacing * 2),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Text(
                      'Room Name',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.055,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: verticalSpacing,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _roomNameController,
                        decoration: InputDecoration(
                          hintText: 'Please enter...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.04,
                            vertical: screenSize.height * 0.02,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Text(
                      'Room Description',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.055,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: verticalSpacing,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _roomDescController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Please enter...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.04,
                            vertical: screenSize.height * 0.02,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: verticalSpacing,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          widget.onCancel();
                        },
                        child: Text(
                          'cancel',
                          style: TextStyle(
                            fontSize: screenSize.width * 0.055,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      if (_existingRoomId != null) ...[
                        GestureDetector(
                          onTap: _isLoading ? null : _leaveRoom,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.06,
                              vertical: screenSize.height * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: _isLoading ? Colors.grey : Colors.red[300],
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              'Leave My Room',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenSize.width * 0.045,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenSize.width * 0.04),
                        GestureDetector(
                          onTap: () {
                            widget.onRoomCreatedAndNavToDetail(
                              _existingRoomId!,
                              _existingRoomName!,
                              _existingRoomDescription!,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.06,
                              vertical: screenSize.height * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: _isLoading ? Colors.grey : Color(0xFFAED3EA),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              'View My Room',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenSize.width * 0.045,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        GestureDetector(
                          onTap: _isLoading ? null : _createRoom,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.06,
                              vertical: screenSize.height * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: _isLoading ? Colors.grey : Color(0xFFAED3EA),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              'Create Room',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenSize.width * 0.045,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenSize.width * 0.04),
                        GestureDetector(
                          onTap: () {
                            // TODO: 实现加入房间的功能
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Join Room feature coming soon!')),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.06,
                              vertical: screenSize.height * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: _isLoading ? Colors.grey : Color(0xFFAED3EA),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              'Join Room',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenSize.width * 0.045,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: verticalSpacing * 2),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _roomDescController.dispose();
    super.dispose();
  }
}
