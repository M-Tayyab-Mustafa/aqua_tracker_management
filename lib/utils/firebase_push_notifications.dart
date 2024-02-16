// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class FirebasePushNotifications {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotification = FlutterLocalNotificationsPlugin();
  static late BuildContext context;

  static FirebasePushNotifications? _instance;

  static FirebasePushNotifications get instance => FirebasePushNotifications._factoryObject();

  factory FirebasePushNotifications._factoryObject() {
    return _instance ??= FirebasePushNotifications._privateConstructor();
  }

  FirebasePushNotifications._privateConstructor();

  Future<void> requestPermission() async {
    await _firebaseMessaging
        .requestPermission(announcement: true, carPlay: true, criticalAlert: true, provisional: true)
        .then((notificationSettings) {
      if (notificationSettings.authorizationStatus == AuthorizationStatus.authorized ||
          notificationSettings.authorizationStatus == AuthorizationStatus.provisional) {
        _initFirebasePushNotification();
      } else {
        requestPermission();
      }
    });
  }

  Future<void> _initFirebasePushNotification() async {
    const androidNotificationChannel =
        AndroidNotificationChannel('my_notifications', 'high_importance_channel', importance: Importance.high);
    final platform = _localNotification.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(androidNotificationChannel);
  }

  static RemoteNotification remoteMessageToRemoteNotification(RemoteMessage remoteMessage) {
    AndroidNotification? androidNotification;
    AppleNotification? appleNotification;
    WebNotification? webNotification;

    if (remoteMessage.data['android'] != null) {
      androidNotification = AndroidNotification.fromMap(
        jsonDecode(remoteMessage.data['android']),
      );
    }

    if (remoteMessage.data['apple'] != null) {
      appleNotification = AppleNotification.fromMap(
        jsonDecode(remoteMessage.data['apple']),
      );
    }
    if (remoteMessage.data['web'] != null) {
      webNotification = WebNotification.fromMap(
        jsonDecode(remoteMessage.data['web']),
      );
    }

    return RemoteNotification(
      title: remoteMessage.data['title'],
      body: remoteMessage.data['body'],
      bodyLocKey: remoteMessage.data['bodyLocKey'],
      titleLocKey: remoteMessage.data['titleLocKey'],
      bodyLocArgs: List.from(jsonDecode(remoteMessage.data['bodyLocArgs'])).cast<String>(),
      titleLocArgs: List.from(jsonDecode(remoteMessage.data['titleLocArgs'])).cast<String>(),
      android: androidNotification,
      apple: appleNotification,
      web: webNotification,
    );
  }

  sendSignOutNotification({required String token}) async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAATeQA6lw:APA91bGSqy2pPlX6Piw3bKYLLm2VNB8RPmGtOO-FVGvTTJHW_AdBiFiNRp2lvTnuKFT1elzdGWQRMvLYLrvkch4derPYoJgWs6nkC0H5H-SCQ2p8CGDeG5kUw5ep7WJBtf-67GW_OPWU',
      },
      body: jsonEncode(
        {
          'data': const RemoteNotification(
            android: AndroidNotification(
              channelId: 'Sign Out',
            ),
            title: 'Sign Out',
            body: 'You Signed In From an other Device',
          ).toMap(),
          "to": token,
        },
      ),
    );
  }
}
