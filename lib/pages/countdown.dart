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
    _remainingSeconds = widget.initialSeconds;
    _selectRandomBackground(); // Select a random background
    // Only the training task automatically starts timing and initializing the camera
    if (widget.isTrainingTask) {
      _startTimer();
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
      // Only the training task automatically starts recording
      if (widget.isTrainingTask) {
        _startRecording();
      }
    }
  }

  Future<void> _startRecording() async {
    print('Start recording video');
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final directory = await getTemporaryDirectory();
        _videoPath = '${directory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
        print('Video will be saved to: $_videoPath');
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
        print('Start recording video successfully');
      } catch (e) {
        print('Error starting recording: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error starting recording: $e')),
          );
        }
      }
    } else {
      print('Camera not initialized, cannot start recording');
    }
  }

  Future<void> _showCameraDialog() async {
    print('Show camera dialog');
    
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
                print('User chose not to open the camera');
                Navigator.of(context).pop();
                // If it is not a training task and the user chooses not to open the camera, start timing
                if (!widget.isTrainingTask) {
                  _startTimer();
                }
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                print('User chose to open the camera');
                Navigator.of(context).pop();
                // If it is not a training task and the user chooses to open the camera, initialize the camera and start timing and recording
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
    print('Stop recording video');
    if (_isRecording && _cameraController != null) {
      try {
        final XFile video = await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _videoPath = video.path;
        });
        print('Video saved to: $_videoPath');
        
        if (widget.isTrainingTask) {
          print('This is a training task, prepare to upload video');
          await _uploadTrainingVideo();
        }
      } catch (e) {
        print('Error stopping recording: $e');
      }
    } else {
      print('No recording video or camera not initialized');
    }
  }

  Future<void> _uploadTrainingVideo() async {
    try {
      print('Start uploading video');
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) {
        print('User ID not found');
        return;
      }

      if (_videoPath == null) {
        print('No video file to upload');
        return;
      }

      print('Video file path: $_videoPath');
      final file = File(_videoPath!);
      if (!await file.exists()) {
        print('Video file does not exist');
        return;
      }

      print('Create upload request');
      final uploadUrl = '${ApiConfig.uploadVideoUrl}?user_id=$userId';
      print('Upload URL: $uploadUrl');
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(uploadUrl)
      );

      // Add video file
      final videoFile = await http.MultipartFile.fromPath(
        'video',
        file.path,
        contentType: MediaType('video', 'mp4'),
      );
      request.files.add(videoFile);

      print('Send upload request');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('Upload response status code: ${response.statusCode}');
      print('Upload response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Upload successful');
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Training completed'),
                content: Text('You have completed the focus model training!'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
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
        print('Upload failed, status code: ${response.statusCode}');
        print('Error details: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed, please try again: ${response.body}')),
          );
        }
      }
    } catch (e) {
      print('Error uploading video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading video: $e')),
        );
      }
    }
  }

  void _startTimer() {
    print('Start the countdown');
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        print('Remaining time: $_remainingSeconds seconds');
      } else {
        print('Countdown finished');
        timer.cancel();
        if (widget.isTrainingTask) {
          print('This is a training task, prepare to handle video');
          _handleTrainingTaskCompletion();
        } else {
          _finishTask();
        }
      }
    });
  }

  Future<void> _handleTrainingTaskCompletion() async {
    print('Start handling training task completion');
    if (_isRecording && _cameraController != null) {
      try {
        print('Stopping recording...');
        // 停止录制
        final XFile video = await _cameraController!.stopVideoRecording();
        print('Recording stopped, video saved to: ${video.path}');
        
        setState(() {
          _isRecording = false;
          _videoPath = video.path;
        });

        print('Closing camera...');
        // close camera
        await _cameraController!.dispose();
        _cameraController = null;
        print('Camera closed');

        print('Preparing to upload video...');
        // upload video
        await _uploadTrainingVideo();
      } catch (e) {
        print('Error handling training task: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error handling video: $e')),
          );
        }
      }
    } else {
      print('Camera status: ${_cameraController != null ? "Initialized" : "Not initialized"}');
      print('Recording status: ${_isRecording ? "Recording" : "Not recording"}');
    }
  }

  Future<void> _finishTask() async {
    print('Task completed');
    if (_isFinished) {
      print('Task already completed, returning directly');
      return;
    }
    setState(() { _isFinished = true; });
    _timer?.cancel();
    _usedSeconds = widget.initialSeconds - _remainingSeconds;
    print('Time used: $_usedSeconds seconds');

    // If you are recording a video, stop recording first
    if (_isRecording && _cameraController != null) {
      print('Stopping video recording...');
      try {
        final XFile video = await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _videoPath = video.path;
        });
        print('Video saved to: $_videoPath');
      } catch (e) {
        print('Error stopping recording: $e');
      }
    }

    if (!widget.isTrainingTask) {
      print('This is a normal task, showing completion dialog');
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
                  print('User chose not to count in statistics');
                  Navigator.of(context).pop();
                  _submitTaskToServerWithGivenUp(true);
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  print('User chose to count in statistics');
                  Navigator.of(context).pop();
                  _submitTaskToServerWithGivenUp(false);
                },
              ),
            ],
          );
        },
      );
    } else {
      print('This is a training task, directly handle video');
      _handleTrainingTaskCompletion();
    }
  }

  Future<void> _submitTaskToServerWithGivenUp(bool givenUp) async {
    print('Start submitting task, givenUp: $givenUp');
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
        print('Task submission response: $data');
        // Verify that the returned data is complete
        if (data['task_id'] == widget.taskId && 
            data['is_finished'] == true) {
          // Save time to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('finished_time_task_${widget.taskId}', data['time']);
          
          // Check video upload conditions
          print('Checking video upload conditions:');
          print('givenUp: $givenUp');
          print('isTrainingTask: ${widget.isTrainingTask}');
          print('_videoPath: $_videoPath');
          
          // If the user chooses to count in statistics, and it is not a training task, upload the video
          if (!givenUp && !widget.isTrainingTask && _videoPath != null) {
            print('All conditions met, starting video upload');
            try {
              final userId = prefs.getInt('user_id');
              if (userId == null) {
                print('User ID not found');
                return;
              }
              print('Preparing to upload video, user ID: $userId, task ID: ${widget.taskId}');

              final file = File(_videoPath!);
              if (!await file.exists()) {
                print('Video file does not exist: $_videoPath');
                return;
              }
              print('Video file exists, size: ${await file.length()} bytes');

              // Build upload URL, with user_id and task_id as URL parameters
              final uploadUrl = '${ApiConfig.uploadansVideoUrl}?user_id=$userId&task_id=${widget.taskId}';
              print('Starting to upload task video to: $uploadUrl');

              // Create multipart request
              final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
              
              // Add video file
              final videoFile = await http.MultipartFile.fromPath(
                'video',  // Ensure the field name here is consistent with the backend expectation
                file.path,
                contentType: MediaType('video', 'mp4'),
              );
              request.files.add(videoFile);

              print('Sending upload request...');
              print('Request URL: ${request.url}');
              print('Request method: ${request.method}');
              print('Request parameters: user_id=$userId, task_id=${widget.taskId}');
              print('Video file: ${file.path}');
              print('Content-Type: ${videoFile.contentType}');

              final streamedResponse = await request.send();
              print('Received response, status code: ${streamedResponse.statusCode}');
              print('Response headers: ${streamedResponse.headers}');
              
              final response = await http.Response.fromStream(streamedResponse);
              print('Complete response body: ${response.body}');
              
              if (response.statusCode == 200) {
                print('Video upload successful!');
                try {
                  final responseData = jsonDecode(response.body);
                  print('Video upload backend return data:');
                  print('Status: ${responseData['status'] ?? 'Unknown'}');
                  print('Focus ratio: ${responseData['focus_ratio'] ?? 'Unknown'}');
                  print('Video URL: ${responseData['video_url'] ?? 'Unknown'}');
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Video upload successful! Focus ratio: ${responseData['focus_ratio']}')),
                    );
                  }
                } catch (e) {
                  print('Error parsing response data: $e');
                  print('Original response content: ${response.body}');
                }
              } else {
                print('Video upload failed, status code: ${response.statusCode}');
                print('Error details: ${response.body}');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Upload failed, please try again: ${response.body}')),
                  );
                }
              }
            } catch (e) {
              print('Error uploading video: $e');
              print('Error stack trace: ${StackTrace.current}');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Upload error: $e')),
                );
              }
            }
          } else {
            print('Conditions not met:');
            if (givenUp) print('- User chose not to count in statistics');
            if (widget.isTrainingTask) print('- This is a training task');
            if (_videoPath == null) print('- No video file');
          }
          
          if (mounted) {
            Navigator.of(context).pop(true); // Return true to refresh
          }
        } else {
          print('Server returned incomplete data: $data');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid response from server')),
            );
          }
        }
      } else {
        print('Task submission failed, status code: ${response.statusCode}');
        print('Error details: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to complete task: ${response.body}')),
          );
        }
      }
    } catch (e) {
      print('Error submitting task: $e');
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
              _formatTime(_remainingSeconds),
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
    print('Component destroyed, cleaning resources');
    _timer?.cancel();
    if (_cameraController != null) {
      print('Cleaning camera resources');
      _cameraController!.dispose();
      _cameraController = null;
    }
    super.dispose();
  }
}
