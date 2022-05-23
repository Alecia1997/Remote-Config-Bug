import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseRemoteConfig _firebaseRemoteConfig = FirebaseRemoteConfig.instance;
  Map<dynamic, dynamic> configValues = {};

  setupRemoteConfig() async {
    await _firebaseRemoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 60),
        minimumFetchInterval: const Duration(hours: 12),
      ),
    );
    await loadRemoteConfig();
  }

  loadRemoteConfig() async {
    try {
      await _firebaseRemoteConfig.fetchAndActivate();
      Map<String, RemoteConfigValue> remoteConfig = _firebaseRemoteConfig.getAll();

      if (remoteConfig.isNotEmpty) {
        RemoteConfigValue? remoteConfigValue = remoteConfig['remoteConfig'];
        if (remoteConfigValue != null) {
          configValues = await jsonDecode(remoteConfigValue.asString());
        }
        return configValues;
      } else {
        return null;
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[firebase_remote_config] BUG'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Remote config values are: ${configValues['value']}',
            ),
            ElevatedButton(
              onPressed: () => setupRemoteConfig(),
              child: Text('Fetch'),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
