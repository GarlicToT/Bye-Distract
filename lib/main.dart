import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'models/task.dart';
import 'pages/todo_list_page.dart';
import 'pages/statistics_page.dart';
import 'pages/study_room_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';
import 'pages/generator_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bye-Distract',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // 如果用户已登录，直接进入主页面
          if (snapshot.data == true) {
            return GeneratorPage();
          }
          
          // 否则显示登录页面
          return LoginPage();
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final userName = prefs.getString('user_name');
      
      // 如果同时存在用户ID和用户名，则认为用户已登录
      return userId != null && userName != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }
}

class GeneratorPage extends StatefulWidget {
  @override
  GeneratorPageState createState() => GeneratorPageState();
}

class GeneratorPageState extends State<GeneratorPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return TodoListPage();
      case 1:
        return StatisticsPage();
      case 2:
        return StudyRoomPage();
      case 3:
        return ProfilePage();
      default:
        return Container();
    }
  }

  Widget _buildBottomNavBar() => BottomNavigationBar(
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
  );
}