import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:noti/home.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notification_permissions/notification_permissions.dart';


void main() async{
  await Hive.initFlutter();
  await Hive.openBox('items');
  await NotificationPermissions.requestNotificationPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noti',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
      ),
        home: AnimatedSplashScreen(
          backgroundColor: Colors.black,
          splash: Container(
            color: Colors.black, // Set background color
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.hourglass_empty_sharp,
                  size: 48,
                  color: Colors.white, // Set icon color
                ),
                SizedBox(height: 8),
                Text(
                  'Noti',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set text color
                  ),
                ),
              ],
            ),
          ), nextScreen: const MyHomePage(title: 'Digital Pantry')),
    );
  }
}

