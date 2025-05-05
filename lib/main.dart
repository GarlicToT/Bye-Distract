import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(MyApp());

class Task {
  final String title;
  final String mode;
  final int? countdownTime; // in minutes

  Task({required this.title, required this.mode, this.countdownTime});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-do List',
      theme: ThemeData(
        primaryColor: Color(0xFFAED3EA),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFAED3EA),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: GeneratorPage(),
    );
  }
}

class GeneratorPage extends StatefulWidget {
  @override
  _GeneratorPageState createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  List<Task> tasks = [
    Task(title: 'IELTS Speaking', mode: 'count down', countdownTime: 30),
    Task(title: 'IELTS Listening', mode: 'count down', countdownTime: 45),
    Task(title: 'IELTS Reading', mode: 'count up'),
  ];
  int _selectedIndex = 0;

  void _showAddTaskModal() {
    String title = '';
    String mode = 'count down';
    double countdownTime = 25;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          child: Icon(Icons.close),
                          onTap: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Add List',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: Icon(Icons.check),
                          onTap: () {
                            if (title.trim().isNotEmpty) {
                              setState(() {
                                tasks.add(Task(
                                  title: title,
                                  mode: mode,
                                  countdownTime: mode == 'count down'
                                      ? countdownTime.toInt()
                                      : null,
                                ));
                              });
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                    TextField(
                      decoration: InputDecoration(
                          hintText: 'Enter task title',
                          contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                      onChanged: (val) {
                        setModalState(() {
                          title = val;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mode == 'count down'
                                ? Colors.blue
                                : Colors.grey[300],
                          ),
                          onPressed: () {
                            setModalState(() {
                              mode = 'count down';
                            });
                          },
                          child: Text('count down'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mode == 'count up'
                                ? Colors.blue
                                : Colors.grey[300],
                          ),
                          onPressed: () {
                            setModalState(() {
                              mode = 'count up';
                            });
                          },
                          child: Text('count up'),
                        ),
                      ],
                    ),
                    if (mode == 'count down') ...[
                      SizedBox(height: 10),
                      Text('${countdownTime.toInt()} minutes'),
                      Slider(
                        min: 5,
                        max: 60,
                        value: countdownTime,
                        divisions: 11,
                        label: '${countdownTime.toInt()} min',
                        onChanged: (val) {
                          setModalState(() {
                            countdownTime = val;
                          });
                        },
                      ),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(200),
      random.nextInt(200),
      random.nextInt(200),
    );
  }

  Widget buildTaskCard(Task task) {
    // 根据任务类型返回固定颜色
    Color getTaskColor() {
      switch(task.title.toLowerCase()) {
        case 'ielts speaking':
          return Color(0xFFAED3EA); // 浅蓝色
        case 'ielts listening':
          return Color(0xFFBFDDBE); // 浅绿色
        case 'ielts reading':
          return Color(0xFFFFD6D6); // 浅粉色
        default:
          return Color(0xFFAED3EA); // 默认浅蓝色
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: getTaskColor(),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    task.mode,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      Scaffold(
        appBar: AppBar(
          title: Text('To-do list'),
          actions: [
            IconButton(
              icon: Icon(Icons.add, color: Colors.black),
              onPressed: _showAddTaskModal,
            )
          ],
        ),
        body: ListView(
          children: tasks.map((task) => buildTaskCard(task)).toList(),
        ),
      ),
      StatisticsPage(),
      StudyRoomPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
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
      ),
    );
  }
}

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.emoji_events_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildTotalCard(),
          SizedBox(height: 16),
          _buildTodayCard(),
          SizedBox(height: 16),
          _buildDistributionCard(),
          SizedBox(height: 16),
          _buildTimePeriodCard(),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE6E6), Color(0xFFFF9E9E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTotalItem('frequency', '25'),
              _buildTotalItem('duration', '11 h 37 min'),
              _buildTotalItem('Average daily\nduration', '1 h 17 min'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE6E6), Color(0xFFFF9E9E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTotalItem('frequency', '3'),
              _buildTotalItem('duration', '150 min'),
              _buildTotalItem('give up', '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE6E6), Color(0xFFFF9E9E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distribution',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Text(
                    '2025-04-03',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: Colors.black54),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: Colors.black54),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Color(0xFFFFD6D6),
                    value: 70,
                    title: 'READING\n70 min',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  PieChartSectionData(
                    color: Color(0xFFBFDDBE),
                    value: 50,
                    title: 'LISTENING\n50 min',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  PieChartSectionData(
                    color: Color(0xFFAED3EA),
                    value: 30,
                    title: 'WORDS\n30 min',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
                sectionsSpace: 0,
                centerSpaceRadius: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE6E6), Color(0xFFFF9E9E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time period distribution',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Text(
                    '2025-04-03',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: Colors.black54),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: Colors.black54),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Center(
              child: Text(
                '时间段分布图表将在这里显示',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StudyRoomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Study Room',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(0xFFAED3EA),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircularButton(
              icon: Icons.add,
              label: 'Create Room',
              color: Color(0xFFFFD6D6),
              onTap: () {
                // TODO: 实现创建房间功能
              },
            ),
            SizedBox(height: 40),
            _buildCircularButton(
              icon: Icons.home,
              label: 'Join Room',
              color: Color(0xFFAED3EA),
              onTap: () {
                // TODO: 实现加入房间功能
              },
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
                Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  label,
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
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // TODO: 实现设置功能
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          // 头像部分
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: Icon(
                    Icons.image,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Tata',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          // 选项卡部分
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildOptionCard(
                  icon: Icons.person,
                  title: 'Profile',
                  color: Color(0xFFFFE6E6),
                  onTap: () {
                    // TODO: 实现个人资料功能
                  },
                ),
                SizedBox(height: 16),
                _buildOptionCard(
                  icon: Icons.check_circle,
                  title: 'Whitelist',
                  color: Color(0xFFBFDDBE),
                  onTap: () {
                    // TODO: 实现白名单功能
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 24),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
