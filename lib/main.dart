import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/pages/login_page.dart';
import 'package:myapp/pages/main_page.dart';
import 'package:myapp/pages/signup_page.dart';
import 'package:myapp/providers/main_provider.dart';
import 'package:myapp/routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
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

    return FutureBuilder(
      future: provider.getUser(),
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData) {
          return const MainPage();
        } else {
          return FutureBuilder(
            future: provider.getFirst(),
            builder: (context, AsyncSnapshot<bool?> snapshot) {
              if (!snapshot.hasData || snapshot.data!) {
                return const SignUpPage();
              }
              return const LoginPage();
            },
          );
        }
      },
    );

  }
}
