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

  Widget _buildBottomNavBar() {
    final screenSize = MediaQuery.of(context).size;
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 8,
      selectedFontSize: screenSize.width * 0.03, // 选中项字体大小
      unselectedFontSize: screenSize.width * 0.03, // 未选中项字体大小
      iconSize: screenSize.width * 0.06, // 图标大小
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
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.05; // 水平内边距为屏幕宽度的5%
    final verticalSpacing = screenSize.height * 0.02; // 垂直间距为屏幕高度的2%

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      'Study Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenSize.width * 0.07, // 字体大小为屏幕宽度的7%
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    left: padding,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: screenSize.width * 0.06, // 图标大小为屏幕宽度的6%
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: padding,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(
                        Icons.settings,
                        size: screenSize.width * 0.08, // 图标大小为屏幕宽度的8%
                        color: Colors.black54,
                      ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: padding,
                        vertical: verticalSpacing * 2,
                      ),
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
                                        fontSize: screenSize.width * 0.07,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: verticalSpacing),
                                Text(
                                  '(Room ID: ${widget.roomId})',
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.045,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                SizedBox(height: verticalSpacing),
                                Text(
                                  widget.roomDescription,
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.04,
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
                                  Text(
                                    '1',
                                    style: TextStyle(
                                      fontSize: screenSize.width * 0.07,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(width: screenSize.width * 0.01),
                                  Text(
                                    'Your Rank',
                                    style: TextStyle(
                                      fontSize: screenSize.width * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 2),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
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
                          padding: EdgeInsets.all(screenSize.width * 0.04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '1',
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.08,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: screenSize.width * 0.03),
                              CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                radius: screenSize.width * 0.07,
                                child: Icon(
                                  Icons.image,
                                  size: screenSize.width * 0.08,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: screenSize.width * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _userName,
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.055,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(
                                          Icons.star_border,
                                          color: Colors.black54,
                                          size: screenSize.width * 0.06,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: verticalSpacing),
                                    Text(
                                      'Focused Today: 0 min',
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.04,
                                      ),
                                    ),
                                    SizedBox(height: verticalSpacing),
                                    Row(
                                      children: [
                                        Text(
                                          '0',
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.08,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'min',
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.04,
                                            color: Colors.black54,
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
                    ),
                    SizedBox(height: verticalSpacing * 2),
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