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

class StatisticsPage extends StatelessWidget {
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
        padding: EdgeInsets.all(16),
        children: [
          _buildTotalCard(),
          SizedBox(height: 16),
          _buildTodayCard(),
          SizedBox(height: 16),
          _buildDistributionCard(),
          SizedBox(height: 16),
          _buildTimePeriodCard(),
        ],
      ),
    );
  }












  // Widget _buildTotalCard() => Container(
  //   padding: EdgeInsets.all(16),
  //   decoration: _cardDecoration(),
  //   child: Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Total', style: _titleStyle),
  //       SizedBox(height: 16),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           _buildTotalItem('frequency', '25'),
  //           _buildTotalItem('duration', '11 h 37 min'),
  //           _buildTotalItem('Average daily\nduration', '1 h 17 min'),
  //         ],
  //       ),
  //     ],
  //   ),
  // );

  Widget _buildTotalCard() {
    return Container(
      padding: EdgeInsets.all(16),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTotalItem('frequency', '25'),
              _buildTotalItem('duration', '11 h 37 min'),
              _buildTotalItem('Average daily\nduration', '1 h 17 min'),
            ],
          ),
        ],
      ),
    );
  }


  // Widget _buildTodayCard() => Container(
  //   padding: EdgeInsets.all(16),
  //   decoration: _cardDecoration(),
  //   child: Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Today', style: _titleStyle),
  //       SizedBox(height: 16),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           _buildTotalItem('frequency', '3'),
  //           _buildTotalItem('duration', '150 min'),
  //           _buildTotalItem('give up', '0'),
  //         ],
  //       ),
  //     ],
  //   ),
  // );
   Widget _buildTodayCard() {
    return Container(
      padding: EdgeInsets.all(16),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTotalItem('frequency', '3'),
              _buildTotalItem('duration', '150 min'),
              _buildTotalItem('give up', '0'),
            ],
          ),
        ],
      ),
    );
  }


  // Widget _buildDistributionCard() => Container(
  //   padding: EdgeInsets.all(16),
  //   decoration: _cardDecoration(),
  //   child: Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text('Distribution', style: _titleStyle),
  //           Row(
  //             children: [
  //               Text('2025-04-03', style: _subtitleStyle),
  //               Row(
  //                 children: [
  //                   IconButton(
  //                     icon: Icon(Icons.chevron_left, color: Colors.black54),
  //                     onPressed: () {},
  //                   ),
  //                   IconButton(
  //                     icon: Icon(Icons.chevron_right, color: Colors.black54),
  //                     onPressed: () {},
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //       SizedBox(height: 16),
  //       SizedBox(
  //         height: 200,
  //         child: PieChart(
  //           PieChartData(
  //             sections: [
  //               PieChartSectionData(
  //                 color: Color(0xFFFFD6D6),
  //                 value: 70,
  //                 title: 'READING\n70 min',
  //                 radius: 80,
  //                 titleStyle: TextStyle(
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //               // 其他饼图区块...
  //             ],
  //             sectionsSpace: 0,
  //             centerSpaceRadius: 0,
  //           ),
  //         ),
  //       ),
  //     ],
  //   ),
  // );
   Widget _buildDistributionCard() {
    return Container(
      padding: EdgeInsets.all(16),
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Text(
                    '2025-04-03',
                    style: TextStyle(
                      fontSize: 14,
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
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Color(0xFFFFD6D6),
                    value: 70,
                    title: 'READING\n70 min',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  PieChartSectionData(
                    color: Color(0xFFBFDDBE),
                    value: 50,
                    title: 'LISTENING\n50 min',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  PieChartSectionData(
                    color: Color(0xFFAED3EA),
                    value: 30,
                    title: 'WORDS\n30 min',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 12,
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

   
   
  //  是D生成的这个文件的初始版本的基础上改红色报错
   Widget _buildTotalItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
   




  Widget _buildTimePeriodCard() {
    return Container(
      padding: EdgeInsets.all(16),
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Text(
                    '2025-04-03',
                    style: TextStyle(
                      fontSize: 14,
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
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Center(
              child: Text(
                '时间段分布图表将在这里显示',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
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

//下面是在D生成的这个文件的初始版本的基础上改红色报错

  // 其他辅助方法和样式定义...
  // 保持与原始代码相同的实现
}