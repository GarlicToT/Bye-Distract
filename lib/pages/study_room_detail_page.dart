import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudyRoomDetailPage extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String roomDescription;
  final int initialPageIndex;

  StudyRoomDetailPage({
    Key? key,
    required this.roomId,
    required this.roomName,
    required this.roomDescription,
    this.initialPageIndex = 2,
  }) : super(key: key);

  @override
  State<StudyRoomDetailPage> createState() => _StudyRoomDetailPageState();
}

class _StudyRoomDetailPageState extends State<StudyRoomDetailPage> {
  late int _selectedIndex;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialPageIndex;
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
    });
  }

  Widget _buildBottomNavBar() => BottomNavigationBar(
    currentIndex: _selectedIndex,
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    elevation: 8,
    onTap: (index) {
      if (index == widget.initialPageIndex) {
      } else {
        Navigator.of(context).pop(index);
      }
    },
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.format_list_bulleted),
        label: 'To-do List',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.access_time),
        label: 'Statistics',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.meeting_room),
        label: 'Study Room',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Me',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      'Study Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.arrow_back_ios, size: 28, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 24,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(Icons.settings, size: 32, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 24, right: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.roomName,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '(Room ID: ${widget.roomId})',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  widget.roomDescription,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text('1', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  SizedBox(width: 4),
                                  Text('Your Rank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFE4E1),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('1', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                              SizedBox(width: 12),
                              CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                radius: 28,
                                child: Icon(Icons.image, size: 32, color: Colors.grey),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(_userName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                        Spacer(),
                                        Icon(Icons.star_border, color: Colors.black54),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Text('Focused Today: 0 min', style: TextStyle(fontSize: 16)),
                                    SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text('0', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                                        Text('min', style: TextStyle(fontSize: 16, color: Colors.black54)),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
} 