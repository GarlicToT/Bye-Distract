import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  Timer? _timer;
  int _remainingSeconds = 0;
  final String addTaskBaseUrl = 'http://10.252.88.78:8001/tasks/add';
  final String fetchTasksBaseUrl = 'http://10.252.88.78:8001/tasks';
  final String deleteTaskBaseUrl = 'http://10.252.88.78:8001/tasks/del';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) {
        print('User ID not found, cannot fetch tasks.');
        setState(() {
          _isLoading = false;
          _tasks = [];
        });
        return;
      }

      final response = await http.get(Uri.parse('$fetchTasksBaseUrl/$userId'));
      
      print('Fetching tasks from: $fetchTasksBaseUrl/$userId');
      print('Fetch tasks response status: ${response.statusCode}');
      print('Fetch tasks response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> tasksJson = jsonDecode(response.body);
        final List<Task> fetchedTasks = [];
        for (var taskJson in tasksJson) {
          if (taskJson['is_finished'] == false && taskJson['given_up'] == false) {
            fetchedTasks.add(Task(
              taskId: taskJson['task_id'],
              title: taskJson['title'],
              mode: taskJson['expected_mode'] == 0 ? 'count down' : 'count up',
              countdownTime: taskJson['expected_mode'] == 0 && taskJson['time'] != null 
                  ? (taskJson['time'] as int) ~/ 60 
                  : null,
              isRunning: false,
            ));
          }
        }
        setState(() {
          _tasks = fetchedTasks;
          _isLoading = false;
        });
      } else {
        print('Failed to load tasks: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTaskToServer(String title, String mode, int? countdownTimeInMinutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      
      final requestBody = {
        'user_id': userId,
        'expected_mode': mode == 'count down' ? 0 : 1,
        'title': title,
        'time': mode == 'count down' ? (countdownTimeInMinutes ?? 0) * 60 : 0,
      };
      
      print('发送请求到: $addTaskBaseUrl');
      print('请求体: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(addTaskBaseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('响应状态码: ${response.statusCode}');
      print('响应体: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchTasks();
      } else {
        throw Exception('Failed to add task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task: $e'))
      );
    }
  }

  Future<void> _deleteTaskFromServer(int taskId) async {
    try {
      final requestBody = {'task_id': taskId};
      print('发送删除请求到: $deleteTaskBaseUrl');
      print('请求体: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(deleteTaskBaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('删除响应状态码: ${response.statusCode}');
      print('删除响应体: ${response.body}');

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['code'] == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseJson['message'] ?? 'delete successful!'))
          );
          _fetchTasks();
        } else {
          throw Exception('Failed to delete task: ${responseJson['message']}');
        }
      } else {
        throw Exception('Failed to delete task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e'))
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown(Task task) {
    if (task.mode == 'count down' && task.countdownTime != null && task.countdownTime! > 0) {
      final taskInList = _tasks.firstWhere((t) => t.taskId == task.taskId, orElse: () => task);
      
      setState(() {
        for (var t in _tasks) {
          if (t.isRunning && t.taskId != taskInList.taskId) {
            t.isRunning = false;
          }
        }
        taskInList.isRunning = true;
        _remainingSeconds = taskInList.countdownTime! * 60;
      });

      _timer?.cancel();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            taskInList.isRunning = false;
            timer.cancel();
          }
        });
      });
    }
  }

  void _stopCountdown(Task task) {
    final taskInList = _tasks.firstWhere((t) => t.taskId == task.taskId, orElse: () => task);
    setState(() {
      taskInList.isRunning = false;
      _remainingSeconds = 0;
    });
    _timer?.cancel();
  }

  void _showDeleteConfirmationDialog(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete the task "${task.title}" ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTaskFromServer(task.taskId);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskModal() {
    String title = '';
    String mode = 'count down';
    double countdownTimeSliderValue = 25;

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
                          onTap: () async {
                            if (title.trim().isNotEmpty) {
                              await _addTaskToServer(
                                title.trim(),
                                mode,
                                mode == 'count down' ? countdownTimeSliderValue.toInt() : null,
                              );
                              
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Task title cannot be empty.'))
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    TextField(
                      decoration: InputDecoration(
                          hintText: 'Enter task title',
                          contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                      onChanged: (val) => title = val,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mode == 'count down'
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300],
                          ),
                          onPressed: () =>
                              setModalState(() => mode = 'count down'),
                          child: Text('count down', style: TextStyle(color: mode == 'count down' ? Colors.white : Colors.black)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mode == 'count up'
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300],
                          ),
                          onPressed: () =>
                              setModalState(() => mode = 'count up'),
                          child: Text('count up', style: TextStyle(color: mode == 'count up' ? Colors.white : Colors.black)),
                        ),
                      ],
                    ),
                    if (mode == 'count down') ...[
                      SizedBox(height: 10),
                      Text('${countdownTimeSliderValue.toInt()} minutes'),
                      Slider(
                        min: 5,
                        max: 60,
                        value: countdownTimeSliderValue,
                        divisions: 11,
                        label: '${countdownTimeSliderValue.toInt()} min',
                        onChanged: (val) =>
                            setModalState(() => countdownTimeSliderValue = val),
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

  Color _getTaskColor(Task task) {
    final colors = [
      Color(0xFFAED3EA), Color(0xFFBFDDBE), Color(0xFFFFD6D6), 
      Color(0xFFFFFACD), Color(0xFFE6E6FA), Color(0xFFFFE4E1)
    ];
    int taskIndex = _tasks.indexWhere((t) => t.taskId == task.taskId);
    if (taskIndex != -1) {
      return colors[taskIndex % colors.length];
    }
    switch (task.title.toLowerCase()) {
      case 'ielts speaking':
        return Color(0xFFAED3EA);
      case 'ielts listening':
        return Color(0xFFBFDDBE);
      case 'ielts reading':
        return Color(0xFFFFD6D6);
      default:
        return colors[task.title.hashCode % colors.length];
    }
  }

  Widget _buildTaskCard(Task task) {
    String countDownDisplayTime = '';
    if (task.mode == 'count down') {
      if (task.isRunning) {
        int minutes = _remainingSeconds ~/ 60;
        int seconds = _remainingSeconds % 60;
        countDownDisplayTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      } else if (task.countdownTime != null) {
        countDownDisplayTime = '${task.countdownTime} min';
      }
    }

    return GestureDetector(
      onTap: () {
        if (task.mode == 'count down') {
          if (task.isRunning) {
            _stopCountdown(task);
          } else {
            _startCountdown(task);
          }
        } else if (task.mode == 'count up') {
          print("Count up task tapped. ID: ${task.taskId}");
        }
      },
      onLongPress: () {
        _showDeleteConfirmationDialog(task);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getTaskColor(task),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  if (task.mode == 'count down' && countDownDisplayTime.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        countDownDisplayTime,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (task.mode == 'count down')
                  Icon(
                    task.isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    size: 32,
                    color: Colors.black.withOpacity(0.7),
                  ),
                if (task.mode == 'count up')
                  Icon(
                    Icons.timer_outlined,
                    size: 32,
                    color: Colors.black.withOpacity(0.7),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchTasks,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddTaskModal,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Text(
                    'No tasks yet. Add one!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 2 / 1,
                    children: _tasks.map((task) => _buildTaskCard(task)).toList(),
                  ),
                ),
    );
  }
}
