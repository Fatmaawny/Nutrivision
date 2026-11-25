import 'package:flutter/material.dart';

class CustomLinearProgressIndicator extends StatelessWidget{
  String progressTitle;
  String progressValue;
  Color progressColor;
  double indicatorValue;
  CustomLinearProgressIndicator({
    required this.progressTitle,
    required this.progressValue,
    required this.progressColor,
    required this.indicatorValue

  });
  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              progressTitle,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff5B6B60)
              ),
            ),
            Text(
              progressValue,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff5B6B60)
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        LinearProgressIndicator(
          value: indicatorValue,
          backgroundColor: Color(0xFFF3EFEA),
          valueColor:  AlwaysStoppedAnimation(
            progressColor,
          ),
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}