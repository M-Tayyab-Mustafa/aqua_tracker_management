import 'package:flutter/material.dart';

import '../../../utils/firebase_push_notifications.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String screenName = '/home_screen';
  @override
  Widget build(BuildContext context) {
    FirebasePushNotifications.context = context;
    return Scaffold(
      body: Container(),
    );
  }
}
