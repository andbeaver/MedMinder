import 'package:medminder/screens/home_screen.dart';
import 'package:medminder/theme/app_styles.dart';

import 'package:medminder/services/notification_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final notificationService = NotificationService();
    await notificationService.initNotification();
    await notificationService.scheduleAllNotifications();
  } catch (e) {
    // Log but don't crash; continue app startup even if notifications fail
    if (kDebugMode) {
      debugPrint('Error initializing notifications: $e');
    }
  }
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'Roboto', 
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),


      ),
      title: 'MedMinder',
      debugShowCheckedModeBanner: false,
      home: HomePage()
    );
  }
}
