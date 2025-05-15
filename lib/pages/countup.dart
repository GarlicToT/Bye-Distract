import 'package:flutter/material.dart';

class CountupPage extends StatelessWidget {
  final String taskTitle;

  const CountupPage({Key? key, required this.taskTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(taskTitle),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          SizedBox(height: 32),
          Text(
            taskTitle.toUpperCase(),
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
          ),
          SizedBox(height: 24),
          Text(
            '3 : 18', // 这里后续可替换为动态时间
            style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.lightBlue[100], letterSpacing: 4),
          ),
          SizedBox(height: 8),
          Text('Focusing', style: TextStyle(fontSize: 20)),
          SizedBox(height: 32),
          Center(
            child: Container(
              width: 300,
              height: 300,
              color: Colors.black12,
              child: Center(child: Icon(Icons.camera_alt, size: 48, color: Colors.grey[400])),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.pause, color: Colors.white, size: 32),
                ),
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.stop, color: Colors.white, size: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
