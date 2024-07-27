import 'dart:convert';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import 'GetServerKey.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const _serviceAccountJson = {
    
  };

  static Future<String> getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(_serviceAccountJson);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(accountCredentials, scopes);
    return client.credentials.accessToken.data;
  }

  void sendNotificationToTarget(String targetToken, RemoteMessage message) async {
    final accessToken = await getAccessToken();
    print("Access Token: $accessToken");

    final data = {
      'message': {
        'token': targetToken,
        'notification': {
          'title': message.notification?.title ?? 'Default Title',
          'body': message.notification?.body ?? 'Default Body'
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',  // Ensures the notification opens the app
          'id': '1',  // Custom data
          'status': 'done'  // Custom data
        },
        'android': {
          'priority': 'high',  // Ensures notification is delivered promptly
          'notification': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'content-available': 1,
              'alert': {
                'title': message.notification?.title ?? 'Default Title',
                'body': message.notification?.body ?? 'Default Body',
              },
            },
          },
          'headers': {
            'apns-priority': '10',  // Ensures high priority delivery on iOS
          },
        },
      }
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/chatting-app-2-8e7d4/messages:send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.statusCode}');
      print(response.body);
    }
  }

  void requestNotificationPermission() async{
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true
    );
    if(settings.authorizationStatus==AuthorizationStatus.authorized){

    }else{

    }
  }

  void initLocalNotificationPlugin(){
    var androidInitializationSettings = AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: DarwinInitializationSettings()
    );
    _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (payload){

        }
    );
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      "1000",
      "default_notification",
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    final id = 100;
    await _flutterLocalNotificationsPlugin.show(
      id ?? 0,
      message.notification!.title ?? '',
      message.notification!.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id.toString(),
          channel.name.toString(),
          channelDescription: "Nothing",
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
        ),
      ),

    );
    print("Notification Sent");
  }

  /*void sendNotificationToTarget(String targetToken, RemoteMessage message) async {
    Getserverkey getserverkey = Getserverkey();

    String serverKey = await getserverkey.getServerKeyToken();
    print("xxxxxxxxxxxxxxxxxxServer Keyxxxxxxxxxxxxxxxxxxx");
    print(serverKey);
    print("xxxxxxxxxxxxxxxxxxEnd Server Keyxxxxxxxxxxxxxxxxxxx");

    var data = {
      'to': targetToken,
      'priority': 'high',
      'notification': {
        'title': message.notification!.title,
        'body': message.notification!.body
      }
    };

    var response = await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/chatting-app-2-8e7d4/messages:send'),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $serverKey',
      },
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.statusCode}');
      print(response.body);
    }
  }*/


  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      print("xxxxxxxxxxxxxxxxxxx Firebase Message xxxxxxxxxxxxxxxxxxxxxx");
      // showNotification(message);
    });
  }
   Future<String?> getDeviceToken() async{

    return await messaging.getToken();
  }




}

