import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// import '../config/api_config.dart';

class CountdownPage extends StatefulWidget {
  final String taskTitle;
  final int initialSeconds;
  final int taskId;
  final bool isTrainingTask;

  const CountdownPage({
    Key? key, 
    required this.taskTitle, 
    required this.initialSeconds, 
    required this.taskId,
    this.isTrainingTask = false,
  }) : super(key: key);

  @override
  State<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isFinished = false;
  int _usedSeconds = 0;
  CameraController? _cameraController;
  bool _isRecording = false;
  String? _videoPath;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _startTimer();
    _initializeCamera();
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
      // 只有训练任务才自动开始录制
      if (widget.isTrainingTask) {
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
        print('开始录制视频');
      } catch (e) {
        print('开始录制时出错: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('开始录制时出错：$e')),
          );
        }
      }
    }
  }

  Future<void> _showCameraDialog() async {
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('开启摄像头'),
          content: Text('是否要开启摄像头进行录制？'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
                _startTimer();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _startRecording();
                _startTimer();
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
      
      if (widget.isTrainingTask) {
        await _uploadTrainingVideo();
      }
    }
  }

  Future<void> _uploadTrainingVideo() async {
    try {
      print('开始上传视频');
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) {
        print('未找到用户ID');
        return;
      }

      if (_videoPath == null) {
        print('没有视频文件可上传');
        return;
      }

      print('视频文件路径: $_videoPath');
      final file = File(_videoPath!);
      if (!await file.exists()) {
        print('视频文件不存在');
        return;
      }

      print('创建上传请求');
      final request = http.MultipartRequest(
        'POST',
        // Uri.parse('http://10.252.88.78:8001/videos/upload/reference')
        Uri.parse(ApiConfig.uploadVideoUrl) 
      );

      // 添加视频文件，使用正确的字段名 'video'
      final videoFile = await http.MultipartFile.fromPath(
        'video',
        file.path,
        contentType: MediaType('video', 'mp4'),
      );
      request.files.add(videoFile);

      print('发送上传请求');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('上传响应状态码: ${response.statusCode}');
      print('上传响应体: ${response.body}');

      if (response.statusCode == 200) {
        print('上传成功');
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('训练完成'),
                content: Text('您已完成专注模型训练！'),
                actions: <Widget>[
                  TextButton(
                    child: Text('确定'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        print('上传失败，状态码: ${response.statusCode}');
        print('错误详情: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('上传失败，请重试: ${response.body}')),
          );
        }
      }
    } catch (e) {
      print('上传视频时出错: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上传出错：$e')),
        );
      }
    }
  }

  void _startTimer() {
    print('开始倒计时');
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        print('剩余时间: $_remainingSeconds 秒');
      } else {
        print('倒计时结束');
        timer.cancel();
        if (widget.isTrainingTask) {
          print('这是训练任务，准备处理视频');
          _handleTrainingTaskCompletion();
        } else {
          _finishTask();
        }
      }
    });
  }

  Future<void> _handleTrainingTaskCompletion() async {
    print('开始处理训练任务完成');
    if (_isRecording && _cameraController != null) {
      try {
        print('正在停止录制...');
        // 停止录制
        final XFile video = await _cameraController!.stopVideoRecording();
        print('录制已停止，视频保存在: ${video.path}');
        
        setState(() {
          _isRecording = false;
          _videoPath = video.path;
        });

        print('正在关闭摄像头...');
        // 关闭摄像头
        await _cameraController!.dispose();
        _cameraController = null;
        print('摄像头已关闭');

        print('准备上传视频...');
        // 上传视频
        await _uploadTrainingVideo();
      } catch (e) {
        print('处理训练任务时出错: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('处理视频时出错：$e')),
          );
        }
      }
    } else {
      print('摄像头状态: ${_cameraController != null ? "已初始化" : "未初始化"}');
      print('录制状态: ${_isRecording ? "正在录制" : "未在录制"}');
    }
  }

  Future<void> _finishTask() async {
    if (_isFinished) return;
    setState(() { _isFinished = true; });
    _timer?.cancel();
    _usedSeconds = widget.initialSeconds - _remainingSeconds;

    if (!widget.isTrainingTask) {
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
  }

  Future<void> _submitTaskToServerWithGivenUp(bool givenUp) async {
    final url = ApiConfig.finishTaskUrl;
    final body = jsonEncode({
      'task_id': widget.taskId,
      'time': _usedSeconds,
      'given_up': givenUp,
    });
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 验证返回的数据是否完整
        if (data['task_id'] == widget.taskId && 
            data['is_finished'] == true) {
          // 保存time到SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('finished_time_task_${widget.taskId}', data['time']);
          
          // 如果用户选择计入专注时长，且不是训练任务，则上传视频
          if (!givenUp && !widget.isTrainingTask && _videoPath != null) {
            try {
              final userId = prefs.getInt('user_id');
              if (userId == null) {
                print('未找到用户ID');
                return;
              }

              final file = File(_videoPath!);
              if (!await file.exists()) {
                print('视频文件不存在');
                return;
              }

              print('开始上传任务视频');
              final request = http.MultipartRequest(
                'POST',
                Uri.parse('${ApiConfig.uploadansVideoUrl}?user_id=$userId&task_id=${widget.taskId}')
              );

              // 添加视频文件
              final videoFile = await http.MultipartFile.fromPath(
                'video',
                file.path,
                contentType: MediaType('video', 'mp4'),
              );
              request.files.add(videoFile);

              print('发送上传请求');
              final streamedResponse = await request.send();
              final response = await http.Response.fromStream(streamedResponse);
              print('上传响应状态码: ${response.statusCode}');
              print('上传响应体: ${response.body}');
              
              // 打印后端返回的详细内容
              try {
                final responseData = jsonDecode(response.body);
                print('视频上传后端返回数据:');
                print('状态: ${responseData['status'] ?? '未知'}');
                print('消息: ${responseData['message'] ?? '无消息'}');
                print('数据: ${responseData['data'] ?? '无数据'}');
              } catch (e) {
                print('解析响应数据时出错: $e');
                print('原始响应内容: ${response.body}');
              }
            } catch (e) {
              print('上传视频时出错: $e');
            }
          }
          
          if (mounted) {
            Navigator.of(context).pop(true); // 返回true表示需要刷新
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid response from server')),
            );
          }
        }
      } else {
        if (mounted) {
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
            _formatTime(_remainingSeconds),
            style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.lightBlue[100], letterSpacing: 4),
          ),
          SizedBox(height: 8),
          Text('Focusing', style: TextStyle(fontSize: 20)),
          SizedBox(height: 32),
          GestureDetector(
            onTap: _showCameraDialog,
            child: Container(
              width: 300,
              height: 300,
              color: Colors.black12,
              child: _cameraController != null && _cameraController!.value.isInitialized
                  ? CameraPreview(_cameraController!)
                  : Center(child: Icon(Icons.camera_alt, size: 48, color: Colors.grey[400])),
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
                  onTap: _isRecording ? _stopRecording : _finishTask,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.black,
                    child: Icon(_isRecording ? Icons.stop : Icons.stop, color: Colors.white, size: 32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('组件销毁，清理资源');
    _timer?.cancel();
    if (_cameraController != null) {
      print('清理摄像头资源');
      _cameraController!.dispose();
      _cameraController = null;
    }
    super.dispose();
  }
}
