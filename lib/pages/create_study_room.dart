import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  Future<void> _createRoom() async {
    final prefs = await SharedPreferences.getInstance();
    final existingRoomId = prefs.getString('created_room_id');

    if (existingRoomId != null && existingRoomId.isNotEmpty) {
      if (mounted) { // Check if the widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You already have an active study room (ID: $existingRoomId). You cannot create another one.')),
        );
      }
      // Optionally, automatically call onCancel or navigate back
      // widget.onCancel(); 
      return;
    }

    final userId = prefs.getInt('user_id') ?? 0;
    final roomName = _roomNameController.text.trim();
    final roomDesc = _roomDescController.text.trim();
    if (roomName.isEmpty || roomDesc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room name and Room description can not be empty.')),
      );
      return;
    }
    setState(() { _isLoading = true; });
    final url = 'http://10.252.88.78:8001/study_room/add';
    final body = jsonEncode({
      'user_id': userId,
      'room_name': roomName,
      'room_description': roomDesc,
    });
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final roomId = responseData['room_id'].toString();
        final fetchedRoomName = responseData['room_name'] as String;
        final fetchedRoomDescription = responseData['room_description'] as String;

        // Save room details to SharedPreferences
        await prefs.setString('created_room_id', roomId);
        await prefs.setString('created_room_name', fetchedRoomName);
        await prefs.setString('created_room_description', fetchedRoomDescription);

        if (!mounted) return; // Check if the widget is still in the tree
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
                  padding: EdgeInsets.only(top: 24, bottom: 24),
                  decoration: BoxDecoration(
                    color: Color(0xFFAED3EA),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
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
                SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Room Name',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Room Description',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : _createRoom,
                        child: Text(
                          'Create',
                          style: TextStyle(
                            color: _isLoading ? Colors.grey : Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
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
