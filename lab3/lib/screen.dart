import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// lab 4
import 'package:intl/intl.dart';
import 'package:lab3/notification_service.dart';
import 'package:geolocator/geolocator.dart';

class AddExamPage extends StatefulWidget {
  const AddExamPage({Key? key}) : super(key: key);

  @override
  _AddExamPageState createState() => _AddExamPageState();
}

class _AddExamPageState extends State<AddExamPage> {
  final TextEditingController nameController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  double? currentLatitude;
  double? currentLongitude;

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
      });
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        timeController.text = picked.format(context);
      });
    }
  }

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  int calculateSecondsDifference(String date, String time) {
    String dateTimeString = "$date $time";

    DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateTimeString);

    Duration difference = dateTime.difference(DateTime.now());

    int secondsDifference = difference.inSeconds;

    return secondsDifference;
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exam'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Exam Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDate != null
                      ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                      : 'Select Date',
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            InkWell(
              onTap: () => _selectTime(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : 'Select Time',
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _addExam(context, firestore, user),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addExam(
      BuildContext context, FirebaseFirestore firestore, User? user) async {
    final String name = nameController.text.trim();
    String date = dateController.text.trim();
    String time = timeController.text.trim();

    if (name.isNotEmpty &&
        date.isNotEmpty &&
        time.isNotEmpty &&
        user != null &&
        user.uid.isNotEmpty) {
      try {
        final String userUid = user.uid;

        await firestore.collection('exams').add({
          'user': userUid,
          'name': name,
          'date': date,
          'time': time,
          'latitude': currentLatitude,
          'longitude': currentLongitude
        });
        date = date.replaceAllMapped(
          RegExp(r'(\d+)-(\d+)-(\d+)'),
          (match) =>
              '${match[1]!.padLeft(2, '0')}-${match[2]!.padLeft(2, '0')}-${match[3]!.padLeft(2, '0')}',
        );

        time = time.replaceAllMapped(
          RegExp(r'(\d+):(\d+)\s+(AM|PM)'),
          (match) {
            int hour = int.parse(match[1]!);
            int minute = int.parse(match[2]!);
            String period = match[3]!;
            if (period == 'PM' && hour != 12) {
              hour += 12;
            } else if (period == 'AM' && hour == 12) {
              hour = 0;
            }
            return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
          },
        );

        int secondsDifference = calculateSecondsDifference(date, time);

        await NotificationService().scheduleNotification(
            "Exam $name happening now.", secondsDifference);

        Navigator.pop(context);
      } catch (e) {
        debugPrint('Exception $e');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add exam. Please try again.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all the fields.'),
        ),
      );
    }
  }
}
