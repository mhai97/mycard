import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
//the first change
  //the second change (feature 1)
  // the 4th change (feature 1)
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                foregroundImage: AssetImage("asset/image/cat.jpg"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
