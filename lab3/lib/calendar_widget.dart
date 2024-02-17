import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final User? user = FirebaseAuth.instance.currentUser;
    _events = await _getEventsFromFirestore(user);
    setState(() {});
  }

  Future<Map<DateTime, List<String>>> _getEventsFromFirestore(
      User? user) async {
    Map<DateTime, List<String>> events = {};
    final QuerySnapshot<Map<String, dynamic>> exams = await FirebaseFirestore
        .instance
        .collection('exams')
        .where('user', isEqualTo: user!.uid)
        .get();

    for (final exam in exams.docs) {
      final DateTime date = _getDateFromExam(exam);
      final String eventName = exam['name'];

      if (events[date] == null) {
        events[date] = [eventName];
      } else {
        events[date]!.add(eventName);
      }
    }

    return events;
  }

  DateTime _getDateFromExam(QueryDocumentSnapshot<Map<String, dynamic>> exam) {
    return DateTime.parse(
      exam['date'].replaceAllMapped(
        RegExp(r'(\d+)-(\d+)-(\d+)'),
        (match) =>
            '${match[1].padLeft(2, '0')}-${match[2].padLeft(2, '0')}-${match[3].padLeft(2, '0')}',
      ),
    );
  }

  List<String> _getEventsForDay(DateTime day) {
    final formattedDay = DateTime(day.year, day.month, day.day);
    final eventsForDay = _events[formattedDay] ?? [];

    return eventsForDay;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTableCalendar(),
        const SizedBox(height: 20),
        if (_selectedDay != null) _buildEventList(),
      ],
    );
  }

  TableCalendar _buildTableCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2022, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onDaySelected: (selectedDay, focusedDay) async {
        await _fetchEvents();
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      eventLoader: (day) => _getEventsForDay(day),
    );
  }

  Column _buildEventList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exams: ${_selectedDay!.day}.${_selectedDay!.month}.${_selectedDay!.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 10),
        ..._getEventsForDay(_selectedDay!).map(
          (event) => ListTile(
            title: Text(
              event,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color.fromARGB(255, 36, 6, 207),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
