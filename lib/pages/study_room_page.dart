import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'study_room_detail_page.dart'; // For navigation
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
    _loadExistingRoomInfo();
  }

  Future<void> _loadExistingRoomInfo() async {
    setState(() { _isLoading = true; });
    final prefs = await SharedPreferences.getInstance();
    final roomId = prefs.getString('created_room_id');
    final roomName = prefs.getString('created_room_name');
    final roomDescription = prefs.getString('created_room_description');

    if (mounted) {
      if (roomId != null && roomId.isNotEmpty && roomName != null && roomDescription != null) {
        setState(() {
          _hasExistingRoom = true;
          _existingRoomId = roomId;
          _existingRoomName = roomName;
          _existingRoomDescription = roomDescription;
        });
      }
      setState(() { _isLoading = false; });
    }
  }

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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_hasExistingRoom && _existingRoomId != null && _existingRoomName != null && _existingRoomDescription != null) {
                        // Call the new callback to notify GeneratorPage
                        widget.onViewExistingRoom(_existingRoomId!, _existingRoomName!, _existingRoomDescription!);
                      } else {
                        widget.onCreateRoom();
                      }
                    },
                    child: _buildCircularButton(
                      icon: _hasExistingRoom ? Icons.visibility : Icons.add,
                      label: _hasExistingRoom ? 'View My Room' : 'Create Room',
                      color: Color(0xFFFFD6D6),
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildCircularButton(
                    icon: Icons.home,
                    label: 'Join Room',
                    color: Color(0xFFAED3EA),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
      ],
    );
  }

  final TextStyle _appBarTitleStyle = TextStyle(
    color: Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );
}