import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
    "2",
    "name",
    channelDescription: "Desc",
  );

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> showNotification(String content) async {
    await flutterLocalNotificationsPlugin.show(
      1,
      "MIS2023/24",
      content,
      NotificationDetails(android: androidPlatformChannelSpecifics),
      payload: 'data',
    );
  }

  Future<void> scheduleNotification(String content, int inSeconds) async {
    if (await Permission.ignoreBatteryOptimizations.request().isGranted) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          1,
          "MIS2023/24",
          content,
          tz.TZDateTime.now(tz.local).add(Duration(seconds: inSeconds)),
          NotificationDetails(android: androidPlatformChannelSpecifics),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    } else {
      var status = await Permission.ignoreBatteryOptimizations.request();

      if (status.isGranted) {
        print('Permission granted');
      } else {
        print('Permission not granted');
      }
    }
  }

  Future<void> selectNotification(String? payload) async {
    // Handle notification tapped logic here
  }

  Future<void> onDidReceiveLocalNotification(
      int x, String? y, String? z, String? t) async {}

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('finki');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: null,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: selectNotification,
    );

    tz.initializeTimeZones();
  }
}
