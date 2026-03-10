import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomLineChart  extends StatelessWidget{
  const CustomLineChart ({super.key});
  @override
  Widget build (BuildContext context) {
    return Card(
      child: LineChart(LineChartData(
        lineBarsData: [ _buildLineChartBarData ()],
      ) ),
    );
   
  }
  LineChartBarData  _buildLineChartBarData (){
    return LineChartBarData();
  }
}
