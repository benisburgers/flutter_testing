import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phone_state_i/phone_state_i.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Sensors Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  StreamSubscription streamSubscription;
  AppLifecycleState _notification;
  bool _activeCall = false;

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    print('setstate');
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Example'),
      ),
      body: new Padding(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text('A:'),
            new FlatButton(
                onPressed: () {
                  setState(() {
                    print('refresh');
                  });
                },
                child: Text('Refresh'))
          ],
        ),
        padding: const EdgeInsets.all(16.0),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('didChangeAppLifecycleState');
    print(state);
    setState(() {
      _notification = state;
    });
    switch (state) {
      case AppLifecycleState.resumed:
        resumeCallback();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    phoneStateCallEvent.listen((PhoneStateCallEvent event) {
      // print('Call is Incoming or Connected' + event.stateC);
      if (event.stateC == 'true') {
        // print('yolo ' + event.stateC);
        _activeCall = true;
        _showNotification();
      } else {
        _activeCall = false;
      }
      //event.stateC has values "true" or "false"
    });

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    streamSubscription =
        phoneStateCallEvent.listen((PhoneStateCallEvent event) {
      // print('Call is Incoming or Connected' + event.stateC);
      if (event.stateC == 'true') {
        // print('yolo ' + event.stateC);
        _showNotification();
      }
      //event.stateC has values "true" or "false"
    });
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              print('hello');
            },
          )
        ],
      ),
    );
  }

  Future _showNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');

    String trendingNewsId = '5';
    await flutterLocalNotificationsPlugin.show(0, 'Call happening - yolo 123',
        'Click here to record.', platformChannelSpecifics,
        payload: trendingNewsId);
  }

  Future resumeCallback() async {
    print('resumeCallback');
    if (_activeCall) {
      launch("tel://21213123123");
    }
  }
}
