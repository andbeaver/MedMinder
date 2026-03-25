import 'dart:async';
import 'package:medminder/screens/home_screen.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

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
