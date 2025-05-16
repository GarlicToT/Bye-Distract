import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Complete Timer'),
          content: Text('Do you want to count this session in statistics?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
                _submitTaskToServerWithGivenUp(true);
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _submitTaskToServerWithGivenUp(false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitTaskToServerWithGivenUp(bool givenUp) async {
    final url = 'http://10.252.88.78:8001/tasks/finish';
    final body = jsonEncode({
      'task_id': widget.taskId,
      'time': _elapsedSeconds,
      'given_up': givenUp,
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
          if (data['task_id'] == widget.taskId && 
              data['is_finished'] == true) {
            Navigator.of(context).pop(true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid response from server')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to complete task: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
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
