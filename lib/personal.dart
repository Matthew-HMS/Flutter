import 'package:flutter/material.dart';

const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);
class PersonalInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is a personal information page',
              style: TextStyle(color: Colors.white),
            ),
            // Add more elements here if needed
          ],
        ),
      ),
    );
  }
}