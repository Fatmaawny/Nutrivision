import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget{
  Widget? widget;
  ProgressCard({
   this.widget
});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16,vertical: 17),
        decoration: BoxDecoration(
            color: Color(0xffFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: 1,
              color: Color(0xFFE5DDD3),
            )
        ),
        child: widget,
      ),
    );
  }
}