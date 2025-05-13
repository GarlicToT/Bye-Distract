import 'package:flutter/material.dart';
import '../models/task.dart';
import 'dart:async';

class TodoListPage extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onAddTask;

  const TodoListPage({
    Key? key,
    required this.tasks,
    required this.onAddTask,
  }) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown(Task task) {
    if (task.mode == 'count down' && task.countdownTime != null) {
      setState(() {
        task.isRunning = true;
        _remainingSeconds = task.countdownTime! * 60;
      });

      _timer?.cancel();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            task.isRunning = false;
            timer.cancel();
          }
        });
      });
    }
  }

  void _stopCountdown(Task task) {
    setState(() {
      task.isRunning = false;
      _remainingSeconds = 0;
    });
    _timer?.cancel();
  }

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
                              widget.onAddTask(Task(
                                title: title,
                                mode: mode,
                                countdownTime: mode == 'count down'
                                    ? countdownTime.toInt()
                                    : null,
                              ));
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
                      onChanged: (val) => setModalState(() => title = val),
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
                          onPressed: () => setModalState(() => mode = 'count down'),
                          child: Text('count down'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mode == 'count up'
                                ? Colors.blue
                                : Colors.grey[300],
                          ),
                          onPressed: () => setModalState(() => mode = 'count up'),
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
                        onChanged: (val) => setModalState(() => countdownTime = val),
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
    switch (task.title.toLowerCase()) {
      case 'ielts speaking':
        return Color(0xFFAED3EA);
      case 'ielts listening':
        return Color(0xFFBFDDBE);
      case 'ielts reading':
        return Color(0xFFFFD6D6);
      default:
        return Color(0xFFAED3EA);
    }
  }

  Widget _buildTaskCard(Task task) {
    return GestureDetector(
      onTap: () {
        if (task.mode == 'count down') {
          if (task.isRunning) {
            _stopCountdown(task);
          } else {
            _startCountdown(task);
          }
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
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
                    if (task.isRunning && task.mode == 'count down')
                      Text(
                        '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    else
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
                task.isRunning ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        children: widget.tasks.map(_buildTaskCard).toList(),
      ),
    );
  }
}