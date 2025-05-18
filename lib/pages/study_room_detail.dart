import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'study_room_page.dart';

class StudyRoomDetailPage extends StatefulWidget {
  @override
  _StudyRoomDetailPageState createState() => _StudyRoomDetailPageState();
}

class _StudyRoomDetailPageState extends State<StudyRoomDetailPage> {
  // int _selectedIndex = 2; // 保持和GeneratorPage一致，2为Study Room

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
    onPressed: () => Navigator.pop(context),
  ),
  title: Text('Study Room', style: TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  )),
  backgroundColor: Color(0xFFAED3EA),
  elevation: 0,
  centerTitle: true,
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Icon(Icons.settings, color: Colors.black, size: 28),
    ),
  ],
),
      // appBar: AppBar(
      //   title: Text('Study Room', style: TextStyle(
      //     color: Colors.white,
      //     fontSize: 24,
      //     fontWeight: FontWeight.bold,
      //   )),
      //   backgroundColor: Color(0xFFAED3EA),
      //   elevation: 0,
      //   centerTitle: true,
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.only(right: 16.0),
      //       child: Icon(Icons.settings, color: Colors.black, size: 28),
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFAED3EA),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Study Room',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Beta', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFE6A0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('2 persons', style: TextStyle(color: Color(0xFFB88A00), fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text('(Room Code: 123456)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text('Fighting', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Text('0', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Text('Focusing', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      SizedBox(width: 24),
                      Text('1', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Text('Your Rank', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildUserCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.blue,
      //   unselectedItemColor: Colors.grey,
      //   type: BottomNavigationBarType.fixed,
      //   backgroundColor: Colors.white,
      //   elevation: 8,
      //   onTap: (index) {
      //     setState(() {
      //       _selectedIndex = index;
      //     });
      //     // 跳转逻辑与GeneratorPage一致
      //     switch (index) {
      //       case 0:
      //         Navigator.pushReplacementNamed(context, '/');
      //         break;
      //       case 1:
      //         Navigator.pushReplacementNamed(context, '/statistics');
      //         break;
      //       case 2:
      //         Navigator.pushReplacementNamed(context, '/studyroom');
      //         break;
      //       case 3:
      //         Navigator.pushReplacementNamed(context, '/profile');
      //         break;
      //     }
      //   },
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.format_list_bulleted),
      //       label: 'To-do List',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.access_time),
      //       label: 'Statistics',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.meeting_room),
      //       label: 'Study Room',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person_outline),
      //       label: 'Me',
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFE6E6),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text('1', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.image, size: 32, color: Colors.grey[400]),
              ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tata', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Focused Today: 0 min', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF8A8A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Focus Streak: 0 days', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFD6B4FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Total focus: 0 days', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Column(
            children: [
              Text('0', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              Text('min', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            ],
          ),
        ],
      ),
    );
  }
}
