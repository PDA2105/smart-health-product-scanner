import 'package:flutter/material.dart';

import '../../../../routes/app_routes.dart';

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/background_auth.jpg',
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
            ),
          ),
          Positioned(
            top: 100,
            left: 30, // cách mép trái
            child: Text(
              "Hello",
              style: TextStyle(
                fontFamily: 'BBHBartle',
                color: Colors.green,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 160,
            left: 30,
            child: Text(
              "Welcome to Smart Health Product Scanner",
              style: TextStyle(
                fontFamily: 'StoryScript',
                color: Colors.green,
                fontSize: 23,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () => context.navigateToLogin(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Bắt đầu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
