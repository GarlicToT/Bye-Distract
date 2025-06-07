import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'dart:convert';
import 'login_page.dart';
import '../config/api_config.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = '';
  String? _avatarUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      print('User ID not found');
      return;
    }

    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
    });

    try {
      print('Getting avatar for user ${userId}...');
      final avatarResponse = await http.post(
        Uri.parse('${ApiConfig.getAvatarUrl}/?user_ids=${userId.toString()}'),
        headers: {
          'accept': 'application/json',
        },
      );
      print('Avatar request status code: ${avatarResponse.statusCode}');
      print('Avatar response raw data: ${avatarResponse.body}');
      print('Get avatar response content: ${avatarResponse.body}');
      
      if (avatarResponse.statusCode == 200) {
        final responseData = json.decode(avatarResponse.body);
        print('Parsed response data: $responseData');
        print('Response status: ${responseData['status']}');
        print('Response data field: ${responseData['data']}');
        
        if (responseData['status'] == 'success' && 
            responseData['data'] != null && 
            responseData['data'][userId.toString()] != null) {
          final avatarUrl = responseData['data'][userId.toString()];
          print('Retrieved avatar URL: $avatarUrl');
          
          setState(() {
            _avatarUrl = avatarUrl;
          });
        } else {
          print('User has no avatar or data format is incorrect');
          print('status: ${responseData['status']}');
          print('data: ${responseData['data']}');
          print('userId: $userId');
          setState(() {
            _avatarUrl = null;
          });
        }
      } else {
        print('Failed to get avatar: ${avatarResponse.statusCode}');
        print('Error response content: ${avatarResponse.body}');
        setState(() {
          _avatarUrl = null;
        });
      }
    } catch (e) {
      print('Error getting avatar: $e');
      print('Error stack trace: ${StackTrace.current}');
      setState(() {
        _avatarUrl = null;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      print('Starting image selection...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image == null) {
        print('User cancelled image selection');
        return;
      }
      
      // Validate file type
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image size cannot exceed 5MB')),
        );
        return;
      }

      print('Selected image: ${image.path}');

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) {
        print('Error: User ID not found');
        return;
      }
      print('User ID: $userId');

      print('Creating multipart request...');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.uploadAvatarUrl}?user_id=${userId.toString()}'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
      });

      print('Adding image file to request...');
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: image.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      print('Image file added to request');

      print('Sending request to server...');
      var response = await request.send();
      print('Received server response, status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        print('Upload avatar response content: $responseData');
        // Reload user info after successful upload
        await _loadUserInfo();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Avatar uploaded successfully')),
        );
      } else {
        print('Upload failed, status code: ${response.statusCode}');
        var errorData = await response.stream.bytesToString();
        print('Error response data: $errorData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed, please try again')),
        );
      }
    } catch (e, stackTrace) {
      print('Unexpected error occurred: $e');
      print('Error stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear saved user information
    await prefs.remove('user_name');
    await prefs.remove('user_id');
    
    // Return to login page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false, // Clear all route history
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          _buildProfileHeader(),
          SizedBox(height: 40),
          _buildProfileOptions(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() => Center(
    child: Column(
      children: [
        GestureDetector(
          onTap: _pickAndUploadImage,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: _avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      _avatarUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image, color: Colors.grey[400], size: 40);
                      },
                    ),
                  )
                : Icon(Icons.image, color: Colors.grey[400], size: 40),
          ),
        ),
        SizedBox(height: 16),
        Text(_userName, style: _profileNameStyle),
      ],
    ),
  );

  Widget _buildProfileOptions() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        _buildOptionCard(
          icon: Icons.person,
          title: 'Profile',
          color: Color(0xFFE6E6FA),
        ),
        SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.check_circle,
          title: 'Whitelist',
          color: Color(0xFFFFD6D6),
        ),
        SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.logout,
          title: 'Log out',
          color: Color(0xFF9CCCf0),
          onTap: _logout,
        ),
      ],
    ),
  );

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 24),
            SizedBox(width: 12),
            Text(title, style: _optionTitleStyle),
          ],
        ),
      ),
    );
  }

  final TextStyle _profileNameStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  final TextStyle _optionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
}