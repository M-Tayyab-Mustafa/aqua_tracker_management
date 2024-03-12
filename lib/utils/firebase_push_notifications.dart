// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:aqua_tracker_managements/controller/sign_in/_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../controller/manager/home/_bloc.dart' as manager_home_bloc;
import '../view/sign_in/sign_in.dart';
import 'constants.dart';
import 'env.dart';

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
        .requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
    )
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
    const androidNotificationChannel = AndroidNotificationChannel(
      'my_notifications',
      'high_importance_channel',
      importance: Importance.high,
    );
    final platform = _localNotification.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(androidNotificationChannel);

    FirebaseMessaging.onMessage.listen(
      (remoteMessage) => _handleNotification(remoteMessage),
    );
  }

  Future<void> _handleNotification(
    RemoteMessage remoteMessage,
  ) async {
    RemoteNotification remoteNotification = _remoteMessageToRemoteNotification(remoteMessage);
    if (remoteNotification.android!.channelId == 'Sign Out') {
      await FirebaseAuth.instance.signOut();
      manager_home_bloc.HomeBloc.backTabDialogForHomeScreen = false;
      SignInBloc.backTabDialogForSignInScreen = true;
      await localStorage.removeUser().whenComplete(() => context.pushReplacement(SignInScreen.name));
    }
  }

  RemoteNotification _remoteMessageToRemoteNotification(
    RemoteMessage remoteMessage,
  ) {
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
        'Authorization': 'key=$messagingAPIKey',
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
