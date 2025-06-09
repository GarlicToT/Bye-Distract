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

// Custom Clipper for the top-left triangle
class TopLeftTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0); // Top-right corner
    path.lineTo(0, size.height); // Bottom-left corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Custom Clipper for the bottom-right triangle
class BottomRightTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, size.height); // Bottom-right corner
    path.lineTo(0, size.height); // Bottom-left corner
    path.lineTo(size.width, 0); // Top-right corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class StudyRoomPage extends GeneratorPage {
  @override
  _StudyRoomPageState createState() => _StudyRoomPageState();
}

class _StudyRoomPageState extends GeneratorPageState with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 2; // Keep consistent with GeneratorPage, 2 is for Study Room

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshPage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshPage();
  }

  void _refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Study Room', style: _appBarTitleStyle),
        backgroundColor: Color(0xFF93BDCE),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/studyroom.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<int?>(
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
                      _buildCombinedActionSquare(
                        topLeftIcon: Icons.visibility,
                        topLeftLabel: 'View My Room',
                        topLeftColor: Color(0xFF67988A),
                        onTopLeftPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => StudyRoomDetailPage()),
                          );
                        },
                        bottomRightIcon: Icons.exit_to_app,
                        bottomRightLabel: 'Leave My Room',
                        bottomRightColor: Color(0xFF4194BC),
                        onBottomRightPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => _buildLeaveRoomDialog(context),
                          );
                        },
                      ),
                    ] else ...[
                      _buildCombinedActionSquare(
                        topLeftIcon: Icons.add,
                        topLeftLabel: 'Create Room',
                        topLeftColor: Color(0xFF67988A),
                        onTopLeftPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => _buildCreateRoomDialog(context),
                          );
                        },
                        bottomRightIcon: Icons.home,
                        bottomRightLabel: 'Join Room',
                        bottomRightColor: Color(0xFF4194BC),
                        onBottomRightPressed: () {
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
      ),
    );
  }

  Future<int?> _getStudyRoomId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('study_room_id');
  }

  // New widget for the combined square button
  Widget _buildCombinedActionSquare({
    required IconData topLeftIcon,
    required String topLeftLabel,
    required Color topLeftColor,
    required VoidCallback onTopLeftPressed,
    required IconData bottomRightIcon,
    required String bottomRightLabel,
    required Color bottomRightColor,
    required VoidCallback onBottomRightPressed,
  }) {
    const double width = 280; // Width remains the same
    const double height = 380; // Increased height for a rectangular shape
    const double iconSize = 60; // Increased icon size
    const double fontSize = 20; // Adjusted font size for labels

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            topLeftColor.withOpacity(0.8),
            bottomRightColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.5, 0.5],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
        borderRadius: BorderRadius.circular(60),
      ),
      child: Stack(
        children: [
          // Bottom-right triangle
          Positioned.fill(
            child: ClipPath(
              clipper: BottomRightTriangleClipper(),
              child: GestureDetector(
                onTap: onBottomRightPressed,
                child: Container(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 40.0, 40.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(bottomRightIcon, color: Colors.white, size: iconSize),
                          SizedBox(height: 15),
                          Text(
                            bottomRightLabel,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Top-left triangle
          Positioned.fill(
            child: ClipPath(
              clipper: TopLeftTriangleClipper(),
              child: GestureDetector(
                onTap: onTopLeftPressed,
                child: Container(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40.0, 40.0, 20.0, 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topLeftLabel,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 15),
                          Icon(topLeftIcon, color: Colors.white, size: iconSize),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final TextStyle _appBarTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
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
            color: Color(0xFF93BDCE),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF417D74),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Create Study Room',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
                    Text('Room Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
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
                          hintText: 'Enter room name',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text('Room Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
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
                          hintText: 'Enter room description',
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
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Color(0xFF417D74),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Cancel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (nameController.text.isEmpty || descController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please fill in all fields.')),
                              );
                              return;
                            }
                            // Get current logged in user's user_id
                            SharedPreferences.getInstance().then((prefs) {
                              int? userId = prefs.getInt('user_id');
                              if (userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('User ID not found. Please log in.')),
                                );
                                return;
                              }
                              // Send POST request
                              http.post(
                                Uri.parse(ApiConfig.createStudyRoomUrl),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'user_id': userId,
                                  'room_name': nameController.text,
                                  'room_description': descController.text,
                                }),
                              ).then((response) {
                                if (response.statusCode == 200) {
                                  final responseData = jsonDecode(response.body);
                                  // Save returned room_id
                                  prefs.setInt('study_room_id', responseData['room_id']);
                                  
                                  // Close create room dialog
                                  Navigator.of(context).pop();
                                  // Show success dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Color(0xFF788682),
                                      title: Text(
                                        'Success',
                                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      content: Text(
                                        'Room created successfully! Would you like to enter the room now?',
                                        style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            // Save study room information
                                            await prefs.setString('room_name', responseData['room_name']);
                                            await prefs.setString('room_description', responseData['room_description']);
                                            setState(() {}); // Refresh page
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => StudyRoomDetailPage()),
                                            );
                                          },
                                          child: Text(
                                            'Enter Room',
                                            style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            setState(() {}); // Refresh page
                                          },
                                          child: Text(
                                            'Later',
                                            style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to create room. Please try again.')),
                                  );
                                }
                              }).catchError((error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error creating room: $error')),
                                );
                              });
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Color(0xFF417D74),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Create', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
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
          color: Color(0xFF93BDCE),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Join Room', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 24),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter room code',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 32),
            GestureDetector(
              onTap: () async {
                if (codeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter room code.')),
                  );
                  return;
                }
                // Get user_id
                final prefs = await SharedPreferences.getInstance();
                int? userId = prefs.getInt('user_id');
                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User not logged in.')),
                  );
                  return;
                }
                // Send POST request
                final response = await http.post(
                  Uri.parse('${ApiConfig.baseUrl}/study_room/join'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'user_id': userId,
                    'room_id': int.tryParse(codeController.text),
                  }),
                );
                if (response.statusCode == 200 || 
                    (response.statusCode == 400 && response.body.contains('User already in this study room'))) {
                  final data = jsonDecode(response.body);
                  // Save study room information
                  await prefs.setInt('study_room_id', data['room_id']);
                  await prefs.setString('room_name', data['room_name']);
                  await prefs.setString('room_description', data['room_description']);
                  Navigator.of(context).pop(); // Close Dialog
                  setState(() {}); // Refresh page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StudyRoomDetailPage()),
                  );
                } else if (response.statusCode == 404) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid room ID, please check and try again')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to join room. Please try again.')),
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFF417D74),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Join', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
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
          color: Color(0xFF93BDCE),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to leave this study room?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFF417D74),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('No', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    int? userId = prefs.getInt('user_id');
                    int? roomId = prefs.getInt('study_room_id');
                    if (userId == null || roomId == null) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User or room info not found.')),
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
                      setState(() {}); // Refresh page
                    } else {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to leave room. Please try again.')),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFF417D74),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Yes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}