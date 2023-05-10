import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Center(child: const Text('About Us           ')),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
                'Welcome to Noti, the expired food tracker app that '
                'helps you keep track of your groceries and reduce '
                'waste by reminding you when food is about to expire and has expired. '
                '\n\nWith Noti, you can easily filter your food items'
                ' with the quick search and keep your kitchen organized.Noti\'s key '
                'features include the ability to track expiration dates '
                'for food items, receive reminders you can set yourself '
                    'for food expiring soon or expired already'
                ', and keep track of items you buy. '
                '\n\nWhether you\'re a busy student or a working '
                'professional, Noti makes it easy to stay on top of your '
                'groceries and reduce waste. Thank you for choosing Noti, '
                'and happy grocery tracking!',

            style: TextStyle(
                fontSize: 22.0,
                color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

