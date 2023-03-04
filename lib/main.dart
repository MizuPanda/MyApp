import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/pages/login_page.dart';
import 'package:myapp/pages/main_page.dart';
import 'package:myapp/providers/main_provider.dart';
import 'package:myapp/routes.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';
import 'models/myuser.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  checkPerm();

  runApp(const MyApp());
}

checkPerm() async {
  await Permission.bluetoothScan.request();
  await Permission.bluetoothConnect.request();
  await Permission.bluetoothAdvertise.request();
  await Permission.locationWhenInUse.request();

  if (await Permission.bluetooth.status.isPermanentlyDenied) {
    openAppSettings();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: MyRoutes.router,
    );
  }
}

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  MainProvider provider = MainProvider();

  @override
  Widget build(BuildContext context) {
    if (MyUser.getUser() != null) {
      return const MainPage();
    } else {
      return const LoginPage();
    }
  }
}
