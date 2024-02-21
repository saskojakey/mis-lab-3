import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab3/card.dart';

class ExamPage extends StatelessWidget {
  final User? authenticatedUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return authenticatedUser == null ? _buildLoginPrompt() : _buildExamStream();
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock,
            color: Colors.blue,
            size: 48.0,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Please log in to view your exams.',
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  Widget _buildExamStream() {
    return StreamBuilder(
      stream: _getUserExams(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'An error occurred: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoExamsFoundMessage();
        }

        return _buildExamList(snapshot);
      },
    );
  }

  Stream<QuerySnapshot> _getUserExams() {
    return FirebaseFirestore.instance
        .collection('exams')
        .where('user', isEqualTo: authenticatedUser!.uid)
        .snapshots();
  }

  Widget _buildNoExamsFoundMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.warning,
            color: Colors.red,
            size: 48.0,
          ),
          const SizedBox(height: 16.0),
          Text(
            'No exams found for the current user.',
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  Widget _buildExamList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: snapshot.data!.docs.map((doc) {
        var examData = doc.data() as Map<String, dynamic>;
        return ExamWidget(
          subject: examData['name'],
          date: examData['date'],
          time: examData['time'],
          latitude: examData['latitude'],
          longitude: examData['longitude'],
        );
      }).toList(),
    );
  }
}
