import 'package:flutter/material.dart';

class ExamWidget extends StatelessWidget {
  final String subject;
  final String date;
  final String time;

  const ExamWidget({
    Key? key,
    required this.subject,
    required this.date,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Date: $date',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Time: $time',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 18.0,
            ),
          ),
        ],
      ),
    );
  }
}
