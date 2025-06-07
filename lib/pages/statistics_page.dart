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
    final fontSize = isTablet ? 20.0 : 16.0;
    final subtitleFontSize = isTablet ? 14.0 : 12.0;

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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            opacity: 1.0,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchStatistics,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.5),
                  child: Column(
                    children: [
                      _buildTotalCard(fontSize, subtitleFontSize),
                      SizedBox(height: padding),
                      _buildTodayCard(fontSize, subtitleFontSize),
                      SizedBox(height: padding),
                      _buildDistributionCard(fontSize, subtitleFontSize),
                      SizedBox(height: padding),
                      _buildTimePeriodCard(fontSize, subtitleFontSize),
                      SizedBox(height: padding),
                    ],
                  ),
                ),
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
      Color(0xFF166DA6),
      Color(0xFF58C0DB),
      Color(0xFFB5D5DA),
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
            radius: 110,
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withOpacity(0.0), Color(0xA06CC6DF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
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
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
              minHeight: 200,
            ),
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withOpacity(0.0), Color(0xA06CC6DF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
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
    final tasks = _statisticsData?['tasks'] as List<dynamic>? ?? [];
    
    // 对任务按focus_ratio排序并只取前5个
    final sortedTasks = List<Map<String, dynamic>>.from(tasks)
      ..sort((a, b) => (b['focus_ratio'] as num).compareTo(a['focus_ratio'] as num));
    final topTasks = sortedTasks.take(5).toList();
    
    // 准备柱状图数据
    final barGroups = topTasks.asMap().entries.map((entry) {
      final task = entry.value;
      final focusRatio = (task['focus_ratio'] as num?)?.toDouble() ?? 0.0;
      
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: focusRatio,
            color: Color(0xFF58C0DB),
            width: 20,
            borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();

    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withOpacity(0.0), Color(0xA06CC6DF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Task focus ratio (Today Top 5)',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
              minHeight: 200,
            ),
            child: tasks.isEmpty
                ? Center(
                    child: Text(
                      'No task data',
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 1,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.black87,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final task = topTasks[group.x.toInt()];
                            return BarTooltipItem(
                              '${task['title']}\nfocus ratio: ${(rod.toY * 100).toStringAsFixed(1)}%',
                              TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value >= 0 && value < topTasks.length) {
                                final task = topTasks[value.toInt()];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    task['title'],
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }
                              return Text('');
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value * 100).toInt()}%',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              );
                            },
                            reservedSize: 40,
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 0.2,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.black12,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      barGroups: barGroups,
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