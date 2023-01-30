import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 30.0,
                    color: Colors.blue,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Material(
                  elevation: 5.0,
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(30.0),
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/QRCodeScan');
                    },
                    minWidth: 120.0,
                    height: 42.0,
                    child: const Text("Scan QR Code"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
