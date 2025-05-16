import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
      body: ListView(
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
    );
  }

  Widget _buildTotalCard(double fontSize, double subtitleFontSize) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.04;

    return Container(
      padding: EdgeInsets.all(padding),
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
          Text(
            'Total',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: padding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTotalItem('frequency', '25', subtitleFontSize),
              _buildTotalItem('duration', '11 h 37 min', subtitleFontSize),
              _buildTotalItem('Average daily\nduration', '1 h 17 min', subtitleFontSize),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(double fontSize, double subtitleFontSize) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.04;

    return Container(
      padding: EdgeInsets.all(padding),
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
          Text(
            'Today',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: padding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTotalItem('frequency', '3', subtitleFontSize),
              _buildTotalItem('duration', '150 min', subtitleFontSize),
              _buildTotalItem('give up', '0', subtitleFontSize),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCard(double fontSize, double subtitleFontSize) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.04;
    final chartHeight = screenSize.height * 0.3;

    return Container(
      padding: EdgeInsets.all(padding),
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
          SizedBox(height: padding),
          SizedBox(
            height: chartHeight,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Color(0xFFFFD6D6),
                    value: 70,
                    title: 'READING\n70 min',
                    radius: chartHeight * 0.4,
                    titleStyle: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  PieChartSectionData(
                    color: Color(0xFFBFDDBE),
                    value: 50,
                    title: 'LISTENING\n50 min',
                    radius: chartHeight * 0.4,
                    titleStyle: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  PieChartSectionData(
                    color: Color(0xFFAED3EA),
                    value: 30,
                    title: 'WORDS\n30 min',
                    radius: chartHeight * 0.4,
                    titleStyle: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
                sectionsSpace: 0,
                centerSpaceRadius: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodCard(double fontSize, double subtitleFontSize) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.04;
    final chartHeight = screenSize.height * 0.3;

    return Container(
      padding: EdgeInsets.all(padding),
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
          SizedBox(height: padding),
          SizedBox(
            height: chartHeight,
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

  Widget _buildTotalItem(String label, String value, double subtitleFontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: subtitleFontSize,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: subtitleFontSize * 1.2,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFE6E6), Color(0xFFFF9E9E)],
      ),
      borderRadius: BorderRadius.circular(20),
    );
  }
}