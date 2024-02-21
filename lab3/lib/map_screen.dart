import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchExamLocations();
  }

  Future<void> _fetchExamLocations() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot<Map<String, dynamic>> exams =
          await getUserExams(firestore, user);
      addMarkers(exams);
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  void addMarkers(QuerySnapshot<Map<String, dynamic>> exams) {
    for (QueryDocumentSnapshot<Map<String, dynamic>> exam in exams.docs) {
      final double? latitude = exam['latitude'];
      final double? longitude = exam['longitude'];

      if (latitude != null && longitude != null) {
        _addMarker(exam.id, latitude, longitude, exam['name'], exam['date'],
            exam['time']);
      }
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserExams(
      FirebaseFirestore firestore, User? user) async {
    QuerySnapshot<Map<String, dynamic>> exams = await firestore
        .collection('exams')
        .where('user', isEqualTo: user!.uid)
        .get();
    return exams;
  }

  void _addMarker(String markerId, double latitude, double longitude,
      String name, String date, String time) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: LatLng(latitude, longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: name,
            snippet: '$date in $time',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Locations'),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 2,
        ),
        markers: _markers,
      ),
    );
  }
}
