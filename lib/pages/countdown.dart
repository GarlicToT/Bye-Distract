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
    // 只有训练任务才自动开始计时和初始化摄像头
    if (widget.isTrainingTask) {
      _startTimer();
      _initializeCamera();
    }
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
    print('开始录制视频');
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final directory = await getTemporaryDirectory();
        _videoPath = '${directory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
        print('视频将保存到: $_videoPath');
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
        print('开始录制视频成功');
      } catch (e) {
        print('开始录制时出错: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('开始录制时出错：$e')),
          );
        }
      }
    } else {
      print('摄像头未初始化，无法开始录制');
    }
  }

  Future<void> _showCameraDialog() async {
    print('显示摄像头对话框');
    
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
                print('用户选择不开启摄像头');
                Navigator.of(context).pop();
                // 非训练任务且用户选择不开启摄像头时，开始计时
                if (!widget.isTrainingTask) {
                  _startTimer();
                }
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                print('用户选择开启摄像头');
                Navigator.of(context).pop();
                // 非训练任务且用户选择开启摄像头时，初始化摄像头并开始计时和录制
                if (!widget.isTrainingTask) {
                  await _initializeCamera();
                  _startTimer();
                  await _startRecording();
                } else {
                  await _initializeCamera();
                  await _startRecording();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _stopRecording() async {
    print('停止录制视频');
    if (_isRecording && _cameraController != null) {
      try {
        final XFile video = await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _videoPath = video.path;
        });
        print('视频已保存到: $_videoPath');
        
        if (widget.isTrainingTask) {
          print('这是训练任务，准备上传视频');
          await _uploadTrainingVideo();
        }
      } catch (e) {
        print('停止录制时出错: $e');
      }
    } else {
      print('没有正在录制的视频或摄像头未初始化');
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
      // 构建上传URL，将user_id作为URL参数
      final uploadUrl = '${ApiConfig.uploadVideoUrl}?user_id=$userId';
      print('上传URL: $uploadUrl');
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(uploadUrl)
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
    print('完成任务');
    if (_isFinished) {
      print('任务已经完成，直接返回');
      return;
    }
    setState(() { _isFinished = true; });
    _timer?.cancel();
    _usedSeconds = widget.initialSeconds - _remainingSeconds;
    print('已使用时间: $_usedSeconds 秒');

    // 如果正在录制视频，先停止录制
    if (_isRecording && _cameraController != null) {
      print('正在停止视频录制...');
      try {
        final XFile video = await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _videoPath = video.path;
        });
        print('视频已保存到: $_videoPath');
      } catch (e) {
        print('停止录制时出错: $e');
      }
    }

    if (!widget.isTrainingTask) {
      print('这是普通任务，显示完成对话框');
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
                  print('用户选择不计入统计');
                  Navigator.of(context).pop();
                  _submitTaskToServerWithGivenUp(true);
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  print('用户选择计入统计');
                  Navigator.of(context).pop();
                  _submitTaskToServerWithGivenUp(false);
                },
              ),
            ],
          );
        },
      );
    } else {
      print('这是训练任务，直接处理视频');
      _handleTrainingTaskCompletion();
    }
  }

  Future<void> _submitTaskToServerWithGivenUp(bool givenUp) async {
    print('开始提交任务，givenUp: $givenUp');
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
        print('任务提交响应: $data');
        // 验证返回的数据是否完整
        if (data['task_id'] == widget.taskId && 
            data['is_finished'] == true) {
          // 保存time到SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('finished_time_task_${widget.taskId}', data['time']);
          
          // 检查视频上传条件
          print('检查视频上传条件:');
          print('givenUp: $givenUp');
          print('isTrainingTask: ${widget.isTrainingTask}');
          print('_videoPath: $_videoPath');
          
          // 如果用户选择计入专注时长，且不是训练任务，则上传视频
          if (!givenUp && !widget.isTrainingTask && _videoPath != null) {
            print('满足所有上传条件，开始上传视频');
            try {
              final userId = prefs.getInt('user_id');
              if (userId == null) {
                print('未找到用户ID');
                return;
              }
              print('准备上传视频，用户ID: $userId, 任务ID: ${widget.taskId}');

              final file = File(_videoPath!);
              if (!await file.exists()) {
                print('视频文件不存在: $_videoPath');
                return;
              }
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

              print('发送上传请求...');
              print('请求URL: ${request.url}');
              print('请求方法: ${request.method}');
              print('请求参数: user_id=$userId, task_id=${widget.taskId}');
              print('视频文件: ${file.path}');
              print('Content-Type: ${videoFile.contentType}');

              final streamedResponse = await request.send();
              print('收到响应，状态码: ${streamedResponse.statusCode}');
              print('响应头: ${streamedResponse.headers}');
              
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
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('视频上传成功！专注比例: ${responseData['focus_ratio']}')),
                    );
                  }
                } catch (e) {
                  print('解析响应数据时出错: $e');
                  print('原始响应内容: ${response.body}');
                }
              } else {
                print('视频上传失败，状态码: ${response.statusCode}');
                print('错误详情: ${response.body}');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('上传失败，请重试: ${response.body}')),
                  );
                }
              }
            } catch (e) {
              print('上传视频时出错: $e');
              print('错误堆栈: ${StackTrace.current}');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('上传出错：$e')),
                );
              }
            }
          } else {
            print('不满足视频上传条件:');
            if (givenUp) print('- 用户选择了不计入统计');
            if (widget.isTrainingTask) print('- 这是训练任务');
            if (_videoPath == null) print('- 没有视频文件');
          }
          
          if (mounted) {
            Navigator.of(context).pop(true); // 返回true表示需要刷新
          }
        } else {
          print('服务器返回数据不完整: $data');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid response from server')),
            );
          }
        }
      } else {
        print('任务提交失败，状态码: ${response.statusCode}');
        print('错误详情: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to complete task: ${response.body}')),
          );
        }
      }
    } catch (e) {
      print('提交任务时出错: $e');
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
