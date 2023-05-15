# Noti

A simple pantry item tracker app made using Flutter. Noti helps you keep track of your groceries and reduce waste by reminding you when food is about to expire or has expired. With Noti, you can easily filter your food items with a quick search. Noti's key features include tracking expiration dates for food items and receiving reminders when food is a certain amount of time away from expiring (decided by the user) or has expired. Whether you're a busy student or a working professional, Noti makes it easy to stay on top of your groceries and reduce waste.

Version 1.0.0 released and in the app store: 
https://play.google.com/store/apps/details?id=com.jerashlant.noti

Version 1.0.1+2 in released

## Code
Dart files located in the lib folder. 
Uses hive, flutter local notifications, flutter datetime picker, timezone, and notification permissions.

about.dart
- contains the code for the construction of the about page

home.dart
- contains the code for the construction and logic most of the home screen and app functionality

main.dart
- contains the code to initialize hive, request notification permission, and run the app with its splash screen

notification.dart
- contains the code for flutter local notifications
