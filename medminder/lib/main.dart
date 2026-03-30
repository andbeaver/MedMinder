import 'dart:async';
import 'package:medminder/screens/home_screen.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:medminder/services/notification_service.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final notificationService = NotificationService();
    await notificationService.initNotification();
    await notificationService.scheduleAllNotifications();
  } catch (e) {
    // Log but don't crash; continue app startup even if notifications fail
    print('Error initializing notifications: $e');
  }
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedMinder',
      debugShowCheckedModeBanner: false,
      home: HomePage()
    );
  }
}
