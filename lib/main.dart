import 'package:abuzar_bhai/Notifications/local_notifications.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:workmanager/workmanager.dart';


// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     print("Native called background task: $task");
//     try {
//       await location();
//     } catch (e) {
//       throw Exception(e);
//     }
//     return Future.value(true);
//   });
// }

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
  );
}

@pragma("vm:entry-point")
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma("vm:entry-point")
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on("setAsForeground").listen((event) {
      service.setAsForegroundService();
    });
    service.on("setAsBackground").listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on("stopService").listen((event) {
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      service.setForegroundNotificationInfo(
        title: "Field Force",
        content: "Field Force is running",
      );
      try {
        await location();
      } catch (e) {
        print(e.toString());
      }
    }
  }

  // Perform background operations
  service.invoke("update");
}

location() async {
  const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 1,
  );

  StreamSubscription<Position> positionStream =
  Geolocator.getPositionStream(locationSettings: locationSettings)
      .listen((Position? position) {
    print(position == null
        ? 'Unknown'
        : 'location in stream is : ${position.latitude.toString()}, ${position.longitude.toString()}');

    LocalNotifications localNotifications = LocalNotifications();
    localNotifications.initializeLocalNotifications();
    localNotifications.showNotification(position: "${position?.latitude} : ${position?.longitude}");
    // initPlatformState();
  });
}

// initPlatformState() async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   // Your existing code to get user information
//   User? user;
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   user = User.fromJson(jsonDecode(prefs.getString(StorageKey.user) ?? "{}"));
//
//   debugPrint('User ID: ${user.id}');
//   debugPrint('First Name: ${user.firstName}');
//   debugPrint('Last Name: ${user.lastName}');
//   debugPrint('Designation: ${user.designation}');
//   debugPrint('Access Token: ${user.accessToken}');
//   debugPrint('Refresh Token: ${user.refreshToken}');
//   debugPrint('Reports To: ${user.reportsTo}');
//   debugPrint('E-Mail: ${user.email}');
//
//   await _determinePosition();
//
//   if (user.reportsTo != 0) {
//     // Check if any documents with the user's ID already exist
//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection("Location")
//         .where("id", isEqualTo: user.id)
//         .get();
//
//     if (querySnapshot.docs.isNotEmpty) {
//       // If more than one document exists, delete the extra documents
//       if (querySnapshot.docs.length > 1) {
//         for (int i = 1; i < querySnapshot.docs.length; i++) {
//           await querySnapshot.docs[i].reference.delete();
//           print("Extra document deleted");
//         }
//       }
//
//       // Update the existing document
//       querySnapshot.docs.first.reference.update({
//         "first_name": "${user?.firstName}",
//         "last_name": "${user?.lastName}",
//         "designation": "${user?.designation}",
//         "latitude": "$lat",
//         "longitude": "$long",
//         "time_stamp": DateTime.now(),
//         "reports_to": "${user?.reportsTo}",
//         "email": "${user?.email}"
//       }).then((_) {
//         print("Data updated in Firestore");
//       }).catchError((error) {
//         print("Error updating document: $error");
//       });
//     } else {
//       // Add a new document if no documents exist
//       FirebaseFirestore.instance.collection("Location").add({
//         "id": int.parse("${user?.id}"),
//         "first_name": "${user?.firstName}",
//         "last_name": "${user?.lastName}",
//         "designation": "${user?.designation}",
//         "latitude": "$lat",
//         "longitude": "$long",
//         "time_stamp": DateTime.now(),
//         "reports_to": "${user?.reportsTo}",
//         "email": "${user?.email}"
//       }).then((_) {
//         print("New document added to Firestore");
//       }).catchError((error) {
//         print("Error adding document: $error");
//       });
//     }
//   }
// }


_determinePosition() async {
  try {
    Position position = await Geolocator.getCurrentPosition();

    print("Latitude is .. ${position.latitude}");
    print(position.longitude); 
  } catch (e) {}
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  FlutterBackgroundService().invoke("setAsForeground");
  _determinePosition();
  LocalNotifications localNotifications = LocalNotifications();
  localNotifications.requestNotificationPermission();
  localNotifications.initializeLocalNotifications();
  
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
