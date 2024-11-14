import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifications {

  static const int notificationId = 0 ;
  static const String notificationChannelId = "your channel id";


  void requestNotificationPermission(){
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  void initializeLocalNotifications() async{
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    // const DarwinInitializationSettings initializationSettingsDarwin =
    // DarwinInitializationSettings();
    // const LinuxInitializationSettings initializationSettingsLinux =
    // LinuxInitializationSettings(
    //     defaultActionName: 'Open notification');
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        // iOS: initializationSettingsDarwin,
        // macOS: initializationSettingsDarwin,
        // linux: initializationSettingsLinux
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          print("Notification is clicked ...");
        },);

    print("Notifications are initialized ...");


  }


  void showNotification({required String position})async{
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(notificationChannelId, 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        notificationId, 'Location Fetching', position, notificationDetails,
        payload: 'item x');
  }



}