import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'PointerController.dart';
import 'QRCodeScan.dart';
import 'HomeScreen.dart';

String resultUri="";

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
          color: Colors.blue,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(key: key,title: title,),
        '/QRCodeScan' :(context) =>QRCodeScan(key: key,),
        '/PointerController' :(context) =>PointerController(key: key,title: title,),
      },
    );
  }
}

