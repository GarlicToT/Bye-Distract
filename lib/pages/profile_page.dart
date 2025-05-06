import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
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
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
          ),
          child: Icon(Icons.image, color: Colors.grey[400], size: 40),
        ),
        SizedBox(height: 16),
        Text('Tata', style: _profileNameStyle),
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
      ],
    ),
  );

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
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