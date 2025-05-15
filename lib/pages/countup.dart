import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CountupPage extends StatefulWidget {
  final String taskTitle;
  final int taskId;

  const CountupPage({Key? key, required this.taskTitle, required this.taskId}) : super(key: key);

  @override
  State<CountupPage> createState() => _CountupPageState();
}

class _CountupPageState extends State<CountupPage> {
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isFinished) {
        setState(() {
          _elapsedSeconds++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _finishTask() async {
    if (_isFinished) return;
    setState(() { _isFinished = true; });
    _timer?.cancel();

    final url = 'http://10.252.88.78:8001/tasks/finish';
    final body = jsonEncode({
      'task_id': widget.taskId,
      'time': _elapsedSeconds,
      'given_up': false,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final finishedTime = data['time'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('任务已完成，专注时长: $finishedTime 秒')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('任务完成请求失败: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('网络错误: $e')),
        );
      }
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m : $s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskTitle),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          SizedBox(height: 32),
          Text(
            widget.taskTitle.toUpperCase(),
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
          ),
          SizedBox(height: 24),
          Text(
            _formatTime(_elapsedSeconds),
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
                GestureDetector(
                  onTap: _finishTask,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.stop, color: Colors.white, size: 32),
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
