import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mealio/views/weekly_progress/widgets/custom_linear_progress_indicator.dart';
import 'package:mealio/views/weekly_progress/widgets/progress_card.dart';

import '../../data/services/weekly_progress_service.dart';

class WeeklyProgress extends StatelessWidget{
  List<String> days = ['S','M','T','W','T','F','S'];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
        backgroundColor: Color(0xFFF3EFEA),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 38),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Progress',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1B2B21)
                    ),
                  ),
                  SizedBox(height: 16,),
                  StreamBuilder<Map<String,dynamic>>(
                      stream: WeeklyProgressService().getWeeklyProgress(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        }
                        final progressData= snapshot.data;
                      return Column(
                        children: [
                          ProgressCard(
                            widget: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Calories (avg ${progressData?['caloriesAverage']} kcal)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff5B6B60)
                                  ),
                                ),
                                SizedBox(height: 17,),
                                SizedBox(
                                  height: 260,
                                  child: BarChart(
                                    BarChartData(
                                      maxY: 2700,
                                      alignment: BarChartAlignment.spaceAround,
                                      gridData: const FlGridData(show: false),
                                      borderData: FlBorderData(show: false),
                                      barTouchData: BarTouchData(
                                        enabled: false,
                                      ),
                                      titlesData: FlTitlesData(
                                        leftTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 35,
                                            getTitlesWidget: (value, meta) {
                                              int index = value.toInt();
                                              if (index < 0 || index >= days.length) {
                                                return const SizedBox();
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 10),
                                                child: Text(
                                                  days[index],
                                                  style: const TextStyle(
                                                    color: Color(0xff5B6B60),
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      barGroups: List.generate(
                                        progressData?['caloriesProgress']!.length,
                                            (index) {
                                          return BarChartGroupData(
                                            x: index,
                                            barRods: [
                                              BarChartRodData(
                                                toY: progressData?['caloriesProgress'][index],
                                                width: 35,
                                                color: const Color(0xff2E7D4F),
                                                borderRadius: const BorderRadius.vertical(
                                                  top: Radius.circular(12),
                                                  bottom: Radius.circular(12),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          ProgressCard(
                            widget: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Macros this week',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff1B2B21)
                                  ),
                                ),
                                SizedBox(height: 17,),
                                CustomLinearProgressIndicator(
                                    progressTitle: 'Protein',
                                    progressValue: '${progressData?['totalProtein']} g',
                                    progressColor: Color(0xff5B6FD6),
                                    indicatorValue: progressData?['weeklyProteinPercentage']
                                ),
                                CustomLinearProgressIndicator(
                                    progressTitle: 'Carbs',
                                    progressValue: '${progressData?['totalCarbs']} g',
                                    progressColor: Color(0xffE0A100),
                                    indicatorValue: progressData?['weeklyCarbsPercentage']
                                ),
                                CustomLinearProgressIndicator(
                                    progressTitle: 'Fat',
                                    progressValue: '${progressData?['totalFats']} g',
                                    progressColor: Color(0xffE0583E),
                                    indicatorValue: progressData?['weeklyFatPercentage']
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                  StreamBuilder<Map<String,dynamic>>(
                    stream: WeeklyProgressService().getWaterGoalProgress(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }
                      final waterProgress= snapshot.data;

                      return ProgressCard(
                        widget: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Water goal',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff1B2B21)
                                  ),
                                ),
                                SizedBox(height: 17,),
                                Text(
                                  '${waterProgress?['achievedDays']} of 7 days reached',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff5B6B60)
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${waterProgress?['percentage']}%',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff2E7D4F)
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  ),
                ],
              ),
          ),
        ),
    ));
  }
}