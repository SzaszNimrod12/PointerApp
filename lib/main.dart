import 'dart:io';
import 'package:flutter/material.dart';
import 'PointerController.dart';

void main() async => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const title = 'Pointer App';
    return MaterialApp(
      title: title,
      theme: ThemeData(
        brightness: Brightness.dark),
      initialRoute: '/',
      routes: {
        '/': (context) => PointerController(title: title),
      },
    );
  }
}

