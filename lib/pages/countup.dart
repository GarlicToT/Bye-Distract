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
          backgroundColor: Color(0xFF788682),
          title: Text(
            'Complete Timer',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Do you want to count this session in statistics?',
            style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _submitTaskToServerWithGivenUp(true);
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
              ),
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
            
            // if the user chooses to count the focus time, upload the video (if there is one)
            if (!givenUp) {
              try {
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getInt('user_id');
                if (userId == null) {
                  print('User ID not found');
                  return;
                }
                print('Preparing to upload data, user ID: $userId, task ID: ${widget.taskId}');

                // if there is a video file, upload the video
                if (_videoPath != null) {
                  final file = File(_videoPath!);
                  if (await file.exists()) {
                    print('Video file exists, size: ${await file.length()} bytes');

                    // build the upload URL, with user_id and task_id as URL parameters
                    final uploadUrl = '${ApiConfig.uploadansVideoUrl}?user_id=$userId&task_id=${widget.taskId}';
                    print('Start uploading task video to: $uploadUrl');

                    // create a multipart request
                    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
                    
                    // add the video file
                    final videoFile = await http.MultipartFile.fromPath(
                      'video',  // make sure the field name here is consistent with the backend expectation
                      file.path,
                      contentType: MediaType('video', 'mp4'),
                    );
                    request.files.add(videoFile);

                    print('Sending upload request...\nRequest URL: ${request.url}\nRequest method: ${request.method}');
                    final streamedResponse = await request.send();
                    print('Received response, status code: ${streamedResponse.statusCode}');
                    
                    final response = await http.Response.fromStream(streamedResponse);
                    print('Complete response body: ${response.body}');
                    
                    if (response.statusCode == 200) {
                      print('Video uploaded successfully!');
                      try {
                        final responseData = jsonDecode(response.body);
                        print('Video uploaded backend return data:');
                        print('Status: ${responseData['status'] ?? 'Unknown'}');
                        print('Focus ratio: ${responseData['focus_ratio'] ?? 'Unknown'}');
                        print('Video URL: ${responseData['video_url'] ?? 'Unknown'}');
                      } catch (e) {
                        print('Error parsing response data: $e');
                      }
                    } else {
                      print('Video upload failed, status code: ${response.statusCode}');
                      print('Error details: ${response.body}');
                    }
                  } else {
                    print('Video file does not exist: $_videoPath');
                  }
                } else {
                  print('No video file, only upload task completion data');
                }
              } catch (e) {
                print('Error uploading data: $e');
                print('Error stack: ${StackTrace.current}');
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
            Container(
              width: 300,
              height: 300,
              color: Colors.white.withOpacity(0.7),
              child: _cameraController != null && _cameraController!.value.isInitialized
                  ? CameraPreview(_cameraController!)
                  : Center(child: Icon(Icons.camera_alt, size: 48, color: Colors.white)),
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
