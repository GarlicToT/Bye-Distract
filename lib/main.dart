import 'dart:math';

import 'package:flutter/material.dart';

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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GeneratorPage(),
    );
  }
}

class GeneratorPage extends StatefulWidget {
  @override
  _GeneratorPageState createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  List<Task> tasks = [];
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
    return Container(
      decoration: BoxDecoration(
        color: getRandomColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Spacer(),
              Text(task.mode,
                  style: TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              // navigate to a new page (placeholder for now)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text('Task Page'),
                      leading: BackButton(), // this shows the back arrow
                    ),
                    body: Center(
                      child: Text('This is the new page'),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('To-do list'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _showAddTaskModal,
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: tasks.map((task) => buildTaskCard(task)).toList(),
          ),
        ),
      ),
      Center(child: Text('Statistics')),
      Center(child: Text('Study Room')),
      Center(child: Text('Me')),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'To-do List'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), label: 'Statistics'),
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Study Room'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}
