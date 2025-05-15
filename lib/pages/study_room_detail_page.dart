import 'package:flutter/material.dart';

class StudyRoomDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                    right: 24,
                    top: 0,
                    child: Icon(Icons.settings, size: 32, color: Colors.black54),
                  ),
                ],
              ),
            ),
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
                              'Beta',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFE4A0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '2 persons',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          '(Room Code: 123456)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fighting',
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
                          Text('0', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                          SizedBox(width: 4),
                          Text('Focusing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)),
                        ],
                      ),
                      SizedBox(height: 8),
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
                                Text('Tata', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFA09A),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('Focus Streak: 0 days', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFD1B3FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('Total Focus: 0 days', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          ],
        ),
      ),
    );
  }
} 