import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../config/api_config.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class CountupPage extends StatefulWidget {
  final String taskTitle;
  final int taskId;
  final bool shouldStartTimer;
  final bool shouldStartCamera;

  const CountupPage({
    Key? key, 
    required this.taskTitle, 
    required this.taskId,
    this.shouldStartTimer = false,
    this.shouldStartCamera = false,
  }) : super(key: key);

  @override
  State<CountupPage> createState() => _CountupPageState();
}

class _CountupPageState extends State<CountupPage> {
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _isFinished = false;
  CameraController? _cameraController;
  bool _isRecording = false;
  String? _videoPath;
  String _backgroundImage = ''; // Added to store random background image

  // List of available images in assets/images
  final List<String> _imageAssets = [
    'assets/images/geren.jpg',
    'assets/images/profile.jpg',
    'assets/images/studyroomlead.png',
    'assets/images/leaderboard.jpg',
    'assets/images/studyroom.jpg',
    'assets/images/purple.jpg',
    'assets/images/screen.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _selectRandomBackground();
    
    if (widget.shouldStartTimer) {
      _startTimer();
    }
    
    if (widget.shouldStartCamera) {
      _initializeCamera();
    }
  }

  void _selectRandomBackground() {
    setState(() {
      _backgroundImage = _imageAssets[DateTime.now().millisecond % _imageAssets.length];
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: true,
    );
    
    await _cameraController!.initialize();
    if (mounted) {
      setState(() {});
      if (widget.shouldStartCamera) {
        _startRecording();
      }
    }
  }

  Future<void> _startRecording() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final directory = await getTemporaryDirectory();
        _videoPath = '${directory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
        print('Start recording video');
      } catch (e) {
        print('Error starting recording: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error starting recording: $e')),
          );
        }
      }
    }
  }

  Future<void> _showCameraDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Open the camera'),
          content: Text('Do you want to open the camera to record?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
                // When the user chooses not to turn on the camera, only the timing starts
                _startTimer();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                // When the user chooses to turn on the camera, initialize the camera and start timing and recording
                await _initializeCamera();
                _startTimer();
                await _startRecording();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _stopRecording() async {
    if (_isRecording && _cameraController != null) {
      final XFile video = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _videoPath = video.path;
      });
      
    }
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
    final url = ApiConfig.finishTaskUrl;
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
            
            // 如果用户选择计入专注时长，则上传视频（如果有的话）
            if (!givenUp) {
              try {
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getInt('user_id');
                if (userId == null) {
                  print('未找到用户ID');
                  return;
                }
                print('准备上传数据，用户ID: $userId, 任务ID: ${widget.taskId}');

                // 如果有视频文件，则上传视频
                if (_videoPath != null) {
                  final file = File(_videoPath!);
                  if (await file.exists()) {
                    print('视频文件存在，大小: ${await file.length()} 字节');

                    // 构建上传URL，将user_id和task_id作为URL参数
                    final uploadUrl = '${ApiConfig.uploadansVideoUrl}?user_id=$userId&task_id=${widget.taskId}';
                    print('开始上传任务视频到: $uploadUrl');

                    // 创建multipart请求
                    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
                    
                    // 添加视频文件
                    final videoFile = await http.MultipartFile.fromPath(
                      'video',  // 确保这里的字段名与后端期望的一致
                      file.path,
                      contentType: MediaType('video', 'mp4'),
                    );
                    request.files.add(videoFile);

                    print('发送上传请求...\nRequest URL: ${request.url}\nRequest method: ${request.method}');
                    final streamedResponse = await request.send();
                    print('收到响应，状态码: ${streamedResponse.statusCode}');
                    
                    final response = await http.Response.fromStream(streamedResponse);
                    print('完整响应体: ${response.body}');
                    
                    if (response.statusCode == 200) {
                      print('视频上传成功！');
                      try {
                        final responseData = jsonDecode(response.body);
                        print('视频上传后端返回数据:');
                        print('状态: ${responseData['status'] ?? '未知'}');
                        print('专注比例: ${responseData['focus_ratio'] ?? '未知'}');
                        print('视频URL: ${responseData['video_url'] ?? '未知'}');
                      } catch (e) {
                        print('解析响应数据时出错: $e');
                      }
                    } else {
                      print('视频上传失败，状态码: ${response.statusCode}');
                      print('错误详情: ${response.body}');
                    }
                  } else {
                    print('视频文件不存在: $_videoPath');
                  }
                } else {
                  print('没有视频文件，仅上传任务完成数据');
                }
              } catch (e) {
                print('上传数据时出错: $e');
                print('错误堆栈: ${StackTrace.current}');
              }
            }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskTitle, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF9CCCCE),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 32),
            Text(
              widget.taskTitle.toUpperCase(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Montserrat', color: Colors.white),
            ),
            SizedBox(height: 24),
            Text(
              _formatTime(_elapsedSeconds),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4),
            ),
            SizedBox(height: 8),
            Text('Focusing', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 32),
            GestureDetector(
              onTap: _showCameraDialog,
              child: Container(
                width: 300,
                height: 300,
                color: Colors.white.withOpacity(0.7),
                child: _cameraController != null && _cameraController!.value.isInitialized
                    ? CameraPreview(_cameraController!)
                    : Center(child: Icon(Icons.camera_alt, size: 48, color: Colors.white)),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _isRecording ? _stopRecording : _finishTask,
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(_isRecording ? Icons.stop : Icons.stop, color: Colors.black, size: 32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }
}
