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
      print('未找到用户ID');
      return;
    }

    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
    });

    try {
      print('正在获取用户 ${userId} 的头像...');
      final avatarResponse = await http.post(
        Uri.parse('${ApiConfig.getAvatarUrl}/?user_ids=${userId.toString()}'),
        headers: {
          'accept': 'application/json',
        },
      );
      print('头像请求状态码: ${avatarResponse.statusCode}');
      print('头像响应原始数据: ${avatarResponse.body}');
      print('获取头像响应内容: ${avatarResponse.body}');
      
      if (avatarResponse.statusCode == 200) {
        final responseData = json.decode(avatarResponse.body);
        print('解析后的响应数据: $responseData');
        print('响应状态: ${responseData['status']}');
        print('响应数据字段: ${responseData['data']}');
        
        if (responseData['status'] == 'success' && 
            responseData['data'] != null && 
            responseData['data'][userId.toString()] != null) {
          final avatarUrl = responseData['data'][userId.toString()];
          print('获取到的头像URL: $avatarUrl');
          
          setState(() {
            _avatarUrl = avatarUrl;
          });
        } else {
          print('用户没有头像或数据格式不正确');
          print('status: ${responseData['status']}');
          print('data: ${responseData['data']}');
          print('userId: $userId');
          setState(() {
            _avatarUrl = null;
          });
        }
      } else {
        print('获取头像失败: ${avatarResponse.statusCode}');
        print('错误响应内容: ${avatarResponse.body}');
        setState(() {
          _avatarUrl = null;
        });
      }
    } catch (e) {
      print('获取头像时出错: $e');
      print('错误堆栈: ${StackTrace.current}');
      setState(() {
        _avatarUrl = null;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      print('开始选择图片...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image == null) {
        print('用户取消了图片选择');
        return;
      }
      
      // 验证文件类型
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图片大小不能超过5MB')),
        );
        return;
      }

      print('已选择图片: ${image.path}');

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) {
        print('错误：未找到用户ID');
        return;
      }
      print('用户ID: $userId');

      print('开始创建multipart请求...');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.uploadAvatarUrl}?user_id=${userId.toString()}'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
      });

      print('正在添加图片文件到请求中...');
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: image.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      print('图片文件已添加到请求中');

      print('开始发送请求到服务器...');
      var response = await request.send();
      print('收到服务器响应，状态码: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        print('上传头像响应内容: $responseData');
        // 上传成功后重新加载用户信息
        await _loadUserInfo();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('头像上传成功')),
        );
      } else {
        print('上传失败，状态码: ${response.statusCode}');
        var errorData = await response.stream.bytesToString();
        print('错误响应数据: $errorData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上传失败，请重试')),
        );
      }
    } catch (e, stackTrace) {
      print('发生未预期的错误: $e');
      print('错误堆栈: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发生错误：$e')),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // 清除保存的用户信息
    await prefs.remove('user_name');
    await prefs.remove('user_id');
    
    // 返回登录页面
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false, // 清除所有路由历史
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
          color: Color(0xFFFFE6E6),
        ),
        SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.check_circle,
          title: 'Whitelist',
          color: Color(0xFFBFDDBE),
        ),
        SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.logout,
          title: 'Log out',
          color: Color(0xFFFFE0B2), // 使用暖色调，与现有配色方案相协调
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