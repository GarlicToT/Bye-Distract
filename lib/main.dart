import 'package:flutter/material.dart';
// import 'models/task.dart';
import 'pages/todo_list_page.dart';
import 'pages/statistics_page.dart';
import 'pages/study_room_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
      // home: GeneratorPage(),
      home: LoginPage(),
    );
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