import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

const TextStyle _titleStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
);
const TextStyle _subtitleStyle = TextStyle(
  fontSize: 14,
  color: Colors.black54,
);

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Map<String, dynamic>? _statisticsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      print('User ID not found');
      return;
    }

    // 构建请求 URL 并打印
    final requestUrl = Uri.parse('${ApiConfig.getStatisticsUrl}/$userId');
    print('🌐 Sending GET request to: $requestUrl');

    final response = await http.get(requestUrl);

    // 打印响应基本信息
    print('🔍 Response status: ${response.statusCode}');
    print('📦 Response body: ${response.body}');

    if (response.statusCode == 200) {
      // 解码并打印结构化数据
      final decodedData = jsonDecode(response.body);
      print('✅ Decoded response data: $decodedData');

      setState(() {
        _statisticsData = decodedData;
        _isLoading = false;
      });
    } else {
      // 打印错误详情
      print('❌ Failed to load statistics: ${response.statusCode}');
      print('❗ Error details: ${response.body}');
      setState(() {
        _isLoading = false;
      });
    }
  } catch (e) {
    // 打印异常信息
    print('⛔ Error fetching statistics: $e');
    setState(() {
      _isLoading = false;
    });
  }
}

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    }
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours h $minutes min';
    } else {
      return '$minutes min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final padding = screenSize.width * 0.04;
    final fontSize = isTablet ? 24.0 : 20.0;
    final subtitleFontSize = isTablet ? 16.0 : 14.0;

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
          IconButton(
            icon: Icon(Icons.emoji_events_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchStatistics,
              child: ListView(
                padding: EdgeInsets.all(padding),
                children: [
                  _buildTotalCard(fontSize, subtitleFontSize),
                  SizedBox(height: padding),
                  _buildTodayCard(fontSize, subtitleFontSize),
                  SizedBox(height: padding),
                  _buildDistributionCard(fontSize, subtitleFontSize),
                  SizedBox(height: padding),
                  _buildTimePeriodCard(fontSize, subtitleFontSize),
                ],
              ),
            ),
    );
  }

  Widget _buildTotalCard(double fontSize, double subtitleFontSize) {
    final total = _statisticsData?['total'] ?? {};
    return _buildStatsCard(
      title: 'Total',
      items: [
        _StatItem('frequency', '${total['total_frequency'] ?? 0}'),
        _StatItem('duration', _formatDuration(total['total_duration'] ?? 0)),
        _StatItem('Average daily\nduration', 
          _formatDuration((total['average_daily_duration']?.toInt() ?? 0))),
      ],
      fontSize: fontSize,
      subtitleFontSize: subtitleFontSize,
    );
  }

  Widget _buildTodayCard(double fontSize, double subtitleFontSize) {
    final today = _statisticsData?['today'] ?? {};
    return _buildStatsCard(
      title: 'Today',
      items: [
        _StatItem('frequency', '${today['frequency_day'] ?? 0}'),
        _StatItem('duration', _formatDuration(today['duration_day'] ?? 0)),
        _StatItem('give up', '${today['given_up_day'] ?? 0}'),
      ],
      fontSize: fontSize,
      subtitleFontSize: subtitleFontSize,
    );
  }

  Widget _buildDistributionCard(double fontSize, double subtitleFontSize) {
    final today = _statisticsData?['today'] ?? {};
    final taskBreakdown = today['task_breakdown'] ?? {};
    final durationDay = today['duration_day']?.toInt() ?? 0;

    List<PieChartSectionData> sections = [];
    final colors = [
      Color(0xFFFFD6D6),
      Color(0xFFBFDDBE),
      Color(0xFFAED3EA),
      Color(0xFFFFF3B0),
      Color(0xFFD8BFD8),
    ];

    int colorIndex = 0;
    taskBreakdown.forEach((taskName, percentage) {
      final seconds = (durationDay * (percentage as double) / 100).round();
      if (seconds > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[colorIndex % colors.length],
            value: seconds.toDouble(),
            title: '$taskName\n${_formatDuration(seconds)}',
            radius: 28,
            titleStyle: TextStyle(
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2
            ),
          ),
        );
        colorIndex++;
      }
    });

    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE6E6), Color(0xFFFF9E9E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distribution',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Text(
                    today['date']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Colors.black54,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: Colors.black54),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: Colors.black54),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: sections.isEmpty
                ? Center(child: Text('No tasks today', style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: Colors.black54)))
                : PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 0,
                      centerSpaceRadius: 0,
                      startDegreeOffset: -90,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required List<_StatItem> items,
    required double fontSize,
    required double subtitleFontSize,
  }) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE6E6), Color(0xFFFF9E9E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          )),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) => _buildStatItem(
              item.label, 
              item.value, 
              subtitleFontSize
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, double fontSize) {
    return Column(
      children: [
        Text(label, 
          style: TextStyle(fontSize: fontSize, color: Colors.black54),
        ),
        SizedBox(height: 4),
        Text(value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize * 1.2,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          )),
      ],
    );
  }

  Widget _buildTimePeriodCard(double fontSize, double subtitleFontSize) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE6E6), Color(0xFFFF9E9E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time period distribution',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Text(
                    '2025-04-03',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Colors.black54,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: Colors.black54),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: Colors.black54),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Center(
              child: Text(
                '时间段分布图表将在这里显示',
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: Colors.black54
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;

  _StatItem(this.label, this.value);
}