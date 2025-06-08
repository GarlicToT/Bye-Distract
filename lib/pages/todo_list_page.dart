import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../config/api_config.dart';
import 'countdown.dart';
import 'countup.dart';

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

      // final response = await http.get(Uri.parse('${ApiConfig.fetchTasksUrl}/$userId'));
      final response = await http.get(
  Uri.parse('${ApiConfig.fetchTasksUrl}/$userId'),);
      
      print('Fetching tasks from: ${ApiConfig.fetchTasksUrl}/$userId');
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
      
      print('Sending request to: ${ApiConfig.addTaskUrl}');
      print('Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(ApiConfig.addTaskUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

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
      print('Sending delete request to: ${ApiConfig.deleteTaskUrl}');
      print('Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(ApiConfig.deleteTaskUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Delete response status code: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['code'] == 200) {
          // Remove the deleted task from the local task list
          setState(() {
            _tasks.removeWhere((task) => task.taskId == taskId);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task deleted successfully!'))
          );
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

  Future<void> _modifyTask(Task task, String newTitle, String newMode, double? countdownTimeInMinutes) async {
    try {
      final requestBody = {
        'task_id': task.taskId,
        'expected_mode': newMode == 'count down' ? 0 : 1,
        'title': newTitle,
        'time': newMode == 'count down' ? (countdownTimeInMinutes ?? 0) * 60 : 0,
      };
      
      print('Sending modify request to: ${ApiConfig.modifyTaskUrl}');
      print('Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(ApiConfig.modifyTaskUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Modify response status code: ${response.statusCode}');
      print('Modify response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Update the corresponding task in the task list
        setState(() {
          final taskIndex = _tasks.indexWhere((t) => t.taskId == task.taskId);
          if (taskIndex != -1) {
            _tasks[taskIndex] = Task(
              taskId: responseData['task_id'],
              title: responseData['title'],
              mode: responseData['expected_mode'] == 0 ? 'count down' : 'count up',
              countdownTime: responseData['expected_mode'] == 0 ? (responseData['time'] as int) ~/ 60 : null,
              isRunning: false,
            );
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task modified successfully!'))
        );
      } else {
        throw Exception('Failed to modify task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error modifying task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to modify task: $e'))
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
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes', style: TextStyle(color: Colors.red)),
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
                color: Color(0xFF95B0B6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          child: Icon(Icons.close, color: Colors.white),
                          onTap: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Add List',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: Icon(Icons.check, color: Colors.white),
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
                                ? Color(0xFF9CCCCE)
                                : Color(0xFF788682),
                          ),
                          onPressed: () =>
                              setModalState(() => mode = 'count down'),
                          child: Text('count down', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mode == 'count up'
                                ? Color(0xFF9CCCCE)
                                : Color(0xFF788682),
                          ),
                          onPressed: () =>
                              setModalState(() => mode = 'count up'),
                          child: Text('count up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (mode == 'count down') ...[
                      SizedBox(height: 10),
                      Text('${countdownTimeSliderValue.toInt()} minutes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Slider(
                        min: 5,
                        max: 60,
                        value: countdownTimeSliderValue,
                        divisions: 11,
                        label: '${countdownTimeSliderValue.toInt()} min',
                        onChanged: (val) =>
                            setModalState(() => countdownTimeSliderValue = val),
                        activeColor: Color(0xFF9CCCCE),
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
    // Define colors using the provided color palette with added transparency (0xD0 alpha)
    final colors = [
      Color(0xD095B0B6), // Soft blue-gray with transparency
      Color(0xD09CCCCE), // Light teal with transparency
      Color(0xD0DABFAE), // Soft peach with transparency
      Color(0xD08FA069), // Sage green with transparency
      Color(0xD07C94A5), // Muted blue with transparency
      Color(0xD0788682), // Gray-green with transparency
    ];
    
    int taskIndex = _tasks.indexWhere((t) => t.taskId == task.taskId);
    if (taskIndex != -1) {
      return colors[taskIndex % colors.length];
    }
    
    // Specific colors for IELTS tasks with transparency
    switch (task.title.toLowerCase()) {
      case 'ielts speaking':
        return Color(0xD095B0B6); // Soft blue-gray with transparency
      case 'ielts listening':
        return Color(0xD08FA069); // Sage green with transparency
      case 'ielts reading':
        return Color(0xD0DABFAE); // Soft peach with transparency
      default:
        return colors[task.title.hashCode % colors.length];
    }
  }

  void _showModifyTaskDialog(Task task) {
    String mode = task.mode;
    double countdownTimeSliderValue = task.countdownTime?.toDouble() ?? 25.0;
    TextEditingController titleController = TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xFF788682),
              title: Text('Modify Task Mode', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mode == 'count down'
                              ? Color(0xFF9CCCCE)
                              : Color(0xFF95B0B6),
                        ),
                        onPressed: () => setState(() => mode = 'count down'),
                        child: Text('count down',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mode == 'count up'
                              ? Color(0xFF9CCCCE)
                              : Color(0xFF95B0B6),
                        ),
                        onPressed: () => setState(() => mode = 'count up'),
                        child: Text('count up',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )
                        ),
                      ),
                    ],
                  ),
                  if (mode == 'count down') ...[
                    SizedBox(height: 16),
                    Text('${countdownTimeSliderValue.toInt()} minutes', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                    Slider(
                      min: 5,
                      max: 60,
                      value: countdownTimeSliderValue,
                      divisions: 11,
                      label: '${countdownTimeSliderValue.toInt()} min',
                      onChanged: (val) => setState(() => countdownTimeSliderValue = val),
                      activeColor: Color(0xFF9CCCCE),
                    ),
                  ],
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Delete', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showDeleteConfirmationDialog(task);
                  },
                ),
                TextButton(
                  child: Text('Cancel', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.check_circle_outline, size: 20, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _modifyTask(
                      task,
                      titleController.text,
                      mode,
                      mode == 'count down' ? countdownTimeSliderValue : null,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTaskOptionsDialog(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Task Options'),
          content: Text('What would you like to do with "${task.title}"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Modify Task'),
              onPressed: () {
                Navigator.of(context).pop();
                _showModifyTaskDialog(task);
              },
            ),
            TextButton(
              child: Text('Delete Task', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(task);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final padding = screenSize.width * 0.04;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9CCCCE),
        title: Text('My Tasks', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchTasks,
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _showAddTaskModal,
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/screen.jpg'),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  children: [
                    _buildTrainingTaskCard(),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: padding * 0.5,
                          mainAxisSpacing: padding * 0.3,
                        ),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskCard(_tasks[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTrainingTaskCard() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final fontSize = isTablet ? 20.0 : 18.0;
    final iconSize = isTablet ? 40.0 : 32.0;
    final padding = screenSize.width * 0.03;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color(0xFFDABFAE),
              title: Text('Train Your Focus Model'),
              content: Text('This task is used to train your focus model. Please upload a video of you in a focused state.'),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'No',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'Yes',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CountdownPage(
                          taskTitle: 'Train Your Focus Model',
                          initialSeconds: 5,
                          taskId: -1,
                          isTrainingTask: true,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: padding * 0.3),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Color(0xD07C94A5), // Muted blue for training card with transparency
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Train Your Focus Model',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '5s',
                    style: TextStyle(
                      fontSize: fontSize * 0.8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                final shouldRefresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CountdownPage(
                      taskTitle: 'Train Your Focus Model',
                      initialSeconds: 5,
                      taskId: -1,
                      isTrainingTask: true,
                    ),
                  ),
                );
                if (shouldRefresh == true) {
                  _fetchTasks();
                }
              },
              child: Icon(
                Icons.play_circle_fill,
                size: iconSize,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final fontSize = isTablet ? 16.0 : 14.0;
    final iconSize = isTablet ? 32.0 : 28.0;
    final padding = screenSize.width * 0.02;

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
        _showModifyTaskDialog(task);
      },
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: _getTaskColor(task),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.mode == 'count down' && countDownDisplayTime.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        countDownDisplayTime,
                        style: TextStyle(
                          fontSize: fontSize * 0.8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () async {
                  final shouldRefresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => task.mode == 'count down'
                          ? CountdownPage(
                              taskTitle: task.title,
                              initialSeconds: (task.countdownTime ?? 0) * 60,
                              taskId: task.taskId,
                            )
                          : CountupPage(
                              taskTitle: task.title,
                              taskId: task.taskId,
                            ),
                    ),
                  );
                  if (shouldRefresh == true) {
                    _fetchTasks();
                  }
                },
                child: Icon(
                  task.mode == 'count down' ? Icons.play_circle_fill : Icons.timer_outlined,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


